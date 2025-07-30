#!/usr/bin/env python3
"""
Master Script: Generate All Stage 1 Architecture Diagrams
Health Care Management System - Complete Diagram Suite

This script generates all Stage 1 architecture diagrams:
1. Complete workflow diagrams
2. Script execution flow diagrams  
3. AWS infrastructure diagrams
4. Error handling diagrams
5. Cost optimization diagrams

Usage:
    python generate_all_diagrams.py

Requirements:
    pip install -r requirements.txt
"""

import os
import sys
import subprocess
import time
from pathlib import Path

def print_banner():
    """Print impressive banner"""
    banner = """
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                                                                              ║
    ║               🏥 HEALTH CARE MANAGEMENT SYSTEM 🏥                           ║
    ║                                                                              ║
    ║                    📊 STAGE 1 ARCHITECTURE DIAGRAMS 📊                     ║
    ║                                                                              ║
    ║                        🎨 Diagram as Code Generator 🎨                     ║
    ║                                                                              ║
    ╚══════════════════════════════════════════════════════════════════════════════╝
    """
    print(banner)

def check_requirements():
    """Check if required packages are installed"""
    print("🔍 Checking requirements...")
    
    try:
        import diagrams
        # Try to get version, fallback to "installed" if not available
        try:
            version = diagrams.__version__
        except AttributeError:
            version = "installed"
        print(f"✅ diagrams: {version}")
    except ImportError:
        print("❌ diagrams not found. Installing...")
        subprocess.run([sys.executable, "-m", "pip", "install", "diagrams"], check=True)
        print("✅ diagrams installed successfully")

    try:
        import PIL
        print(f"✅ Pillow: {PIL.__version__}")
    except ImportError:
        print("❌ Pillow not found. Installing...")
        subprocess.run([sys.executable, "-m", "pip", "install", "Pillow"], check=True)
        print("✅ Pillow installed successfully")
    
    print("✅ All requirements satisfied")
    print("🎨 Generating high-resolution PNG diagrams with latest AWS/K8s icons...")

def run_diagram_script(script_name, description):
    """Run a diagram generation script"""
    print(f"\n🎨 Generating {description}...")
    print(f"📄 Running: {script_name}")
    
    start_time = time.time()
    
    try:
        # Import and run the script
        if script_name == "stage1_workflow_diagram.py":
            from stage1_workflow_diagram import create_stage1_workflow_diagram, create_cost_breakdown_diagram
            create_stage1_workflow_diagram()
            create_cost_breakdown_diagram()
            
        elif script_name == "stage1_script_flow_diagram.py":
            from stage1_script_flow_diagram import create_script_execution_flow, create_error_handling_diagram
            create_script_execution_flow()
            create_error_handling_diagram()
            
        elif script_name == "stage1_aws_architecture_diagram.py":
            from stage1_aws_architecture_diagram import create_aws_infrastructure_diagram, create_kubernetes_application_diagram, create_cost_optimization_diagram
            create_aws_infrastructure_diagram()
            create_kubernetes_application_diagram()
            create_cost_optimization_diagram()
        
        end_time = time.time()
        duration = end_time - start_time
        
        print(f"✅ {description} completed in {duration:.2f} seconds")
        return True
        
    except Exception as e:
        print(f"❌ Error generating {description}: {str(e)}")
        return False

def list_generated_files():
    """List all generated diagram files"""
    print("\n📁 Generated Diagram Files:")
    print("=" * 80)
    
    current_dir = Path(".")
    png_files = list(current_dir.glob("*.png"))
    
    if png_files:
        for i, file in enumerate(sorted(png_files), 1):
            file_size = file.stat().st_size / 1024  # Size in KB
            print(f"{i:2d}. {file.name:<40} ({file_size:.1f} KB)")
    else:
        print("No PNG files found in current directory")
    
    print("=" * 80)

def create_diagram_index():
    """Create an index file describing all diagrams"""
    index_content = """# 📊 Stage 1 Architecture Diagrams Index
## Health Care Management System - Complete Diagram Suite

### 🎯 Overview
This directory contains comprehensive architecture diagrams for Stage 1 of the Health Care Management System deployment. All diagrams are generated using Python Diagram as Code for consistency and maintainability.

---

## 🖼️ Diagram Catalog

### **1. Complete Workflow Diagrams**
- **`stage1_complete_workflow.png`** - End-to-end deployment workflow
- **`stage1_cost_timeline.png`** - Cost breakdown and timeline

### **2. Script Execution Flow Diagrams**  
- **`stage1_script_execution_flow.png`** - Detailed script execution workflow
- **`stage1_error_handling.png`** - Error handling and troubleshooting

### **3. AWS Infrastructure Diagrams**
- **`stage1_aws_infrastructure.png`** - Complete AWS infrastructure
- **`stage1_k8s_application.png`** - Kubernetes application architecture
- **`stage1_cost_optimization.png`** - Cost optimization strategies

---

## 🎨 Diagram Generation

### **Requirements**
```bash
pip install -r requirements.txt
```

### **Generate All Diagrams**
```bash
python generate_all_diagrams.py
```

### **Generate Individual Diagrams**
```bash
python stage1_workflow_diagram.py
python stage1_script_flow_diagram.py  
python stage1_aws_architecture_diagram.py
```

---

## 📋 Diagram Details

### **🔧 Workflow Diagrams**
- **Purpose**: Show complete deployment and destruction process
- **Audience**: DevOps engineers, system administrators
- **Key Features**: Phase-by-phase breakdown, script integration, cost awareness

### **⚙️ Script Flow Diagrams**
- **Purpose**: Detailed script execution and error handling
- **Audience**: Developers, troubleshooting teams
- **Key Features**: Decision points, error paths, validation steps

### **🏗️ Infrastructure Diagrams**
- **Purpose**: AWS architecture and Kubernetes deployment
- **Audience**: Cloud architects, security teams
- **Key Features**: Auto-created resources, security groups, cost optimization

---

## 🎯 Usage Guidelines

### **For Documentation**
- Use workflow diagrams in setup guides
- Include script flow diagrams in troubleshooting docs
- Reference infrastructure diagrams in architecture reviews

### **For Presentations**
- High-resolution PNG format suitable for presentations
- Clear labeling and color coding for easy understanding
- Professional layout following AWS architecture standards

### **For Training**
- Step-by-step visual guides for team onboarding
- Error handling scenarios for troubleshooting training
- Cost optimization strategies for budget planning

---

## 🔄 Maintenance

### **Updating Diagrams**
1. Modify the Python diagram scripts
2. Run `python generate_all_diagrams.py`
3. Commit updated PNG files to version control

### **Adding New Diagrams**
1. Create new Python script following existing patterns
2. Add to `generate_all_diagrams.py`
3. Update this index file

---

## 📊 Diagram Statistics

- **Total Diagrams**: 7 comprehensive diagrams
- **Generation Time**: ~30 seconds for all diagrams
- **File Format**: PNG (high resolution)
- **Total Size**: ~2-3 MB for complete set
- **Last Updated**: Generated automatically

---

## 🎉 Benefits

### **✅ Consistency**
- All diagrams follow same visual standards
- Automated generation ensures accuracy
- Version controlled with code changes

### **✅ Maintainability**  
- Easy to update when architecture changes
- Code-based generation allows bulk updates
- Clear separation of concerns

### **✅ Professional Quality**
- High-resolution output suitable for documentation
- AWS-standard icons and layouts
- Clear visual hierarchy and flow

**Your Stage 1 architecture is now fully documented with professional diagrams!** 🏥📊✨
"""
    
    with open("DIAGRAM_INDEX.md", "w") as f:
        f.write(index_content)
    
    print("📋 Created DIAGRAM_INDEX.md with complete documentation")

def main():
    """Main execution function"""
    print_banner()
    
    # Check requirements
    check_requirements()
    
    # List of diagram scripts to run
    diagram_scripts = [
        ("stage1_workflow_diagram.py", "Complete Workflow Diagrams"),
        ("stage1_script_flow_diagram.py", "Script Execution Flow Diagrams"),
        ("stage1_aws_architecture_diagram.py", "AWS Infrastructure Diagrams")
    ]
    
    # Track success/failure
    successful = 0
    total = len(diagram_scripts)
    
    print(f"\n🚀 Starting generation of {total} diagram sets...")
    
    # Generate each diagram set
    for script, description in diagram_scripts:
        if run_diagram_script(script, description):
            successful += 1
    
    # List generated files
    list_generated_files()
    
    # Create documentation index
    create_diagram_index()
    
    # Final summary
    print(f"\n🎉 Diagram Generation Complete!")
    print(f"✅ Successfully generated: {successful}/{total} diagram sets")
    
    if successful == total:
        print("🏆 All diagrams generated successfully!")
        print("🖼️  Format: High-resolution PNG with latest AWS/Kubernetes icons")
        print("📁 Location: Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/Stage-1-Architecture/")
        print("📖 See DIAGRAM_INDEX.md for complete documentation")
    else:
        print(f"⚠️  {total - successful} diagram set(s) failed to generate")
        print("🔍 Check error messages above for troubleshooting")
    
    print("\n" + "="*80)
    print("🎨 Stage 1 Architecture Diagrams - Ready for Documentation! 🎨")
    print("="*80)

if __name__ == "__main__":
    main()
