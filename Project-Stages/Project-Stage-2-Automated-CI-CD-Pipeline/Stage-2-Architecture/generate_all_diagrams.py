#!/usr/bin/env python3
"""
Stage 2 Complete Architecture Diagram Generator
Healthcare Management System - All Diagrams
Tech Stack: Jest + Selenium + SonarQube + Trivy
"""

import subprocess
import sys
import os

def check_dependencies():
    """Check if required Python packages are installed"""
    required_packages = ['matplotlib', 'numpy']
    missing_packages = []
    
    for package in required_packages:
        try:
            __import__(package)
        except ImportError:
            missing_packages.append(package)
    
    if missing_packages:
        print("❌ Missing required packages:")
        for package in missing_packages:
            print(f"   • {package}")
        print("\n📦 Installing missing packages...")
        
        for package in missing_packages:
            try:
                subprocess.check_call([sys.executable, "-m", "pip", "install", package])
                print(f"✅ Installed {package}")
            except subprocess.CalledProcessError:
                print(f"❌ Failed to install {package}")
                return False
    
    return True

def generate_diagrams():
    """Generate all Stage 2 architecture diagrams"""
    print("🎨 Generating Stage 2 Architecture Diagrams...")
    print("=" * 60)
    
    # Check dependencies first
    if not check_dependencies():
        print("❌ Failed to install required dependencies")
        return False
    
    # Import after ensuring dependencies are available
    try:
        from generate_stage2_architecture import main as generate_arch
        from generate_pipeline_flow import main as generate_flow
    except ImportError as e:
        print(f"❌ Import error: {e}")
        return False
    
    # Generate architecture diagram
    print("\n1️⃣ Generating main architecture diagram...")
    try:
        generate_arch()
        print("✅ Main architecture diagram completed")
    except Exception as e:
        print(f"❌ Error generating architecture diagram: {e}")
        return False
    
    # Generate pipeline flow diagram
    print("\n2️⃣ Generating pipeline flow diagram...")
    try:
        generate_flow()
        print("✅ Pipeline flow diagram completed")
    except Exception as e:
        print(f"❌ Error generating pipeline flow diagram: {e}")
        return False
    
    return True

def create_readme():
    """Create README file for the diagrams"""
    readme_content = """# 🏗️ Stage 2 Architecture Diagrams

## 📊 Healthcare Management System - Automated CI/CD Pipeline

### **🎯 Selected Technology Stack**
- **Unit Testing**: Jest (mature, stable, excellent documentation)
- **E2E Testing**: Selenium WebDriver (cross-browser, enterprise-grade)
- **Code Quality**: SonarQube (industry standard, compliance-ready)
- **Security**: Trivy (fast, comprehensive vulnerability scanning)

---

## 📁 Generated Diagrams

### **1. Stage-2-Architecture-Diagram.png**
**Complete system architecture overview**

**Features**:
- ✅ Complete CI/CD pipeline visualization
- ✅ AWS EKS infrastructure details
- ✅ Technology stack integration
- ✅ Security and quality gates
- ✅ Deployment environments
- ✅ Monitoring and observability
- ✅ Cost and performance metrics

**Sections**:
- Source code & version control (GitHub)
- CI/CD pipeline (GitHub Actions)
- Quality & security tools (SonarQube, Trivy)
- Container registry (Docker Hub)
- AWS infrastructure (EKS cluster)
- Deployment environments (Dev/Staging/Prod)
- Monitoring & alerts

### **2. Stage-2-Pipeline-Flow-Diagram.png**
**Detailed CI/CD workflow process**

**Features**:
- ✅ Step-by-step pipeline process
- ✅ Quality gates and decision points
- ✅ Timing and performance metrics
- ✅ Success/failure paths
- ✅ External service integrations
- ✅ Technology stack details

**Pipeline Stages**:
1. 🚀 Pipeline Trigger (< 1 min)
2. 🛡️ Security Analysis (2-3 min) - Trivy
3. 🧪 Unit Testing (3-4 min) - Jest
4. 📊 Code Quality (2-3 min) - SonarQube
5. 🐳 Container Build (4-5 min) - Docker
6. 🔍 Image Security (2-3 min) - Trivy
7. 🌐 E2E Testing (5-8 min) - Selenium
8. 🚀 Deployment (3-5 min) - EKS

---

## 🎯 Diagram Specifications

### **Technical Details**
- **Format**: High-resolution PNG (300 DPI)
- **Dimensions**: Optimized for documentation and presentations
- **Color Scheme**: Professional healthcare industry colors
- **Text**: No overlapping, clear readability
- **Icons**: Modern, industry-standard representations

### **Quality Features**
- ✅ No text overlap or crowding
- ✅ Clear visual hierarchy
- ✅ Consistent color coding
- ✅ Professional appearance
- ✅ Scalable for different uses
- ✅ Print-ready quality

---

## 🚀 Usage Instructions

### **Viewing Diagrams**
```bash
# View architecture diagram
open Stage-2-Architecture-Diagram.png

# View pipeline flow
open Stage-2-Pipeline-Flow-Diagram.png
```

### **Regenerating Diagrams**
```bash
# Generate all diagrams
python3 generate_all_diagrams.py

# Generate specific diagrams
python3 generate_stage2_architecture.py
python3 generate_pipeline_flow.py
```

### **Requirements**
- Python 3.7+
- matplotlib
- numpy

---

## 📊 Architecture Benefits

### **🎯 Stage 2 Improvements Over Stage 1**
- **Automated Testing**: Jest unit tests + Selenium E2E tests
- **Quality Gates**: SonarQube code quality enforcement
- **Security Scanning**: Trivy vulnerability detection
- **Cross-Browser Testing**: Chrome, Firefox, Safari, Edge support
- **Compliance Ready**: Healthcare industry standards
- **Cost Optimized**: ~$63/month total infrastructure cost

### **🔧 Enterprise Features**
- **Scalability**: Auto-scaling EKS cluster (1-4 nodes)
- **Reliability**: 99.5% pipeline success rate target
- **Security**: Comprehensive vulnerability scanning
- **Monitoring**: Real-time pipeline and application health
- **Compliance**: SOC 2, HIPAA-ready architecture

---

## 📈 Performance Metrics

### **Pipeline Performance**
- **Total Time**: 15-25 minutes (full pipeline)
- **Success Rate**: >95% target
- **Test Coverage**: >80% requirement
- **Security**: 0 critical vulnerabilities
- **Quality**: A-rating requirement

### **Infrastructure Metrics**
- **Availability**: 99.9% uptime target
- **Scalability**: 1-4 nodes auto-scaling
- **Cost**: ~$63/month optimized
- **Recovery**: <30 minutes MTTR

---

**Generated**: August 2025  
**Version**: Stage 2 v2.0  
**Tech Stack**: Jest + Selenium + SonarQube + Trivy  
**Infrastructure**: AWS EKS (us-east-1)
"""
    
    with open('README.md', 'w') as f:
        f.write(readme_content)
    
    print("📝 README.md created with diagram documentation")

def main():
    """Main function to generate all diagrams and documentation"""
    print("🏗️ Stage 2 Architecture Diagram Generator")
    print("Healthcare Management System")
    print("Tech Stack: Jest + Selenium + SonarQube + Trivy")
    print("=" * 60)
    
    # Generate diagrams
    if generate_diagrams():
        print("\n📝 Creating documentation...")
        create_readme()
        
        print("\n🎉 All diagrams generated successfully!")
        print("\n📁 Generated files:")
        print("   • Stage-2-Architecture-Diagram.png")
        print("   • Stage-2-Pipeline-Flow-Diagram.png")
        print("   • README.md")
        
        print("\n🎯 Diagram features:")
        print("   ✅ High-resolution PNG format (300 DPI)")
        print("   ✅ No overlapping text")
        print("   ✅ Professional healthcare color scheme")
        print("   ✅ Complete technology stack visualization")
        print("   ✅ Detailed pipeline workflow")
        print("   ✅ AWS infrastructure details")
        print("   ✅ Security and quality gates")
        print("   ✅ Performance metrics included")
        
        print("\n📊 Your selected stack is fully visualized:")
        print("   🧪 Jest (Unit Testing)")
        print("   🌐 Selenium WebDriver (E2E Testing)")
        print("   📊 SonarQube (Code Quality)")
        print("   🛡️ Trivy (Security Scanning)")
        
        return True
    else:
        print("\n❌ Failed to generate diagrams")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
