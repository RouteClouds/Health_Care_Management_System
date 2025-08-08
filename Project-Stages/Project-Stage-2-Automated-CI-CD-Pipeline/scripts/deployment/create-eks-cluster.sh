#!/bin/bash

# Stage 2 - Create EKS Cluster Script
# Health Care Management System - Automated CI/CD Pipeline

set -e

echo "🚀 Stage 2: Creating Multi-Environment EKS Cluster for Health Care Management System"
echo "=================================================================================="

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

# Configuration
CLUSTER_NAME="healthcare-cluster-stage2"
CLUSTER_VERSION="1.32"
REGION="us-east-1"
NODE_GROUP_NAME="healthcare-nodes-stage2"
NODE_TYPE="t3.medium"
MIN_NODES=2
MAX_NODES=6
DESIRED_NODES=3

echo ""
print_info "Cluster Configuration:"
echo "• Cluster Name: $CLUSTER_NAME"
echo "• EKS Version: $CLUSTER_VERSION (compatible with your kubectl v1.33.3)"
echo "• Region: $REGION"
echo "• Node Type: $NODE_TYPE"
echo "• Node Count: $DESIRED_NODES (min: $MIN_NODES, max: $MAX_NODES)"
echo "• Estimated Cost: ~$163/month"

echo ""
print_warning "Prerequisites Check:"

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI not found. Please install AWS CLI first."
    exit 1
fi

# Check eksctl
if ! command -v eksctl &> /dev/null; then
    print_error "eksctl not found. Please install eksctl first."
    exit 1
fi

# Check kubectl
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl not found. Please install kubectl first."
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS credentials not configured. Please run 'aws configure' first."
    exit 1
fi

print_status "All prerequisites met"

# Check if cluster already exists
echo ""
print_info "Checking if cluster already exists..."
if eksctl get cluster $CLUSTER_NAME --region $REGION &> /dev/null; then
    print_warning "Cluster '$CLUSTER_NAME' already exists in region $REGION"
    print_info "Existing cluster details:"
    eksctl get cluster $CLUSTER_NAME --region $REGION
    echo ""
    read -p "Do you want to continue anyway? (y/n): " continue_anyway
    if [ "$continue_anyway" != "y" ] && [ "$continue_anyway" != "Y" ]; then
        print_info "Cluster creation cancelled."
        exit 0
    fi
else
    print_status "No existing cluster found. Ready to create new cluster."
fi

# Confirmation
echo ""
print_warning "This will create AWS resources that will incur costs (~$163/month):"
echo "• EKS Control Plane: ~$73/month"
echo "• EC2 Worker Nodes (2x t3.medium): ~$60/month"
echo "• Load Balancer: ~$20/month"
echo "• Storage and Data Transfer: ~$10/month"
echo ""
read -p "Do you want to proceed with cluster creation? (type 'yes' to confirm): " confirmation

if [ "$confirmation" != "yes" ]; then
    print_info "Cluster creation cancelled."
    exit 0
fi

# Create cluster
echo ""
print_info "Creating EKS cluster..."
print_warning "This will take 15-20 minutes. Please be patient."

echo ""
print_info "Running eksctl command:"
echo "eksctl create cluster \\"
echo "  --name $CLUSTER_NAME \\"
echo "  --version $CLUSTER_VERSION \\"
echo "  --region $REGION \\"
echo "  --nodegroup-name $NODE_GROUP_NAME \\"
echo "  --node-type $NODE_TYPE \\"
echo "  --nodes $DESIRED_NODES \\"
echo "  --nodes-min $MIN_NODES \\"
echo "  --nodes-max $MAX_NODES \\"
echo "  --managed \\"
echo "  --with-oidc \\"
echo "  --full-ecr-access \\"
echo "  --asg-access \\"
echo "  --external-dns-access \\"
echo "  --alb-ingress-access"

echo ""
print_info "Starting cluster creation..."

eksctl create cluster \
  --name $CLUSTER_NAME \
  --version $CLUSTER_VERSION \
  --region $REGION \
  --nodegroup-name $NODE_GROUP_NAME \
  --node-type $NODE_TYPE \
  --nodes $DESIRED_NODES \
  --nodes-min $MIN_NODES \
  --nodes-max $MAX_NODES \
  --managed \
  --with-oidc \
  --full-ecr-access \
  --asg-access \
  --external-dns-access \
  --alb-ingress-access

# Verify cluster creation
echo ""
print_info "Verifying cluster creation..."

# Configure kubectl
print_info "Configuring kubectl..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

# Check cluster info
print_info "Cluster information:"
kubectl cluster-info

# Check nodes
print_info "Cluster nodes:"
kubectl get nodes -o wide

# Check version compatibility
print_info "Version compatibility check:"
kubectl version --client --output=yaml | grep gitVersion || kubectl version --client

echo ""
print_status "EKS cluster created successfully!"

echo ""
print_info "Cluster Details:"
echo "================"
eksctl get cluster $CLUSTER_NAME --region $REGION

echo ""
print_info "Next Steps:"
echo "1. ✅ EKS cluster is ready"
echo "2. 🐳 Build and push Docker images to Docker Hub"
echo "3. 🚀 Deploy application: ../deploy-healthcare.sh"
echo "4. 🔍 Verify deployment: ./verify-deployment.sh"

echo ""
print_warning "Important Notes:"
echo "• Your cluster is now running and incurring costs"
echo "• Use '../deploy-healthcare.sh --help' for deployment options"
echo "• Monitor your AWS billing dashboard"

echo ""
print_status "Ready for application deployment!"
