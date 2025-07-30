#!/bin/bash

# Stage 1 - Cleanup Script
# Health Care Management System - Basic CI/CD Deployment

set -e

echo "🧹 Stage 1: Cleaning up Health Care Management System Resources"
echo "=============================================================="
echo ""
echo "📖 For detailed step-by-step deletion process, see:"
echo "    docs/stage-1-deletion-process.md"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Confirmation prompt
print_warning "This will delete ALL resources created in Stage 1:"
echo "• EKS cluster: healthcare-cluster"
echo "• All applications and data"
echo "• Load balancers and associated AWS resources"
echo "• This action cannot be undone!"
echo ""
read -p "Are you sure you want to proceed? (type 'yes' to confirm): " confirmation

if [ "$confirmation" != "yes" ]; then
    print_info "Cleanup cancelled."
    exit 0
fi

echo ""
print_info "Starting cleanup process..."

# Check if kubectl is configured
if kubectl cluster-info &> /dev/null; then
    print_info "kubectl is configured, proceeding with application cleanup..."

    # Delete application resources first
    if kubectl get namespace healthcare &> /dev/null; then
        print_info "Deleting healthcare namespace and all resources..."
        kubectl delete namespace healthcare --timeout=300s
        print_status "Healthcare namespace deleted"
    else
        print_warning "Healthcare namespace not found"
    fi

else
    print_warning "kubectl not configured or cluster not accessible"
fi

# Delete EKS cluster
print_info "Deleting EKS cluster..."
if eksctl get cluster healthcare-cluster --region us-east-1 &> /dev/null; then
    print_info "Deleting EKS cluster 'healthcare-cluster'..."
    print_warning "This will take 10-15 minutes..."

    eksctl delete cluster --name healthcare-cluster --region us-east-1 --wait
    print_status "EKS cluster deleted successfully"
else
    print_warning "EKS cluster 'healthcare-cluster' not found"
fi

# Clean up local Docker images (optional)
print_info "Cleaning up local Docker images..."
read -p "Do you want to remove local Docker images? (y/n): " remove_images

if [ "$remove_images" = "y" ] || [ "$remove_images" = "Y" ]; then
    # Remove healthcare images
    docker images | grep healthcare | awk '{print $3}' | xargs -r docker rmi -f 2>/dev/null || true
    print_status "Local Docker images cleaned up"
else
    print_info "Skipping Docker image cleanup"
fi

# Verify cleanup
echo ""
print_info "Verifying cleanup..."

# Check if cluster still exists
if eksctl get cluster healthcare-cluster --region us-east-1 &> /dev/null; then
    print_warning "EKS cluster still exists - cleanup may not be complete"
else
    print_status "EKS cluster successfully removed"
fi

# Check AWS resources
print_info "Checking for remaining AWS resources..."
print_warning "Please manually verify in AWS Console that the following are cleaned up:"
echo "• EC2 instances (should be terminated)"
echo "• Load Balancers (should be deleted)"
echo "• VPC and subnets (if created by eksctl)"
echo "• Security Groups (if created by eksctl)"
echo "• IAM roles (if created by eksctl)"

echo ""
print_info "=== CLEANUP SUMMARY ==="
echo "✅ Healthcare namespace deleted"
echo "✅ EKS cluster deleted"
echo "✅ Associated AWS resources should be cleaned up automatically"

echo ""
print_warning "IMPORTANT NOTES:"
echo "1. Check your AWS billing to ensure all resources are stopped"
echo "2. Some resources may take a few minutes to fully terminate"
echo "3. CloudFormation stacks created by eksctl should be deleted automatically"
echo "4. Your Docker Hub images remain available for future use"

echo ""
print_info "Recommended next steps:"
echo "1. 💰 Check AWS Cost Explorer to verify no ongoing charges"
echo "2. 🔍 Review AWS Console for any remaining resources"
echo "3. 📊 Document lessons learned for Stage 2"
echo "4. 🚀 Plan Stage 2 automated CI/CD implementation"

echo ""
print_status "Stage 1 cleanup completed!"
print_info "You can now proceed to Stage 2 or re-run Stage 1 anytime."