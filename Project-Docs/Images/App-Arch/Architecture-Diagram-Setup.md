# Architecture Diagram Generator - Setup Guide

## 📊 Overview

This guide helps you generate professional architecture diagrams for the Health Care Management System using Python's `diagrams` library with modern technology icons.

## 🎯 Generated Diagrams

The script creates **3 comprehensive diagrams**:

1. **healthcare_architecture.png** - Complete system architecture
2. **healthcare_dataflow.png** - Data flow and API interactions  
3. **healthcare_deployment.png** - Development vs Production deployment

## 🛠️ Prerequisites & Installation

### System Requirements
- **Python 3.8+** installed on Ubuntu 24.04 LTS
- **Graphviz** for diagram rendering
- **Internet connection** for downloading icons

### Step 1: Install System Dependencies

```bash
# Update package list
sudo apt update

# Install Python and pip (if not already installed)
sudo apt install python3 python3-pip python3-venv

# Install Graphviz (required for diagrams library)
sudo apt install graphviz graphviz-dev

# Verify installations
python3 --version
pip3 --version
dot -V
```

### Step 2: Create Python Virtual Environment

```bash
# Navigate to architecture diagrams directory
cd /home/ubuntu/Projects/Health_Care_Management_System/Project-Docs/RC-Health-Care-Mgmt-App-Arch-Diagrams

# Create virtual environment
python3 -m venv diagram_env

# Activate virtual environment
source diagram_env/bin/activate

# Upgrade pip
pip install --upgrade pip
```

### Step 3: Install Python Dependencies

```bash
# Install diagrams library and dependencies
pip install diagrams

# Install additional dependencies for better rendering
pip install graphviz
pip install pillow

# Verify installation
python -c "import diagrams; print('Diagrams library installed successfully!')"
```

## 🚀 Running the Diagram Generator

### Generate All Diagrams

```bash
# Make sure you're in the architecture diagrams directory
cd /home/ubuntu/Projects/Health_Care_Management_System/Project-Docs/RC-Health-Care-Mgmt-App-Arch-Diagrams

# Activate virtual environment (if not already active)
source diagram_env/bin/activate

# Run the diagram generator
python3 Architecture-Diagram-Generator.py
```

### Expected Output

```
🎨 Generating Health Care Management System Architecture Diagrams...
📊 Creating main architecture diagram...
🔄 Creating data flow diagram...
🚀 Creating deployment diagram...
✅ All diagrams generated successfully!

📁 Generated files:
   - healthcare_architecture.png
   - healthcare_dataflow.png
   - healthcare_deployment.png
```

## 📋 Diagram Details

### 1. Main Architecture Diagram (healthcare_architecture.png)

**Components Visualized:**
- **👥 User Layer:** Patients, Doctors, Admin Staff
- **📱 Client Devices:** Desktop, Mobile, Tablet
- **🌐 Network Layer:** DNS, CDN, Load Balancer, Nginx
- **🎨 Frontend:** React + TypeScript + Tailwind CSS + Context API
- **⚙️ Backend:** Node.js + Express + Microservices (Port 3002)
- **🗄️ Database:** PostgreSQL + Redis (Future) + File Storage (Future)
- **🔌 External Services:** Email, SMS, Payment, Video (All Future)
- **📊 Monitoring:** Prometheus + Grafana (Future)
- **👨‍⚕️ Doctor Specializations:** 5 doctors across departments
- **✅ Current Status:** Authentication System Working

### 2. Data Flow Diagram (healthcare_dataflow.png)

**Flow Visualization:**
1. Client HTTP Request
2. API Token Validation
3. Cache Check (Redis)
4. Database Query (PostgreSQL)
5. Response Flow Back to Client

### 3. Deployment Diagram (healthcare_deployment.png)

**Environments Shown:**
- **🚀 Production:** Vercel/Netlify + AWS ECS + RDS
- **💻 Development:** Local Vite (:5173) + Express (:3002) + PostgreSQL (:5432)

## 🎨 Customizing Diagrams

### Modify Doctor Information

Edit the doctor specializations section in `Architecture-Diagram-Generator.py`:

```python
# Doctor Data Specification
with Cluster("👨‍⚕️ Doctor Specializations"):
    cardiology = Server("Dr. John Smith\nCardiology (Heart)")
    pulmonology = Server("Dr. Sarah Johnson\nPulmonology (Lungs)")
    neurology = Server("Dr. Michael Williams\nNeurology (Neuro)")
    orthopedics = Server("Dr. Emily Brown\nOrthopedics (Bone)")
    nephrology = Server("Dr. David Davis\nNephrology (Kidney)")
```

### Change Diagram Colors/Styles

Modify the graph attributes:

```python
graph_attr={
    "fontsize": "16",
    "bgcolor": "white",      # Background color
    "pad": "1.0",           # Padding
    "splines": "ortho"      # Connection style
}
```

### Add New Components

```python
# Example: Add new service
ai_service = Server("AI Diagnosis Service")

# Connect to existing components
doctor_service >> Edge(label="AI Analysis") >> ai_service
```

## 🔧 Troubleshooting

### Common Issues & Solutions

#### Issue: "graphviz not found"
```bash
# Solution: Install graphviz system package
sudo apt install graphviz graphviz-dev

# Reinstall Python graphviz
pip uninstall graphviz
pip install graphviz
```

#### Issue: "Permission denied"
```bash
# Solution: Check file permissions
chmod +x Architecture-Diagram-Generator.py

# Or run with python explicitly
python3 Architecture-Diagram-Generator.py
```

#### Issue: "Module 'diagrams' not found"
```bash
# Solution: Activate virtual environment
source diagram_env/bin/activate

# Reinstall diagrams
pip install diagrams
```

#### Issue: "Low quality images"
```bash
# Solution: Install Pillow for better image quality
pip install pillow

# Or specify DPI in diagram creation
with Diagram("Title", show=False, graph_attr={"dpi": "300"}):
```

### Verify Generated Files

```bash
# Check if files were created
ls -la *.png

# View file sizes (should be > 0 bytes)
du -h *.png

# Open images (if GUI available)
xdg-open healthcare_architecture.png
```

## 📊 Integration with Documentation

### Add to Project Tracker

Update `Project-Tracker.md` to include:

```markdown
### ✅ Completed Tasks
- [x] **Architecture Diagrams** - Generated visual system architecture (2025-01-26)
  - [x] Main system architecture diagram
  - [x] Data flow visualization
  - [x] Deployment architecture diagram
```

### Include in README

Add to main project README:

```markdown
## 🏗️ System Architecture

![System Architecture](Project-Docs/RC-Health-Care-Mgmt-App-Arch-Diagrams/healthcare_architecture.png)

For detailed architecture diagrams, see:
- [Main Architecture](Project-Docs/RC-Health-Care-Mgmt-App-Arch-Diagrams/healthcare_architecture.png)
- [Data Flow](Project-Docs/RC-Health-Care-Mgmt-App-Arch-Diagrams/healthcare_dataflow.png)
- [Deployment](Project-Docs/RC-Health-Care-Mgmt-App-Arch-Diagrams/healthcare_deployment.png)
```

## 🔄 Updating Diagrams

### When to Regenerate

- After adding new backend services
- When changing database structure
- After deployment architecture changes
- When adding new external integrations

### Quick Update Process

```bash
# Navigate to architecture diagrams directory
cd /home/ubuntu/Projects/Health_Care_Management_System/Project-Docs/RC-Health-Care-Mgmt-App-Arch-Diagrams

# Activate environment
source diagram_env/bin/activate

# Edit the Python script as needed
nano Architecture-Diagram-Generator.py

# Regenerate diagrams
python3 Architecture-Diagram-Generator.py

# Commit changes to version control
git add *.png Architecture-Diagram-Generator.py
git commit -m "Updated architecture diagrams"
```

## 📁 File Organization

After running the generator, your directory structure will be:

```
Health_Care_Management_System/
├── Project-Docs/
│   ├── RC-Health-Care-Mgmt-App-Arch-Diagrams/
│   │   ├── Architecture-Diagram-Generator.py    # Python script
│   │   ├── Architecture-Diagram-Setup.md        # This setup guide
│   │   ├── healthcare_architecture.png          # Main architecture
│   │   ├── healthcare_dataflow.png             # Data flow diagram
│   │   ├── healthcare_deployment.png           # Deployment diagram
│   │   └── diagram_env/                        # Python virtual environment
│   ├── Backend-Implementation-Checklist.md
│   ├── LOCAL_SETUP_GUIDE.md
│   ├── PROJECT_ANALYSIS_SUMMARY.md
│   ├── Project-Tracker.md
│   ├── QUICK_TEST.md
│   ├── Sample-Backend-Code.md
│   └── Upgrading-Project-For-Backend.md
└── [Other project files...]
```

---

## 🔄 **ARCHITECTURE UPDATES (July 26, 2025)**

### ✅ **Synchronized with Current Working System**

The architecture diagrams have been updated to reflect our **WORKING AUTHENTICATION SYSTEM** with the following changes:

#### **🔧 Port Configuration Updates:**
- **Backend Server:** `3001` → `3002` (Fixed port conflict)
- **Frontend Server:** Correctly shows `:5173` (Vite dev server)
- **Database:** Correctly shows `:5432` (PostgreSQL)

#### **📊 Technology Stack Corrections:**
- **State Management:** `Redux Toolkit` → `React Context API` (Current implementation)
- **API Client:** `React Query` → `Custom Hooks` (Current implementation)
- **Cache Layer:** Redis marked as `(Planned)` - not yet implemented
- **External Services:** All marked as `(Future)` - not yet implemented

#### **🎯 Current Implementation Status:**
- ✅ **Authentication System:** Working (Registration + Login)
- ✅ **Doctor Management:** Working (CRUD operations)
- ✅ **Appointment System:** Working (Basic functionality)
- ✅ **Database:** PostgreSQL with Prisma ORM
- ✅ **Frontend:** React + TypeScript + Tailwind CSS
- ✅ **Backend:** Node.js + Express + JWT Authentication

#### **🔮 Future Components (Shown as Planned):**
- Redis Cache Layer
- External Email/SMS Services
- Payment Gateway Integration
- Video Call Service
- Monitoring (Prometheus + Grafana)

### 📋 **Updated Diagram Descriptions:**

#### **1. Main Architecture (healthcare_architecture.png)**
- Shows current working system with correct ports
- Distinguishes between implemented and planned features
- Reflects actual technology choices

#### **2. Data Flow (healthcare_dataflow.png)**
- Updated to show current API flow patterns
- Reflects actual authentication flow
- Shows current database interaction patterns

#### **3. Deployment (healthcare_deployment.png)**
- Development environment shows correct ports
- Production environment shows planned AWS deployment
- Reflects current Docker configuration

### 🚀 **Generate Updated Diagrams:**

```bash
# Navigate to architecture diagrams directory
cd /home/ubuntu/Projects/Health_Care_Management_System/Project-Docs/RC-Health-Care-Mgmt-App-Arch-Diagrams

# Activate virtual environment
source diagram_env/bin/activate

# Generate updated diagrams
python3 Architecture-Diagram-Generator.py

# Expected output shows current system status
✅ All diagrams generated successfully!
📁 Generated files reflect WORKING authentication system
```

### 📊 **Verification:**

After generating, the diagrams will show:
- ✅ Backend on port 3002 (working)
- ✅ Frontend on port 5173 (working)
- ✅ Authentication system (implemented)
- ✅ Doctor management (implemented)
- 🔮 Future features clearly marked as "Planned"

---

**🎉 Ready to Generate!** Follow this guide to create professional architecture diagrams that visualize your **CURRENT WORKING** Health Care Management System with accurate port configurations and implementation status.
