#!/bin/bash

# Health Care Management System - Architecture Diagram Generator Script
# This script automates the setup and generation of architecture diagrams

set -e  # Exit on any error

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

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Main function
main() {
    echo "🎨 Health Care Management System - Architecture Diagram Generator"
    echo "=================================================================="
    echo ""
    
    # Check if we're in the right directory
    if [[ ! -f "Architecture-Diagram-Generator.py" ]]; then
        print_error "Architecture-Diagram-Generator.py not found!"
        print_error "Please run this script from the Project-Docs directory"
        exit 1
    fi
    
    print_status "Starting architecture diagram generation process..."
    
    # Step 1: Check system dependencies
    print_status "Checking system dependencies..."
    
    if ! command_exists python3; then
        print_error "Python 3 is not installed. Please install it first:"
        echo "sudo apt update && sudo apt install python3 python3-pip python3-venv"
        exit 1
    fi
    
    if ! command_exists pip3; then
        print_error "pip3 is not installed. Please install it first:"
        echo "sudo apt install python3-pip"
        exit 1
    fi
    
    if ! command_exists dot; then
        print_warning "Graphviz is not installed. Installing now..."
        sudo apt update
        sudo apt install -y graphviz graphviz-dev
        print_success "Graphviz installed successfully"
    fi
    
    print_success "System dependencies check completed"
    
    # Step 2: Setup Python virtual environment
    print_status "Setting up Python virtual environment..."
    
    if [[ ! -d "diagram_env" ]]; then
        print_status "Creating virtual environment..."
        python3 -m venv diagram_env
        print_success "Virtual environment created"
    else
        print_status "Virtual environment already exists"
    fi
    
    # Step 3: Activate virtual environment and install dependencies
    print_status "Activating virtual environment and installing dependencies..."
    
    source diagram_env/bin/activate
    
    # Upgrade pip
    pip install --upgrade pip --quiet
    
    # Install required packages
    print_status "Installing diagrams library..."
    pip install diagrams --quiet
    pip install graphviz --quiet
    pip install pillow --quiet
    
    print_success "Python dependencies installed successfully"
    
    # Step 4: Generate diagrams
    print_status "Generating architecture diagrams..."
    
    python3 Architecture-Diagram-Generator.py
    
    # Step 5: Verify generated files
    print_status "Verifying generated files..."
    
    diagrams=(
        "healthcare_architecture.png"
        "healthcare_dataflow.png"
        "healthcare_deployment.png"
    )
    
    all_generated=true
    for diagram in "${diagrams[@]}"; do
        if [[ -f "$diagram" ]]; then
            size=$(du -h "$diagram" | cut -f1)
            print_success "✓ $diagram generated successfully ($size)"
        else
            print_error "✗ $diagram was not generated"
            all_generated=false
        fi
    done
    
    # Step 6: Summary
    echo ""
    echo "📊 Generation Summary"
    echo "===================="
    
    if $all_generated; then
        print_success "All architecture diagrams generated successfully!"
        echo ""
        echo "📁 Generated files:"
        for diagram in "${diagrams[@]}"; do
            if [[ -f "$diagram" ]]; then
                echo "   - $diagram"
            fi
        done
        echo ""
        echo "🔍 To view the diagrams:"
        echo "   - Open the PNG files with any image viewer"
        echo "   - Use: xdg-open healthcare_architecture.png"
        echo ""
        echo "📝 Next steps:"
        echo "   1. Review the generated architecture diagrams"
        echo "   2. Include them in your project documentation"
        echo "   3. Update Project-Tracker.md with completion status"
        echo "   4. Share with your development team"
    else
        print_error "Some diagrams failed to generate. Please check the error messages above."
        exit 1
    fi
    
    # Deactivate virtual environment
    deactivate
}

# Function to clean up generated files
clean() {
    print_status "Cleaning up generated files..."
    rm -f healthcare_architecture.png
    rm -f healthcare_dataflow.png
    rm -f healthcare_deployment.png
    rm -rf diagram_env
    print_success "Cleanup completed"
}

# Function to show help
show_help() {
    echo "Health Care Management System - Architecture Diagram Generator"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  generate    Generate architecture diagrams (default)"
    echo "  clean       Remove generated files and virtual environment"
    echo "  help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Generate diagrams"
    echo "  $0 generate          # Generate diagrams"
    echo "  $0 clean             # Clean up files"
    echo "  $0 help              # Show help"
}

# Parse command line arguments
case "${1:-generate}" in
    "generate")
        main
        ;;
    "clean")
        clean
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        print_error "Unknown option: $1"
        show_help
        exit 1
        ;;
esac
