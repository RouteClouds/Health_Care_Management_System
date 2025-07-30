#!/usr/bin/env python3
"""
Test script to verify all imports work correctly
"""

def test_imports():
    print("🧪 Testing diagram imports...")
    
    try:
        from diagrams import Diagram, Cluster, Edge
        print("✅ Core diagrams imports successful")
    except ImportError as e:
        print(f"❌ Core diagrams import failed: {e}")
        return False
    
    try:
        from diagrams.onprem.client import Users, Client
        from diagrams.onprem.compute import Server
        from diagrams.onprem.database import PostgreSQL
        from diagrams.onprem.inmemory import Redis
        from diagrams.onprem.network import Nginx
        from diagrams.onprem.monitoring import Grafana, Prometheus
        print("✅ OnPrem imports successful")
    except ImportError as e:
        print(f"❌ OnPrem import failed: {e}")
        return False
    
    try:
        from diagrams.programming.framework import React
        from diagrams.programming.language import JavaScript, TypeScript, Nodejs
        print("✅ Programming imports successful")
    except ImportError as e:
        print(f"❌ Programming import failed: {e}")
        return False
    
    try:
        from diagrams.aws.compute import EC2, ECS
        from diagrams.aws.database import RDS, ElastiCache
        from diagrams.aws.network import CloudFront, ELB, Route53
        from diagrams.aws.storage import S3
        from diagrams.aws.security import IAM
        print("✅ AWS imports successful")
    except ImportError as e:
        print(f"❌ AWS import failed: {e}")
        return False
    
    try:
        from diagrams.generic.device import Mobile, Tablet
        from diagrams.generic.storage import Storage
        from diagrams.generic.compute import Rack
        print("✅ Generic imports successful")
    except ImportError as e:
        print(f"❌ Generic import failed: {e}")
        return False
    
    print("🎉 All imports successful!")
    return True

def test_simple_diagram():
    print("\n🎨 Testing simple diagram creation...")
    
    try:
        from diagrams import Diagram
        from diagrams.onprem.compute import Server
        
        with Diagram("Test Diagram", show=False, filename="test_diagram"):
            server = Server("Test Server")
        
        import os
        if os.path.exists("test_diagram.png"):
            print("✅ Simple diagram created successfully")
            os.remove("test_diagram.png")  # Clean up
            return True
        else:
            print("❌ Diagram file not created")
            return False
            
    except Exception as e:
        print(f"❌ Diagram creation failed: {e}")
        return False

if __name__ == "__main__":
    print("🔍 Diagrams Library Test Suite")
    print("=" * 40)
    
    imports_ok = test_imports()
    
    if imports_ok:
        diagram_ok = test_simple_diagram()
        
        if diagram_ok:
            print("\n🎉 All tests passed! Ready to generate architecture diagrams.")
        else:
            print("\n⚠️  Imports work but diagram creation failed. Check Graphviz installation.")
    else:
        print("\n❌ Import tests failed. Please check your diagrams installation.")
        print("\nTry: pip install --upgrade diagrams")
