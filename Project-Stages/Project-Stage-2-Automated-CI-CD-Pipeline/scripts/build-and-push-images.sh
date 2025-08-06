#!/bin/bash

# Healthcare Management System - Stage 2 Docker Image Build and Push Script
# Enhanced Docker build with testing, security scanning, and multi-stage builds

set -e

echo "🚀 Stage 2: Building and Pushing Docker Images"
echo "=============================================="

# Determine script location and set paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAGE_DIR="$(dirname "$SCRIPT_DIR")"
SRC_CODE_DIR="$STAGE_DIR/src-code"

# Configuration
DOCKER_REGISTRY="routeclouds"
BACKEND_IMAGE="${DOCKER_REGISTRY}/healthcare-backend"
FRONTEND_IMAGE="${DOCKER_REGISTRY}/healthcare-frontend"
VERSION="v2.0"
RUN_TESTS=true
RUN_SECURITY_SCAN=true
PUSH_IMAGES=true

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

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-tests)
            RUN_TESTS=false
            shift
            ;;
        --no-security-scan)
            RUN_SECURITY_SCAN=false
            shift
            ;;
        --no-push)
            PUSH_IMAGES=false
            shift
            ;;
        --version)
            VERSION="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --no-tests          Skip running tests before build"
            echo "  --no-security-scan  Skip security scanning"
            echo "  --no-push          Build only, don't push to registry"
            echo "  --version VERSION   Set image version (default: v2.0)"
            echo "  -h, --help         Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if source code directory exists
if [ ! -d "$SRC_CODE_DIR" ]; then
    print_error "Source code directory not found: $SRC_CODE_DIR"
    print_error "Please run this script from the Stage-2 directory"
    exit 1
fi

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Function to check Docker Hub login
check_docker_login() {
    if [ "$PUSH_IMAGES" = false ]; then
        print_info "Skipping Docker Hub login check (--no-push specified)"
        return 0
    fi

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
        print_info "Alternatively, you can:"
        echo "• Use --no-push to build without pushing"
        echo "• Use --help to see all options"
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
            print_info "Run with --no-push to build without pushing"
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
echo "• Backend: Node.js dependencies + testing frameworks (Jest, Supertest)"
echo "• Frontend: React dependencies + testing libraries (Vitest, Testing Library)"
echo "• Multi-stage builds optimize final image size"
echo "• No need to run 'npm install' manually - Docker handles everything!"
echo ""

# Run tests if enabled
if [ "$RUN_TESTS" = true ]; then
    print_status "Running tests before build..."
    
    # Backend tests
    print_status "Running backend tests..."
    cd backend
    if npm test; then
        print_success "Backend tests passed"
    else
        print_error "Backend tests failed"
        exit 1
    fi
    
    # Frontend tests
    print_status "Running frontend tests..."
    cd ../frontend
    if npm test; then
        print_success "Frontend tests passed"
    else
        print_error "Frontend tests failed"
        exit 1
    fi
    
    cd ..
    print_success "All tests passed"
fi

print_status "Building Healthcare Backend Image..."
echo "Building: ${BACKEND_IMAGE}:${VERSION}"
print_info "⏳ This may take 5-8 minutes for first build (includes testing dependencies)..."

# Build backend image with enhanced Dockerfile
docker build -f Dockerfile.backend -t ${BACKEND_IMAGE}:${VERSION} -t ${BACKEND_IMAGE}:latest .

if [ $? -eq 0 ]; then
    print_success "Backend image built successfully"
else
    print_error "Failed to build backend image"
    exit 1
fi

print_status "Building Healthcare Frontend Image..."
echo "Building: ${FRONTEND_IMAGE}:${VERSION}"
print_info "⏳ Frontend build includes React compilation, testing setup, and K8s optimization..."

# Build frontend image with Kubernetes-optimized Dockerfile
docker build -f Dockerfile.frontend.k8s -t ${FRONTEND_IMAGE}:${VERSION} -t ${FRONTEND_IMAGE}:latest .

if [ $? -eq 0 ]; then
    print_success "Frontend image built successfully"
else
    print_error "Failed to build frontend image"
    exit 1
fi

# Run security scanning if enabled
if [ "$RUN_SECURITY_SCAN" = true ]; then
    print_status "Running security scans..."
    
    # Check if trivy is installed
    if command -v trivy >/dev/null 2>&1; then
        print_status "Scanning backend image for vulnerabilities..."
        trivy image --severity HIGH,CRITICAL ${BACKEND_IMAGE}:${VERSION}
        
        print_status "Scanning frontend image for vulnerabilities..."
        trivy image --severity HIGH,CRITICAL ${FRONTEND_IMAGE}:${VERSION}
        
        print_success "Security scans completed"
    else
        print_warning "Trivy not installed, skipping security scan"
        print_warning "Install with: curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin"
    fi
fi

# Push images if enabled
if [ "$PUSH_IMAGES" = true ]; then
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
    
    print_success "All images pushed successfully!"
else
    print_success "Images built successfully (not pushed)"
fi

echo ""
echo "📋 Summary:"
echo "✅ Backend Image: ${BACKEND_IMAGE}:${VERSION}"
echo "✅ Frontend Image: ${FRONTEND_IMAGE}:${VERSION}"
echo "✅ NPM Dependencies: Automatically installed during build"
if [ "$RUN_TESTS" = true ]; then
    echo "✅ Tests: Passed"
fi
if [ "$RUN_SECURITY_SCAN" = true ]; then
    echo "✅ Security Scan: Completed"
fi
if [ "$PUSH_IMAGES" = true ]; then
    echo "✅ Registry: Pushed to Docker Hub"
else
    echo "⏸️  Registry: Not pushed (--no-push used)"
fi
echo ""
echo "⏱️ Build Time Information:"
echo "• First build: 8-12 minutes (includes testing dependencies + security scan)"
echo "• Subsequent builds: 3-5 minutes (uses Docker layer caching)"
echo "• With --no-tests: Reduces build time by 2-3 minutes"
echo ""
echo "🔄 Next Steps:"
if [ "$PUSH_IMAGES" = true ]; then
    echo "1. Deploy with Helm: ./scripts/deploy-healthcare.sh"
    echo "2. Check deployment status: kubectl get pods -n healthcare-system"
    echo "3. Monitor application: kubectl logs -f deployment/healthcare-backend -n healthcare-system"
else
    echo "1. Push images: $0 (without --no-push)"
    echo "2. Then deploy with: ./scripts/deploy-healthcare.sh"
fi
echo ""
echo "🛠️ Troubleshooting:"
echo "• If tests fail: Run 'npm test' locally first"
echo "• If build fails: Check Docker daemon and available disk space"
echo "• If push fails: Verify Docker Hub login with 'docker login'"
echo "• If security scan fails: Install trivy or use --no-security-scan"
echo ""
echo "💡 Pro Tips:"
echo "• Use --no-tests for faster builds during development"
echo "• Use --no-push for local testing without registry"
echo "• Use --version to create custom image tags"
echo ""
echo "🎉 Stage 2 Docker images are ready!"
