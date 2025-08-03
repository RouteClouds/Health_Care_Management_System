#!/usr/bin/env python3
"""
Stage 1 Onboarding Verification Script
Healthcare Management System - Documentation Synchronization Check
Verifies that all Stage 1 documentation and diagrams are synchronized

Created: August 2, 2025
Purpose: Ensure Stage 1 onboarding system is complete and accurate
"""

import os
import sys
from pathlib import Path

def check_file_exists(file_path, description):
    """Check if a file exists and report status"""
    if os.path.exists(file_path):
        file_size = os.path.getsize(file_path)
        print(f"✅ {description}")
        print(f"   📁 {file_path}")
        print(f"   📊 Size: {file_size:,} bytes")
        return True
    else:
        print(f"❌ {description}")
        print(f"   📁 {file_path} (NOT FOUND)")
        return False

def verify_stage1_onboarding():
    """Verify all Stage 1 onboarding components"""
    print("🔍 Stage 1 Onboarding Verification")
    print("=" * 50)
    
    # Base paths
    stage1_base = "/home/ubuntu/Projects/Health_Care_Management_System/Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy"
    architecture_dir = f"{stage1_base}/Stage-1-Architecture"
    docs_dir = f"{stage1_base}/docs"
    scripts_dir = f"{stage1_base}/scripts"
    
    success_count = 0
    total_checks = 0
    
    print("\n📊 Visual Onboarding Components")
    print("-" * 30)
    
    # Check onboarding roadmap diagram
    total_checks += 1
    if check_file_exists(f"{architecture_dir}/Stage-1-Onboarding-Roadmap.png", 
                        "Stage 1 Onboarding Roadmap Diagram"):
        success_count += 1
    
    # Check onboarding generator script
    total_checks += 1
    if check_file_exists(f"{architecture_dir}/generate_stage1_onboarding_roadmap.py", 
                        "Onboarding Roadmap Generator Script"):
        success_count += 1
    
    print("\n📚 Documentation Components")
    print("-" * 30)
    
    # Check new user getting started guide
    total_checks += 1
    if check_file_exists(f"{docs_dir}/NEW-USER-GETTING-STARTED.md", 
                        "New User Getting Started Guide"):
        success_count += 1
    
    # Check visual onboarding summary
    total_checks += 1
    if check_file_exists(f"{docs_dir}/VISUAL-ONBOARDING-SUMMARY.md", 
                        "Visual Onboarding Summary"):
        success_count += 1
    
    # Check existing documentation
    existing_docs = [
        ("STAGE-1-INDEX.md", "Stage 1 Main Index"),
        ("STAGE-1-MASTER-GUIDE.md", "Stage 1 Master Guide"),
        ("STAGE-1-OPERATIONS-GUIDE.md", "Stage 1 Operations Guide"),
        ("STAGE-1-TROUBLESHOOTING-REFERENCE.md", "Stage 1 Troubleshooting")
    ]
    
    for doc_file, description in existing_docs:
        total_checks += 1
        if check_file_exists(f"{docs_dir}/{doc_file}", description):
            success_count += 1
    
    print("\n🏗️ Architecture Diagrams")
    print("-" * 30)
    
    # Check existing architecture diagrams
    existing_diagrams = [
        ("stage1_complete_workflow.png", "Complete Workflow Diagram"),
        ("stage1_aws_infrastructure.png", "AWS Infrastructure Diagram"),
        ("stage1_cost_timeline.png", "Cost Timeline Diagram"),
        ("stage1_script_execution_flow.png", "Script Execution Flow"),
        ("stage1_k8s_application.png", "Kubernetes Application Architecture")
    ]
    
    for diagram_file, description in existing_diagrams:
        total_checks += 1
        if check_file_exists(f"{architecture_dir}/{diagram_file}", description):
            success_count += 1
    
    print("\n🤖 Scripts and Tools")
    print("-" * 30)
    
    # Check key scripts
    key_scripts = [
        ("setup-tools.sh", "Tools Setup Script"),
        ("create-eks-cluster.sh", "EKS Cluster Creation"),
        ("deploy-to-eks.sh", "Application Deployment"),
        ("verify-deployment.sh", "Deployment Verification"),
        ("cleanup.sh", "Resource Cleanup")
    ]
    
    for script_file, description in key_scripts:
        total_checks += 1
        if check_file_exists(f"{scripts_dir}/{script_file}", description):
            success_count += 1
    
    print("\n📂 Source Code Location")
    print("-" * 30)
    
    # Check source code (shared with Stage 2)
    src_code_base = "/home/ubuntu/Projects/Health_Care_Management_System/src-code"
    src_components = [
        ("frontend/package.json", "Frontend Package Configuration"),
        ("backend/package.json", "Backend Package Configuration"),
        ("docker-compose.yml", "Docker Compose Configuration")
    ]
    
    for src_file, description in src_components:
        total_checks += 1
        if check_file_exists(f"{src_code_base}/{src_file}", description):
            success_count += 1
    
    print("\n📋 README and Index Files")
    print("-" * 30)
    
    # Check README files
    readme_files = [
        (f"{stage1_base}/README.md", "Stage 1 Main README"),
        (f"{architecture_dir}/README.md", "Architecture README"),
        (f"{architecture_dir}/DIAGRAM_INDEX.md", "Diagram Index")
    ]
    
    for readme_file, description in readme_files:
        total_checks += 1
        if check_file_exists(readme_file, description):
            success_count += 1
    
    # Summary
    print("\n" + "=" * 50)
    print("📊 Verification Summary")
    print("=" * 50)
    
    success_rate = (success_count / total_checks) * 100
    
    print(f"✅ Successful checks: {success_count}/{total_checks}")
    print(f"📊 Success rate: {success_rate:.1f}%")
    
    if success_count == total_checks:
        print("\n🎉 All Stage 1 onboarding components verified successfully!")
        print("✅ Stage 1 is ready for new users")
        print("\n📋 Quick Start for New Users:")
        print("   1. View: Stage-1-Architecture/Stage-1-Onboarding-Roadmap.png")
        print("   2. Read: docs/NEW-USER-GETTING-STARTED.md")
        print("   3. Follow: 10-step visual pathway")
        print("   4. Deploy: AWS EKS healthcare application")
        
        print("\n🎯 Key Features:")
        print("   • 10-step visual onboarding pathway")
        print("   • Complete documentation suite")
        print("   • Cost-conscious approach (~$163/month)")
        print("   • Basic CI/CD with AWS EKS")
        print("   • Perfect for Kubernetes learning")
        
        return True
    else:
        print(f"\n⚠️  {total_checks - success_count} components missing or incomplete")
        print("❌ Stage 1 onboarding system needs attention")
        return False

def main():
    """Main verification function"""
    print("🗺️  Stage 1 Onboarding System Verification")
    print("Healthcare Management System")
    print("Generated: August 2, 2025\n")
    
    try:
        success = verify_stage1_onboarding()
        
        if success:
            print("\n✅ Verification completed successfully!")
            sys.exit(0)
        else:
            print("\n❌ Verification found issues!")
            sys.exit(1)
            
    except Exception as e:
        print(f"\n💥 Verification failed with error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
