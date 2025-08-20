#!/bin/bash

# Update Database Configuration Script
# This script updates the GitOps manifests with the actual RDS endpoint (hostname)
# Prefer Terraform outputs; fall back to AWS CLI if Terraform is unavailable or outputs are missing

set -euo pipefail

echo "🔧 Updating database configuration with actual RDS endpoint..."

# Optional mode argument ("cluster" forces in-cluster secret update)
MODE="${1:-}"

# Ensure we're at the Stage-3 project root (where terraform/ and gitops/ exist)
if [[ ! -f "terraform/environments/dev/main.tf" ]]; then
    echo "❌ Error: Must be run from the Stage-3 project root directory"
    echo "Current directory: $(pwd)"
    exit 1
fi

AWS_REGION_ENV="${AWS_REGION:-us-east-1}"

# Helper to resolve RDS endpoint via AWS CLI
resolve_rds_endpoint_via_aws() {
    local region="$1"
    local identifier_prefix="healthcare-eks-stage3-dev-db"
    echo "🌐 Falling back to AWS CLI to resolve RDS endpoint (region=${region})..."
    # Find the DB instance by identifier prefix
    local query="DBInstances[?contains(DBInstanceIdentifier, \`${identifier_prefix}\`)].{addr:Endpoint.Address,port:Endpoint.Port}"
    local result_json
    if ! result_json=$(aws rds describe-db-instances --region "$region" --query "$query" --output json 2>/dev/null); then
        echo "❌ AWS CLI failed to describe DB instances"
        return 1
    fi

    local addr
    local port
    addr=$(echo "$result_json" | jq -r '.[0].addr // empty')
    port=$(echo "$result_json" | jq -r '.[0].port // empty')
    if [[ -z "${addr}" ]]; then
        echo "❌ Could not locate RDS instance with identifier containing '${identifier_prefix}'"
        return 1
    fi
    if [[ -z "${port}" ]]; then
        port=5432
    fi
    echo "${addr}:${port}"
}

# Attempt to obtain endpoint via env override, then Terraform, then AWS CLI
ACTUAL_RDS_ENDPOINT=""
RDS_HOSTNAME=""

# Allow CI to override via environment variable
if [[ -n "${RDS_ENDPOINT_OVERRIDE:-}" ]]; then
    if [[ "$RDS_ENDPOINT_OVERRIDE" =~ \.rds\.amazonaws\.com$ ]]; then
        ACTUAL_RDS_ENDPOINT="$RDS_ENDPOINT_OVERRIDE"
        echo "✅ Using RDS endpoint from environment override: $ACTUAL_RDS_ENDPOINT"
    else
        echo "⚠️ Provided RDS_ENDPOINT_OVERRIDE is invalid: '$RDS_ENDPOINT_OVERRIDE'"
    fi
elif [[ -n "${RDS_ENDPOINT:-}" ]]; then
    if [[ "$RDS_ENDPOINT" =~ \.rds\.amazonaws\.com$ ]]; then
        ACTUAL_RDS_ENDPOINT="$RDS_ENDPOINT"
        echo "✅ Using RDS endpoint from environment: $ACTUAL_RDS_ENDPOINT"
    else
        echo "⚠️ Provided RDS_ENDPOINT is invalid: '$RDS_ENDPOINT'"
    fi
fi

if [[ -z "$ACTUAL_RDS_ENDPOINT" ]]; then
    echo "🗄️ Getting RDS endpoint from Terraform (preferred)..."
    pushd terraform/environments/dev >/dev/null
    if command -v terraform >/dev/null 2>&1; then
        # Initialize backend to access remote state if needed, but keep it lightweight
        if terraform output >/dev/null 2>&1; then
            :
        else
            terraform init -input=false -no-color >/dev/null 2>&1 || true
        fi

        # Check if terraform output is available and valid
        if terraform output db_instance_endpoint >/dev/null 2>&1; then
            TEMP_OUTPUT=$(terraform output -raw db_instance_endpoint 2>/dev/null || echo "")
            if [[ -n "$TEMP_OUTPUT" && "$TEMP_OUTPUT" =~ \\.[r]ds\\.amazonaws\\.com$ ]]; then
                ACTUAL_RDS_ENDPOINT="$TEMP_OUTPUT"
                echo "✅ Found valid RDS endpoint via Terraform: $ACTUAL_RDS_ENDPOINT"
            else
                echo "⚠️ Terraform output exists but is not a valid RDS endpoint: '$TEMP_OUTPUT'"
                ACTUAL_RDS_ENDPOINT=""
            fi
        else
            echo "ℹ️ Terraform output 'db_instance_endpoint' not available"
            ACTUAL_RDS_ENDPOINT=""
        fi
    else
        echo "ℹ️ Terraform is not installed in this job environment"
    fi
    popd >/dev/null
fi

# Enhanced AWS CLI fallback with multiple methods
if [[ -z "${ACTUAL_RDS_ENDPOINT}" ]]; then
    echo "🌐 Using AWS CLI to discover RDS endpoint..."

    # Try multiple methods to find the RDS instance
    RDS_IDENTIFIER="healthcare-eks-stage3-dev-db"

    # Method 1: Direct identifier lookup
    if aws rds describe-db-instances --db-instance-identifier "$RDS_IDENTIFIER" --region "$AWS_REGION_ENV" >/dev/null 2>&1; then
        ACTUAL_RDS_ENDPOINT=$(aws rds describe-db-instances \
            --db-instance-identifier "$RDS_IDENTIFIER" \
            --region "$AWS_REGION_ENV" \
            --query 'DBInstances[0].Endpoint.Address' \
            --output text 2>/dev/null)
        echo "✅ Found RDS endpoint via AWS CLI (direct): $ACTUAL_RDS_ENDPOINT"
    else
        # Method 2: Search by tag or pattern
        echo "🔍 Searching for RDS instance by pattern..."
        if ACTUAL_RDS_ENDPOINT=$(resolve_rds_endpoint_via_aws "$AWS_REGION_ENV"); then
            echo "✅ Found RDS endpoint via AWS CLI (search): $ACTUAL_RDS_ENDPOINT"
        else
            echo "❌ Could not determine RDS endpoint via Terraform or AWS CLI"
            exit 1
        fi
    fi
fi

# Extract hostname and validate it
RDS_HOSTNAME="${ACTUAL_RDS_ENDPOINT%%:*}"

# Validate RDS hostname before using in sed
if [[ ! "$RDS_HOSTNAME" =~ ^[a-zA-Z0-9.-]+\.rds\.amazonaws\.com$ ]]; then
    echo "❌ Invalid RDS hostname format: '$RDS_HOSTNAME'"
    echo "Expected format: *.rds.amazonaws.com"
    exit 1
fi

echo "🔎 Using validated RDS hostname for manifest substitution: ${RDS_HOSTNAME}"

# Try updating the cluster Secret first if kubectl is available and the Secret exists,
# or if mode is explicitly set to "cluster"
CAN_USE_CLUSTER=false
if command -v kubectl >/dev/null 2>&1; then
    if kubectl get namespace healthcare-stage3-dev >/dev/null 2>&1; then
        if kubectl -n healthcare-stage3-dev get secret database-credentials-stage3 >/dev/null 2>&1; then
            CAN_USE_CLUSTER=true
        elif [[ "$MODE" == "--mode=cluster" || "$MODE" == "cluster" ]]; then
            # Secret may not exist yet, but if mode forces cluster, we'll still try to create it
            CAN_USE_CLUSTER=true
        fi
    fi
fi

if [[ "$CAN_USE_CLUSTER" == "true" ]]; then
    echo "🔐 Updating Kubernetes Secret 'database-credentials-stage3' in namespace 'healthcare-stage3-dev'..."

    # Read existing values (fallbacks if keys are missing)
    EXISTING_USER=$(kubectl -n healthcare-stage3-dev get secret database-credentials-stage3 -o jsonpath='{.data.username}' 2>/dev/null | base64 -d || echo "healthcare_stage3_user")
    EXISTING_PASS=$(kubectl -n healthcare-stage3-dev get secret database-credentials-stage3 -o jsonpath='{.data.password}' 2>/dev/null | base64 -d || echo "healthcare_stage3_password_change_me")
    EXISTING_DB=$(kubectl -n healthcare-stage3-dev get secret database-credentials-stage3 -o jsonpath='{.data.database}' 2>/dev/null | base64 -d || echo "healthcare_stage3_db")
    EXISTING_PORT=$(kubectl -n healthcare-stage3-dev get secret database-credentials-stage3 -o jsonpath='{.data.port}' 2>/dev/null | base64 -d || echo "5432")

    NEW_URL="postgresql://${EXISTING_USER}:${EXISTING_PASS}@${RDS_HOSTNAME}:${EXISTING_PORT}/${EXISTING_DB}"

    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: database-credentials-stage3
  namespace: healthcare-stage3-dev
type: Opaque
stringData:
  url: "${NEW_URL}"
  host: "${RDS_HOSTNAME}"
  port: "${EXISTING_PORT}"
  database: "${EXISTING_DB}"
  username: "${EXISTING_USER}"
  password: "${EXISTING_PASS}"
EOF

    echo "✅ Secret updated with actual RDS endpoint: ${RDS_HOSTNAME}"

    # Verify the update worked
    echo "🔍 Verifying Secret update..."
    UPDATED_URL=$(kubectl -n healthcare-stage3-dev get secret database-credentials-stage3 -o jsonpath='{.data.url}' 2>/dev/null | base64 -d || echo "FAILED_TO_READ")
    echo "📋 Updated Secret URL: $UPDATED_URL"

    if echo "$UPDATED_URL" | grep -q "$RDS_HOSTNAME"; then
        echo "✅ Secret verification successful - contains actual RDS hostname"
    else
        echo "⚠️ WARNING: Secret may not have been updated properly"
        echo "Expected hostname: $RDS_HOSTNAME"
        echo "Actual URL: $UPDATED_URL"
    fi

    echo "ℹ️ Please restart the backend deployment to pick up new env vars."
    exit 0
fi

# Fallback: Update GitOps manifest on disk (used when cluster resources are not available yet)
GITOPS_DIR="gitops/environments/dev"
BACKEND_MANIFEST="$GITOPS_DIR/backend.yaml"

if [[ ! -f "$BACKEND_MANIFEST" ]]; then
    echo "❌ Error: Backend manifest not found at $BACKEND_MANIFEST"
    exit 1
fi

echo "📝 Cluster Secret not available; updating GitOps manifest file: $BACKEND_MANIFEST"

# Create backup
cp "$BACKEND_MANIFEST" "$BACKEND_MANIFEST.backup"

# Safe sed commands with proper escaping and validation
echo "🔧 Replacing RDS endpoint placeholders with actual hostname..."

# Replace known placeholder patterns (escape dots for regex)
sed -i "s|healthcare-eks-stage3-dev-db\\.c6t4q0g6i4n5\\.us-east-1\\.rds\\.amazonaws\\.com|$RDS_HOSTNAME|g" "$BACKEND_MANIFEST"
sed -i "s|healthcare-eks-stage3-dev-db\\.cluster-[a-zA-Z0-9]*\\.us-east-1\\.rds\\.amazonaws\\.com|$RDS_HOSTNAME|g" "$BACKEND_MANIFEST"
sed -i "s|YOUR_RDS_ENDPOINT_HERE|$RDS_HOSTNAME|g" "$BACKEND_MANIFEST"

# Verify the replacement worked
if ! grep -q "$RDS_HOSTNAME" "$BACKEND_MANIFEST"; then
    echo "⚠️ Warning: RDS hostname replacement may have failed"
    echo "🔍 Checking for any remaining placeholders..."
    grep -n "YOUR_RDS_ENDPOINT_HERE\|healthcare-eks-stage3-dev-db\\.c6t4q0g6i4n5" "$BACKEND_MANIFEST" || echo "No obvious placeholders found"
fi

echo "✅ Manifest updated"
echo "🔍 Verifying database URL update:"
grep -A 2 -B 2 "postgresql://" "$BACKEND_MANIFEST" || echo "No postgresql URL found"

if grep -q "$RDS_HOSTNAME" "$BACKEND_MANIFEST"; then
    echo "✅ RDS hostname successfully updated in manifest"
else
    echo "⚠️ Warning: RDS hostname may not have been updated properly"
fi

echo "🎉 Database configuration update completed!"
echo "📋 Backup saved as: $BACKEND_MANIFEST.backup"

if [[ -z "${CI:-}" ]]; then
    echo ""
    echo "💡 To restore the original configuration later, run:"
    echo "   mv $BACKEND_MANIFEST.backup $BACKEND_MANIFEST"
else
    echo "🤖 Running in CI/CD environment - backup will be restored automatically after deployment"
fi
