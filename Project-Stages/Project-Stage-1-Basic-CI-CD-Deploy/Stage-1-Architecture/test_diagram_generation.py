#!/usr/bin/env python3
"""
Test Script: Verify Diagram Generation Capability
Health Care Management System - Stage 1 Architecture

This script tests the diagram generation environment and creates a simple test diagram
to verify that all dependencies are working correctly.

Usage:
    python test_diagram_generation.py
"""

import sys
import os
from pathlib import Path

def test_imports():
    """Test if all required packages can be imported"""
    print("🔍 Testing package imports...")
    
    try:
        import diagrams
        # Try to get version, fallback to "installed" if not available
        try:
            version = diagrams.__version__
        except AttributeError:
            version = "installed"
        print(f"✅ diagrams: {version}")
    except ImportError as e:
        print(f"❌ diagrams import failed: {e}")
        return False
    
    try:
        import PIL
        print(f"✅ Pillow: {PIL.__version__}")
    except ImportError as e:
        print(f"❌ Pillow import failed: {e}")
        return False
    
    try:
        # Test specific diagram components
        from diagrams.aws.compute import EKS, EC2
        from diagrams.aws.network import ELB, VPC
        from diagrams.k8s.compute import Pod
        from diagrams.onprem.client import Users
        print("✅ Diagram components imported successfully")
    except ImportError as e:
        print(f"❌ Diagram components import failed: {e}")
        return False
    
    return True

def create_test_diagram():
    """Create a simple test diagram to verify functionality"""
    print("\n🎨 Creating test diagram...")
    
    try:
        from diagrams import Diagram, Cluster, Edge
        from diagrams.aws.compute import EKS
        from diagrams.aws.network import ELB
        from diagrams.k8s.compute import Pod
        from diagrams.onprem.client import Users
        
        with Diagram(
            "Stage 1 Test Diagram",
            filename="Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/Stage-1-Architecture/test_diagram",
            show=False,
            direction="LR"
        ):
            users = Users("Healthcare Users")
            
            with Cluster("AWS EKS"):
                lb = ELB("Load Balancer")
                eks = EKS("EKS Cluster")
                pod = Pod("Healthcare App")
            
            users >> lb >> eks >> pod
        
        # Check if file was created
        test_file = Path("test_diagram.png")
        if test_file.exists():
            file_size = test_file.stat().st_size
            print(f"✅ Test diagram created successfully ({file_size} bytes)")
            
            # Clean up test file
            test_file.unlink()
            print("✅ Test file cleaned up")
            return True
        else:
            print("❌ Test diagram file not found")
            return False
            
    except Exception as e:
        print(f"❌ Test diagram creation failed: {e}")
        return False

def check_environment():
    """Check the environment and provide recommendations"""
    print("\n🔧 Checking environment...")
    
    # Check Python version
    python_version = sys.version_info
    print(f"🐍 Python version: {python_version.major}.{python_version.minor}.{python_version.micro}")
    
    if python_version.major < 3 or (python_version.major == 3 and python_version.minor < 8):
        print("⚠️  Python 3.8+ recommended for best compatibility")
    else:
        print("✅ Python version is compatible")
    
    # Check current directory
    current_dir = Path.cwd()
    print(f"📁 Current directory: {current_dir}")
    
    # Check if we're in the right location
    expected_path = "Stage-1-Architecture"
    if expected_path in str(current_dir):
        print("✅ Running from correct directory")
    else:
        print(f"⚠️  Expected to run from directory containing '{expected_path}'")
    
    # Check write permissions
    try:
        test_file = Path("test_write_permission.tmp")
        test_file.write_text("test")
        test_file.unlink()
        print("✅ Write permissions verified")
    except Exception as e:
        print(f"❌ Write permission test failed: {e}")
        return False
    
    return True

def provide_installation_help():
    """Provide installation instructions if needed"""
    print("\n📦 Installation Help:")
    print("=" * 50)
    print("If packages are missing, install with:")
    print("")
    print("# Install from requirements file")
    print("pip install -r requirements.txt")
    print("")
    print("# Or install individually")
    print("pip install diagrams pillow")
    print("")
    print("# For Ubuntu/Debian, you might also need:")
    print("sudo apt-get update")
    print("sudo apt-get install graphviz")
    print("")
    print("# For enhanced features (optional):")
    print("pip install matplotlib graphviz")

def main():
    """Main test execution"""
    print("🧪 Stage 1 Diagram Generation Test")
    print("=" * 50)
    
    # Test imports
    imports_ok = test_imports()
    
    # Check environment
    env_ok = check_environment()
    
    # Create test diagram if imports work
    if imports_ok:
        diagram_ok = create_test_diagram()
    else:
        diagram_ok = False
    
    # Final summary
    print("\n📊 Test Results Summary:")
    print("=" * 50)
    print(f"Package Imports: {'✅ PASS' if imports_ok else '❌ FAIL'}")
    print(f"Environment Check: {'✅ PASS' if env_ok else '❌ FAIL'}")
    print(f"Diagram Creation: {'✅ PASS' if diagram_ok else '❌ FAIL'}")
    
    if imports_ok and env_ok and diagram_ok:
        print("\n🎉 ALL TESTS PASSED!")
        print("✅ Your environment is ready for diagram generation")
        print("🚀 Run: python generate_all_diagrams.py")
    else:
        print("\n⚠️  SOME TESTS FAILED")
        print("❌ Please resolve issues before generating diagrams")
        provide_installation_help()
    
    print("\n" + "=" * 50)

if __name__ == "__main__":
    main()
