# 🐍 Python Virtual Environment Setup Guide

## 📋 Overview

This guide provides step-by-step instructions for creating and managing Python virtual environments for the Health Care Management System's Docker architecture diagram generation and other Python-based tools.

---

## 🎯 Why Use Virtual Environments?

### ✅ **Benefits:**
- **Isolation**: Keep project dependencies separate
- **Version Control**: Manage specific package versions
- **Clean System**: Avoid polluting global Python installation
- **Reproducibility**: Ensure consistent environments across systems
- **Conflict Prevention**: Avoid package version conflicts

### 🔧 **Use Cases in Our Project:**
- **Docker Architecture Diagrams**: ASCII diagram generation
- **RC Architecture Diagrams**: Visual architecture diagrams with diagrams library
- **Development Tools**: Testing, linting, and automation scripts

---

## 🚀 Virtual Environment Setup

### **Step 1: Verify Python Installation**

```bash
# Check Python version (should be 3.8+)
python3 --version

# Check pip installation
pip3 --version

# If not installed, install Python and pip
sudo apt update
sudo apt install python3 python3-pip python3-venv
```

### **Step 2: Navigate to Dedicated Python Directory**

```bash
# Navigate to the dedicated Python virtual environment directory
cd /home/ubuntu/Projects/python-venv

# Create the directory if it doesn't exist
mkdir -p /home/ubuntu/Projects/python-venv

# Verify you're in the correct location
pwd
# Should show: /home/ubuntu/Projects/python-venv
```

### **Step 3: Create Virtual Environment**

```bash
# Create virtual environment in the dedicated directory
python3 -m venv healthcare-diagrams

# Verify creation
ls -la healthcare-diagrams/
# Should show: bin/ include/ lib/ pyvenv.cfg
```

### **Step 4: Activate Virtual Environment**

```bash
# Activate the virtual environment
source healthcare-diagrams/bin/activate

# Verify activation (prompt should change)
# You should see: (healthcare-diagrams) ubuntu@hostname:~/Projects/python-venv$

# Verify Python path
which python
# Should show: /home/ubuntu/Projects/python-venv/healthcare-diagrams/bin/python
```

### **Step 5: Upgrade pip in Virtual Environment**

```bash
# Upgrade pip to latest version
pip install --upgrade pip

# Verify pip version
pip --version
```

---

## 📦 Package Installation

### **For Docker Architecture Diagrams**

#### **ASCII Version (No Dependencies):**
```bash
# No additional packages needed - uses pure Python!
cd /home/ubuntu/Projects/Health_Care_Management_System/Project-Docs/Images/Docker-Arch
python docker-architecture-ascii.py
```

#### **Professional Visual Version (PNG/PDF/SVG):**
```bash
# Install visual diagram dependencies
pip install matplotlib numpy

# Generate professional visual diagrams
cd /home/ubuntu/Projects/Health_Care_Management_System/Project-Docs/Images/Docker-Arch
export MPLBACKEND=Agg  # For headless servers
python docker-architecture-visual.py
```

### **For RC Architecture Diagrams (Visual)**

```bash
# Install diagrams library for RC architecture diagrams
pip install diagrams

# Install additional dependencies
pip install graphviz pillow

# Test RC architecture diagrams
cd /home/ubuntu/Projects/Health_Care_Management_System/Project-Docs/RC-Health-Care-Mgmt-App-Arch-Diagrams
python Architecture-Diagram-Generator.py
```

### **For Development Tools (Optional)**

```bash
# Install development and testing tools
pip install pytest pytest-cov black flake8 mypy

# Install web development tools
pip install requests beautifulsoup4 selenium

# Install data analysis tools (if needed)
pip install pandas numpy matplotlib
```

---

## 🔧 Virtual Environment Management

### **Daily Usage Commands**

```bash
# Activate virtual environment
source /home/ubuntu/Projects/python-venv/healthcare-diagrams/bin/activate

# Deactivate virtual environment
deactivate

# Check installed packages
pip list

# Check package information
pip show package_name

# Install specific package version
pip install package_name==1.2.3

# Uninstall package
pip uninstall package_name
```

### **Requirements Management**

```bash
# Generate requirements file
pip freeze > requirements.txt

# Install from requirements file
pip install -r requirements.txt

# Update all packages
pip list --outdated
pip install --upgrade package_name
```

---

## 📁 Project Structure with Virtual Environment

```
/home/ubuntu/Projects/
├── python-venv/                    # Dedicated Python virtual environments
│   ├── healthcare-diagrams/       # Healthcare project Python environment
│   │   ├── bin/                    # Executables (python, pip, etc.)
│   │   ├── lib/                    # Installed packages
│   │   └── pyvenv.cfg              # Environment configuration
│   └── activate_healthcare_diagrams.sh  # Quick activation script
├── Health_Care_Management_System/  # Main project (code only)
│   ├── frontend/                   # React frontend
│   ├── backend/                    # Node.js backend
│   ├── Project-Docs/               # Documentation
│   │   ├── docker-architecture-ascii.py    # Docker diagram (no deps)
│   │   ├── RC-Health-Care-Mgmt-App-Arch-Diagrams/
│   │   │   └── Architecture-Diagram-Generator.py  # RC diagrams (needs deps)
│   │   └── PYTHON_VIRTUAL_ENV_SETUP.md     # This guide
│   ├── docker-compose.yml          # Docker configuration
│   └── README.md                   # Project README
```

---

## 🧪 Testing the Setup

### **Test 1: Docker Architecture Diagram**

```bash
# Activate virtual environment
source venv/bin/activate

# Navigate to docs
cd Project-Docs

# Run Docker architecture script (no dependencies needed)
python docker-architecture-ascii.py

# Expected output:
# ✅ ASCII diagram displayed
# ✅ docker-architecture-ascii.txt file created
```

### **Test 2: RC Architecture Diagrams**

```bash
# Install diagrams library
pip install diagrams

# Navigate to RC diagrams directory
cd RC-Health-Care-Mgmt-App-Arch-Diagrams

# Run RC architecture script
python Architecture-Diagram-Generator.py

# Expected output:
# ✅ healthcare_architecture.png created
# ✅ healthcare_dataflow.png created
# ✅ healthcare_deployment.png created
```

### **Test 3: Environment Verification**

```bash
# Check Python version in virtual environment
python --version

# Check installed packages
pip list

# Check virtual environment location
echo $VIRTUAL_ENV
# Should show: /home/ubuntu/Projects/Health_Care_Management_System/venv
```

---

## 🔄 Automation Scripts

### **Quick Activation Script**

Create a convenience script for quick activation:

```bash
# Create activation script
cat > activate_env.sh << 'EOF'
#!/bin/bash
cd /home/ubuntu/Projects/Health_Care_Management_System
source venv/bin/activate
echo "✅ Virtual environment activated!"
echo "📍 Current directory: $(pwd)"
echo "🐍 Python version: $(python --version)"
echo "📦 Installed packages: $(pip list | wc -l) packages"
EOF

# Make executable
chmod +x activate_env.sh

# Usage
./activate_env.sh
```

### **Docker Diagram Generation Script**

```bash
# Create Docker diagram script
cat > generate_docker_diagram.sh << 'EOF'
#!/bin/bash
echo "🐳 Generating Docker Architecture Diagram..."
cd /home/ubuntu/Projects/Health_Care_Management_System
source venv/bin/activate
cd Project-Docs
python docker-architecture-ascii.py
echo "✅ Docker diagram generated successfully!"
EOF

# Make executable
chmod +x generate_docker_diagram.sh

# Usage
./generate_docker_diagram.sh
```

---

## 🛠️ Troubleshooting

### **Common Issues & Solutions**

#### **Issue 1: Virtual Environment Not Activating**
```bash
# Solution: Check if venv directory exists
ls -la venv/

# If missing, recreate
python3 -m venv venv
source venv/bin/activate
```

#### **Issue 2: Package Installation Fails**
```bash
# Solution: Upgrade pip and try again
pip install --upgrade pip
pip install package_name

# Or use --user flag
pip install --user package_name
```

#### **Issue 3: Permission Denied**
```bash
# Solution: Check directory permissions
ls -la venv/
chmod -R 755 venv/

# Or recreate virtual environment
rm -rf venv/
python3 -m venv venv
```

#### **Issue 4: Wrong Python Version**
```bash
# Solution: Specify Python version explicitly
python3.9 -m venv venv
# or
python3.10 -m venv venv
```

---

## 📚 Best Practices

### ✅ **Do's:**
- Always activate virtual environment before working
- Use `requirements.txt` for dependency management
- Keep virtual environment in project root
- Use descriptive names for environments
- Regularly update pip and packages

### ❌ **Don'ts:**
- Don't commit virtual environment to version control
- Don't install packages globally when using venv
- Don't mix system Python with virtual environment
- Don't forget to deactivate when switching projects

---

## 🎯 Quick Reference

### **Essential Commands:**
```bash
# Create virtual environment
python3 -m venv venv

# Activate
source venv/bin/activate

# Deactivate
deactivate

# Install package
pip install package_name

# Generate requirements
pip freeze > requirements.txt

# Install from requirements
pip install -r requirements.txt
```

---

**🎉 Your Python virtual environment is now ready for Docker architecture diagram generation and other Python development tasks!**
