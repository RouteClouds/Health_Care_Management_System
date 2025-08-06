#!/bin/bash

# Healthcare Management System - Stage 1 Docker Image Build and Push Script
# Simple Docker build and push for basic CI/CD deployment

set -e

echo "🚀 Stage 1: Building and Pushing Docker Images"
echo "=============================================="

# Determine script location and set paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAGE_DIR="$(dirname "$SCRIPT_DIR")"
SRC_CODE_DIR="$STAGE_DIR/src-code"

# Configuration
DOCKER_REGISTRY="routeclouds"
BACKEND_IMAGE="${DOCKER_REGISTRY}/healthcare-backend"
FRONTEND_IMAGE="${DOCKER_REGISTRY}/healthcare-frontend"
VERSION="v1.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if source code directory exists
if [ ! -d "$SRC_CODE_DIR" ]; then
    print_error "Source code directory not found: $SRC_CODE_DIR"
    print_error "Please run this script from the Stage-1 directory"
    exit 1
fi

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Function to check Docker Hub login
check_docker_login() {
    print_status "Checking Docker Hub authentication..."

    # Try to get Docker Hub username
    DOCKER_USERNAME=$(docker info 2>/dev/null | grep "Username:" | awk '{print $2}' || echo "")

    if [ -z "$DOCKER_USERNAME" ]; then
        print_error "❌ Not logged into Docker Hub!"
        echo ""
        print_info "To push images to Docker Hub, you need to login first:"
        echo "1. Create account at https://hub.docker.com (if you don't have one)"
        echo "2. Run: docker login"
        echo "3. Enter your Docker Hub username and password"
        echo ""

        # Prompt user for login
        read -p "Do you want to login to Docker Hub now? (y/n): " login_choice

        if [ "$login_choice" = "y" ] || [ "$login_choice" = "Y" ]; then
            print_info "Please login to Docker Hub:"
            if docker login; then
                print_success "✅ Successfully logged into Docker Hub"
                DOCKER_USERNAME=$(docker info 2>/dev/null | grep "Username:" | awk '{print $2}')
            else
                print_error "❌ Docker login failed"
                exit 1
            fi
        else
            print_error "Cannot push images without Docker Hub login"
            print_info "You can build images locally by modifying the script to skip push commands"
            exit 1
        fi
    else
        print_success "✅ Logged into Docker Hub as: $DOCKER_USERNAME"
    fi
}

# Check Docker Hub login
check_docker_login

print_success "Docker is running"
print_status "Using source code directory: $SRC_CODE_DIR"

# Navigate to source code directory
cd "$SRC_CODE_DIR"

print_info "📦 Docker Build Process Information:"
echo "• All NPM packages will be automatically installed during Docker build"
echo "• Backend: Node.js dependencies from package.json and package-lock.json"
echo "• Frontend: React dependencies and build process included"
echo "• No need to run 'npm install' manually - Docker handles everything!"
echo ""

print_status "Building Healthcare Backend Image..."
echo "Building: ${BACKEND_IMAGE}:${VERSION}"
print_info "⏳ This may take 3-5 minutes for first build (downloading and installing NPM packages)..."

# Build backend image
docker build -f Dockerfile.backend -t ${BACKEND_IMAGE}:${VERSION} -t ${BACKEND_IMAGE}:latest .

if [ $? -eq 0 ]; then
    print_success "Backend image built successfully"
else
    print_error "Failed to build backend image"
    exit 1
fi

print_status "Building Healthcare Frontend Image..."
echo "Building: ${FRONTEND_IMAGE}:${VERSION}"
print_info "⏳ Frontend build includes React compilation and optimization..."

# Build frontend image
docker build -f Dockerfile.frontend -t ${FRONTEND_IMAGE}:${VERSION} -t ${FRONTEND_IMAGE}:latest .

if [ $? -eq 0 ]; then
    print_success "Frontend image built successfully"
else
    print_error "Failed to build frontend image"
    exit 1
fi

print_status "Pushing images to Docker Hub..."

# Push backend image
print_status "Pushing backend image..."
docker push ${BACKEND_IMAGE}:${VERSION}
docker push ${BACKEND_IMAGE}:latest

if [ $? -eq 0 ]; then
    print_success "Backend image pushed successfully"
else
    print_error "Failed to push backend image"
    exit 1
fi

# Push frontend image
print_status "Pushing frontend image..."
docker push ${FRONTEND_IMAGE}:${VERSION}
docker push ${FRONTEND_IMAGE}:latest

if [ $? -eq 0 ]; then
    print_success "Frontend image pushed successfully"
else
    print_error "Failed to push frontend image"
    exit 1
fi

print_success "All images built and pushed successfully!"
echo ""
echo "📋 Summary:"
echo "✅ Backend Image: ${BACKEND_IMAGE}:${VERSION}"
echo "✅ Frontend Image: ${FRONTEND_IMAGE}:${VERSION}"
echo "✅ NPM Dependencies: Automatically installed during build"
echo "✅ Docker Registry: Available on Docker Hub"
echo ""
echo "⏱️ Build Time Information:"
echo "• First build: 5-8 minutes (downloads base images + NPM packages)"
echo "• Subsequent builds: 2-3 minutes (uses Docker layer caching)"
echo ""
echo "🔄 Next Steps:"
echo "1. The Kubernetes deployment should now be able to pull the images"
echo "2. Deploy to EKS: ./scripts/deploy-to-eks.sh"
echo "3. Check pod status: kubectl get pods -n healthcare"
echo "4. If pods are still failing, restart the deployment:"
echo "   kubectl rollout restart deployment/healthcare-backend -n healthcare"
echo ""
echo "🛠️ Troubleshooting:"
echo "• If build fails: Check Docker daemon is running"
echo "• If push fails: Verify Docker Hub login with 'docker login'"
echo "• If NPM errors: Docker will show detailed logs during build"
echo ""
echo "🎉 Stage 1 Docker images are now available on Docker Hub!"
