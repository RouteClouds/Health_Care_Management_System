#!/bin/bash

echo "🗄️ Database Validation Script"
echo "============================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Configuration
NAMESPACE="healthcare-stage3-dev"

# Validation counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

validate_check() {
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if [ $1 -eq 0 ]; then
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        log_success "$2"
    else
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        log_error "$2"
    fi
}

# Get LoadBalancer URL
get_lb_url() {
    kubectl get service frontend-stage3-svc -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null
}

log_info "Starting database validation..."

# 1. Validate database credentials secret
log_info "1. Validating database credentials..."
kubectl get secret database-credentials-stage3 -n $NAMESPACE > /dev/null 2>&1
validate_check $? "Database credentials secret exists"

# 2. Validate database URL format
log_info "2. Validating database URL format..."
DB_URL=$(kubectl get secret database-credentials-stage3 -n $NAMESPACE -o jsonpath='{.data.url}' 2>/dev/null | base64 -d 2>/dev/null)
if echo "$DB_URL" | grep -q "postgresql://.*healthcare.*:.*@.*healthcare-eks-stage3-dev-db.*:5432/healthcare_stage3_db"; then
    validate_check 0 "Database URL format is valid"
else
    validate_check 1 "Database URL format is invalid or missing"
fi

# 3. Validate backend pod can connect to database
log_info "3. Validating backend database connectivity..."
BACKEND_POD=$(kubectl get pods -n $NAMESPACE -l app=healthcare-backend-stage3 --field-selector=status.phase=Running -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -n "$BACKEND_POD" ]; then
    log_info "Using backend pod: $BACKEND_POD"
    
    # Test database connection from backend pod
    DB_TEST=$(kubectl exec -it $BACKEND_POD -n $NAMESPACE -- node -e "
        const { PrismaClient } = require('@prisma/client');
        const prisma = new PrismaClient();
        prisma.\$connect()
            .then(() => { console.log('DATABASE_CONNECTED'); process.exit(0); })
            .catch(() => { console.log('DATABASE_FAILED'); process.exit(1); });
    " 2>/dev/null | tr -d '\r')
    
    if echo "$DB_TEST" | grep -q "DATABASE_CONNECTED"; then
        validate_check 0 "Backend can connect to database"
    else
        validate_check 1 "Backend cannot connect to database"
    fi
else
    validate_check 1 "No running backend pod found for database testing"
fi

# 4. Validate API health endpoint
log_info "4. Validating API health endpoint..."
LB_URL=$(get_lb_url)
if [ -n "$LB_URL" ]; then
    HEALTH_RESPONSE=$(curl -s --max-time 10 "http://$LB_URL/api/health" 2>/dev/null)
    if echo "$HEALTH_RESPONSE" | jq -e '.database == "connected"' > /dev/null 2>&1; then
        validate_check 0 "API health endpoint reports database connected"
    else
        validate_check 1 "API health endpoint reports database issues"
    fi
else
    validate_check 1 "Load balancer URL not available for health check"
fi

# 5. Validate database schema (tables exist)
log_info "5. Validating database schema..."
if [ -n "$BACKEND_POD" ]; then
    TABLES_CHECK=$(kubectl exec -it $BACKEND_POD -n $NAMESPACE -- node -e "
        const { PrismaClient } = require('@prisma/client');
        const prisma = new PrismaClient();
        prisma.doctor.count()
            .then(() => { console.log('TABLES_EXIST'); process.exit(0); })
            .catch(() => { console.log('TABLES_MISSING'); process.exit(1); });
    " 2>/dev/null | tr -d '\r')
    
    if echo "$TABLES_CHECK" | grep -q "TABLES_EXIST"; then
        validate_check 0 "Database schema is properly migrated"
    else
        validate_check 1 "Database schema is missing or incomplete"
    fi
else
    validate_check 1 "Cannot validate schema - no backend pod available"
fi

# 6. Validate sample data exists
log_info "6. Validating sample data..."
if [ -n "$LB_URL" ]; then
    # Test doctors endpoint
    DOCTORS_RESPONSE=$(curl -s --max-time 10 "http://$LB_URL/api/doctors" 2>/dev/null)
    DOCTORS_COUNT=$(echo "$DOCTORS_RESPONSE" | jq -r '.data.doctors | length' 2>/dev/null)
    
    if [ "$DOCTORS_COUNT" -gt 0 ] 2>/dev/null; then
        validate_check 0 "Sample doctors data exists ($DOCTORS_COUNT doctors)"
    else
        validate_check 1 "No sample doctors data found"
    fi
    
    # Test departments endpoint
    DEPARTMENTS_RESPONSE=$(curl -s --max-time 10 "http://$LB_URL/api/departments" 2>/dev/null)
    DEPARTMENTS_COUNT=$(echo "$DEPARTMENTS_RESPONSE" | jq -r '.data.departments | length' 2>/dev/null)
    
    if [ "$DEPARTMENTS_COUNT" -gt 0 ] 2>/dev/null; then
        validate_check 0 "Sample departments data exists ($DEPARTMENTS_COUNT departments)"
    else
        validate_check 1 "No sample departments data found"
    fi
else
    validate_check 1 "Cannot validate sample data - load balancer URL not available"
fi

# 7. Validate API endpoints functionality
log_info "7. Validating API endpoints functionality..."
if [ -n "$LB_URL" ]; then
    # Test doctors API
    DOCTORS_API=$(curl -s --max-time 10 "http://$LB_URL/api/doctors" 2>/dev/null)
    if echo "$DOCTORS_API" | jq -e '.success == true' > /dev/null 2>&1; then
        validate_check 0 "Doctors API endpoint is functional"
    else
        validate_check 1 "Doctors API endpoint is not functional"
    fi
    
    # Test departments API
    DEPARTMENTS_API=$(curl -s --max-time 10 "http://$LB_URL/api/departments" 2>/dev/null)
    if echo "$DEPARTMENTS_API" | jq -e '.success == true' > /dev/null 2>&1; then
        validate_check 0 "Departments API endpoint is functional"
    else
        validate_check 1 "Departments API endpoint is not functional"
    fi
else
    validate_check 1 "Cannot validate API endpoints - load balancer URL not available"
fi

# 8. Validate database performance
log_info "8. Validating database performance..."
if [ -n "$LB_URL" ]; then
    START_TIME=$(date +%s%N)
    curl -s --max-time 5 "http://$LB_URL/api/doctors" > /dev/null 2>&1
    END_TIME=$(date +%s%N)
    RESPONSE_TIME=$(( (END_TIME - START_TIME) / 1000000 )) # Convert to milliseconds
    
    if [ $RESPONSE_TIME -lt 2000 ]; then
        validate_check 0 "Database response time is acceptable (${RESPONSE_TIME}ms)"
    else
        validate_check 1 "Database response time is slow (${RESPONSE_TIME}ms)"
    fi
else
    validate_check 1 "Cannot validate database performance - load balancer URL not available"
fi

# 9. Validate data integrity
log_info "9. Validating data integrity..."
if [ -n "$LB_URL" ]; then
    # Check if doctors have department relationships
    DOCTORS_WITH_DEPARTMENTS=$(curl -s --max-time 10 "http://$LB_URL/api/doctors" 2>/dev/null | jq -r '.data.doctors[] | select(.department != null) | .id' 2>/dev/null | wc -l)
    
    if [ "$DOCTORS_WITH_DEPARTMENTS" -gt 0 ] 2>/dev/null; then
        validate_check 0 "Data integrity check passed - doctors have department relationships"
    else
        validate_check 1 "Data integrity check failed - doctors missing department relationships"
    fi
else
    validate_check 1 "Cannot validate data integrity - load balancer URL not available"
fi

# 10. Validate database backup capability
log_info "10. Validating database backup capability..."
if [ -n "$BACKEND_POD" ]; then
    # Test if we can run database operations (indicates backup capability)
    BACKUP_TEST=$(kubectl exec -it $BACKEND_POD -n $NAMESPACE -- node -e "
        const { PrismaClient } = require('@prisma/client');
        const prisma = new PrismaClient();
        prisma.department.findMany()
            .then((data) => { 
                if (data.length > 0) {
                    console.log('BACKUP_CAPABLE'); 
                } else {
                    console.log('BACKUP_NO_DATA');
                }
                process.exit(0); 
            })
            .catch(() => { console.log('BACKUP_FAILED'); process.exit(1); });
    " 2>/dev/null | tr -d '\r')
    
    if echo "$BACKUP_TEST" | grep -q "BACKUP_CAPABLE"; then
        validate_check 0 "Database backup capability is available"
    else
        validate_check 1 "Database backup capability test failed"
    fi
else
    validate_check 1 "Cannot validate backup capability - no backend pod available"
fi

# Summary
echo ""
echo "============================"
echo "📊 Database Validation Summary"
echo "============================"
echo "Total Checks: $TOTAL_CHECKS"
echo "Passed: $PASSED_CHECKS"
echo "Failed: $FAILED_CHECKS"

if [ $FAILED_CHECKS -eq 0 ]; then
    log_success "🎉 All database validation checks passed!"
    echo ""
    echo "✅ Database is properly configured and functional"
    echo "✅ Sample data is available for testing"
    echo "✅ API endpoints are working correctly"
    exit 0
else
    log_error "❌ $FAILED_CHECKS database validation checks failed"
    echo ""
    echo "🔧 Please fix the failed checks before proceeding"
    echo ""
    echo "Common fixes:"
    echo "- Check database credentials in secret"
    echo "- Verify RDS endpoint configuration"
    echo "- Run database migrations: kubectl exec -it BACKEND_POD -- npx prisma migrate deploy"
    echo "- Run database seeding: kubectl exec -it BACKEND_POD -- npm run db:seed"
    exit 1
fi
