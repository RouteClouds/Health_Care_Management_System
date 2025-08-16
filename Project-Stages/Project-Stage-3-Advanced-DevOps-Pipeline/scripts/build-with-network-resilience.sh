#!/bin/bash

echo "🔧 Network-Resilient Docker Build Script"
echo "========================================"

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
ECR_REGISTRY="${ECR_REGISTRY:-867344452513.dkr.ecr.us-east-1.amazonaws.com}"
IMAGE_TAG="${IMAGE_TAG:-$(git rev-parse HEAD)}"
BUILD_DATE="${BUILD_DATE:-$(date +%s)}"

# Function to test network connectivity
test_network() {
    log_info "Testing network connectivity..."
    
    # Test npm registry
    if curl -s --connect-timeout 10 https://registry.npmjs.org/ > /dev/null; then
        log_success "npm registry accessible"
        return 0
    else
        log_warning "npm registry not accessible"
        return 1
    fi
}

# Function to configure Docker for resilience
configure_docker() {
    log_info "Configuring Docker for network resilience..."
    
    # Create Docker daemon configuration
    sudo mkdir -p /etc/docker
    cat > /tmp/daemon.json << 'EOF'
{
  "max-concurrent-downloads": 2,
  "max-concurrent-uploads": 2,
  "registry-mirrors": [
    "https://mirror.gcr.io",
    "https://dockerhub.azk8s.cn"
  ],
  "insecure-registries": [],
  "debug": false,
  "experimental": false,
  "default-runtime": "runc",
  "storage-driver": "overlay2"
}
EOF
    
    sudo mv /tmp/daemon.json /etc/docker/daemon.json
    sudo systemctl restart docker
    sleep 15
    
    log_success "Docker configured for network resilience"
}

# Function to build with retries
build_with_retry() {
    local dockerfile=$1
    local image_name=$2
    local build_args=$3
    local max_attempts=3
    
    log_info "Building $image_name with retry mechanism..."
    
    for attempt in $(seq 1 $max_attempts); do
        log_info "Build attempt $attempt/$max_attempts for $image_name..."
        
        # Build command with network resilience
        if docker build \
            --network=host \
            --build-arg BUILD_DATE="$BUILD_DATE" \
            --build-arg COMMIT_SHA="$IMAGE_TAG" \
            $build_args \
            -f "$dockerfile" \
            -t "$image_name:$IMAGE_TAG" \
            -t "$image_name:latest" \
            .; then
            log_success "✅ $image_name build successful on attempt $attempt"
            return 0
        else
            log_error "❌ $image_name build failed on attempt $attempt"
            
            if [ $attempt -eq $max_attempts ]; then
                log_error "💥 $image_name build failed after $max_attempts attempts"
                return 1
            fi
            
            log_warning "⏳ Waiting 60 seconds before retry..."
            sleep 60
            
            # Clean up failed build artifacts
            docker system prune -f --volumes
        fi
    done
}

# Main execution
main() {
    log_info "Starting network-resilient build process..."
    
    # Test network connectivity
    if ! test_network; then
        log_warning "Network issues detected, applying resilience measures..."
        configure_docker
    fi
    
    # Build frontend
    log_info "Building frontend image..."
    if ! build_with_retry "Dockerfile.frontend" \
        "$ECR_REGISTRY/healthcare-frontend-stage3" \
        "--build-arg VITE_API_BASE_URL=/api --build-arg VITE_APP_NAME=\"RouteClouds Health Platform\" --build-arg VITE_APP_VERSION=\"1.0.0\""; then
        log_error "Frontend build failed"
        exit 1
    fi
    
    # Build backend
    log_info "Building backend image..."
    if ! build_with_retry "Dockerfile.backend" \
        "$ECR_REGISTRY/healthcare-backend-stage3" \
        ""; then
        log_error "Backend build failed"
        exit 1
    fi
    
    # Verify images
    log_info "Verifying built images..."
    docker images | grep healthcare
    
    log_success "🎉 All images built successfully!"
    
    # Push images if ECR login is available
    if docker info | grep -q "Username"; then
        log_info "Pushing images to ECR..."
        
        docker push "$ECR_REGISTRY/healthcare-frontend-stage3:$IMAGE_TAG"
        docker push "$ECR_REGISTRY/healthcare-frontend-stage3:latest"
        docker push "$ECR_REGISTRY/healthcare-backend-stage3:$IMAGE_TAG"
        docker push "$ECR_REGISTRY/healthcare-backend-stage3:latest"
        
        log_success "✅ All images pushed to ECR"
    else
        log_warning "ECR not logged in, skipping push"
    fi
}

# Execute main function
main "$@"
