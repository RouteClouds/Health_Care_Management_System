#!/usr/bin/env python3
"""
Simple test to check if we can generate basic diagrams
"""

try:
    from diagrams import Diagram, Edge
    from diagrams.aws.compute import EKS
    from diagrams.aws.network import ELB
    from diagrams.onprem.client import Users
    
    print("✅ All imports successful")
    
    # Try to create a very simple diagram
    with Diagram("Simple Test", show=False, filename="simple_test", direction="LR"):
        users = Users("Users")
        lb = ELB("Load Balancer") 
        eks = EKS("EKS")
        
        users >> lb >> eks
    
    print("✅ Simple diagram created successfully")
    
    # Check if file exists
    import os
    if os.path.exists("simple_test.png"):
        print("✅ PNG file generated successfully")
        file_size = os.path.getsize("simple_test.png")
        print(f"📊 File size: {file_size} bytes")
    else:
        print("❌ PNG file not found")
        
except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc()
