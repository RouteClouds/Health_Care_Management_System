#!/bin/bash

# Update Database Configuration Script
# This script updates the GitOps manifests with the actual RDS endpoint from Terraform

set -e

echo "🔧 Updating database configuration with actual RDS endpoint..."

# Check if we're in the right directory
if [[ ! -f "terraform/environments/dev/main.tf" ]]; then
    echo "❌ Error: Must be run from the project root directory"
    echo "Current directory: $(pwd)"
    exit 1
fi

# Get RDS endpoint from Terraform
echo "🗄️ Getting RDS endpoint from Terraform..."
cd terraform/environments/dev

if terraform output db_instance_endpoint >/dev/null 2>&1; then
    ACTUAL_RDS_ENDPOINT=$(terraform output -raw db_instance_endpoint)
    echo "✅ Found RDS endpoint: $ACTUAL_RDS_ENDPOINT"
else
    echo "❌ Could not get RDS endpoint from Terraform outputs"
    echo "📋 Available outputs:"
    terraform output
    exit 1
fi

# Return to project root
cd ../../..

# Update GitOps manifests
GITOPS_DIR="gitops/environments/dev"
BACKEND_MANIFEST="$GITOPS_DIR/backend.yaml"

if [[ ! -f "$BACKEND_MANIFEST" ]]; then
    echo "❌ Error: Backend manifest not found at $BACKEND_MANIFEST"
    exit 1
fi

echo "🔧 Updating database configuration in $BACKEND_MANIFEST..."

# Create backup
cp "$BACKEND_MANIFEST" "$BACKEND_MANIFEST.backup"

# Replace placeholder RDS endpoint with actual endpoint
# Handle various possible placeholder formats
sed -i "s|healthcare-eks-stage3-dev-db\.c6t4q0g6i4n5\.us-east-1\.rds\.amazonaws\.com|$ACTUAL_RDS_ENDPOINT|g" "$BACKEND_MANIFEST"
sed -i "s|healthcare-eks-stage3-dev-db\.cluster-[a-zA-Z0-9]*\.us-east-1\.rds\.amazonaws\.com|$ACTUAL_RDS_ENDPOINT|g" "$BACKEND_MANIFEST"
sed -i "s|YOUR_RDS_ENDPOINT_HERE|$ACTUAL_RDS_ENDPOINT|g" "$BACKEND_MANIFEST"

echo "✅ Database configuration updated"
echo "🔍 Verifying database URL update:"
grep -A 2 -B 2 "postgresql://" "$BACKEND_MANIFEST" || echo "No postgresql URL found"

# Verify the change was made
if grep -q "$ACTUAL_RDS_ENDPOINT" "$BACKEND_MANIFEST"; then
    echo "✅ RDS endpoint successfully updated in manifest"
else
    echo "⚠️ Warning: RDS endpoint may not have been updated properly"
    echo "Please check the manifest manually"
fi

echo "🎉 Database configuration update completed!"
echo "📋 Backup saved as: $BACKEND_MANIFEST.backup"

# In CI/CD environment, don't restore immediately - let the pipeline handle it
if [[ -z "$CI" ]]; then
    echo ""
    echo "💡 To restore the original configuration later, run:"
    echo "   mv $BACKEND_MANIFEST.backup $BACKEND_MANIFEST"
else
    echo "🤖 Running in CI/CD environment - backup will be restored automatically after deployment"
fi
