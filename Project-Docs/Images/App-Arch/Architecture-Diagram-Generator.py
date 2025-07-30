#!/usr/bin/env python3
"""
Health Care Management System - Architecture Diagram Generator
Creates a comprehensive system architecture diagram using Python diagrams library
"""

try:
    from diagrams import Diagram, Cluster, Edge
    from diagrams.onprem.client import Users, Client
    from diagrams.onprem.compute import Server
    from diagrams.onprem.database import PostgreSQL
    from diagrams.onprem.inmemory import Redis
    from diagrams.onprem.network import Nginx
    from diagrams.onprem.monitoring import Grafana, Prometheus
    from diagrams.programming.framework import React
    from diagrams.programming.language import JavaScript, TypeScript, Nodejs
    from diagrams.aws.compute import EC2, ECS
    from diagrams.aws.database import RDS, ElastiCache
    from diagrams.aws.network import CloudFront, ELB, Route53
    from diagrams.aws.storage import S3
    from diagrams.aws.security import IAM
    from diagrams.generic.device import Mobile, Tablet
    from diagrams.generic.storage import Storage
    from diagrams.generic.compute import Rack
    print("✅ All imports successful!")
except ImportError as e:
    print(f"❌ Import error: {e}")
    print("Please install diagrams library: pip install diagrams")
    exit(1)

def create_healthcare_architecture():
    """Create the main healthcare system architecture diagram"""
    
    with Diagram("Health Care Management System - Docker Production Architecture (v2.0)",
                 show=False,
                 direction="TB",
                 filename="healthcare_architecture",
                 graph_attr={
                     "fontsize": "16",
                     "bgcolor": "white",
                     "pad": "1.0",
                     "splines": "ortho",
                     "label": "✅ Production Ready: Docker + Authentication + Appointments + 4 Containers"
                 }):
        
        # User Layer
        with Cluster("👥 Users & Devices"):
            patients = Users("Patients")
            doctors = Users("Doctors") 
            admins = Users("Admin Staff")
            
            with Cluster("📱 Client Devices"):
                desktop = Client("Desktop Browser")
                mobile = Mobile("Mobile App")
                tablet = Tablet("Tablet")
        
        # Docker Container Layer (Current Production Setup)
        with Cluster("🐳 Docker Container Architecture"):
            with Cluster("Container Network"):
                nginx_container = Nginx("Nginx Proxy\n(Port 80/443)")
                frontend_container = Server("Frontend Container\n(React + Nginx)")
                backend_container = Server("Backend Container\n(Node.js + Express)")
                database_container = PostgreSQL("Database Container\n(PostgreSQL)")

        # Load Balancer & CDN (Future/Production)
        with Cluster("🌐 Network & CDN Layer (Future)"):
            dns = Route53("DNS (Planned)")
            cdn = CloudFront("CDN (Planned)")
            load_balancer = ELB("Load Balancer (Planned)")
        
        # Frontend Layer
        with Cluster("🎨 Frontend Layer (React + TypeScript)"):
            with Cluster("React Application"):
                react_app = React("React 18.3.1")
                typescript = TypeScript("TypeScript")
                
            with Cluster("State Management (Current)"):
                redux_toolkit = JavaScript("Redux Toolkit")
                react_query = JavaScript("React Query")
                custom_hooks = JavaScript("Custom Hooks")
                
            with Cluster("UI Framework"):
                tailwind = JavaScript("Tailwind CSS")
                vite = JavaScript("Vite Build")
                
            with Cluster("Routing & Forms"):
                router = JavaScript("React Router")
                formik = JavaScript("Formik + Yup")

            with Cluster("Current Features (Implemented)"):
                auth_ui = JavaScript("Login/Register UI")
                appointment_ui = JavaScript("Appointment Booking")
                protected_routes = JavaScript("Protected Routes")
                doctor_listings = JavaScript("Doctor Management")
        
        # API Gateway
        api_gateway = Server("API Gateway")
        
        # Backend Layer
        with Cluster("⚙️ Backend Layer (Node.js + Express)"):
            with Cluster("Application Servers"):
                app_server1 = Nodejs("Express Server 1")
                app_server2 = Nodejs("Express Server 2")
                
            with Cluster("API Services"):
                auth_service = Server("Auth Service")
                doctor_service = Server("Doctor Service")
                appointment_service = Server("Appointment Service")
                patient_service = Server("Patient Service")
                notification_service = Server("Notification Service")
        
        # Database Layer
        with Cluster("🗄️ Database Layer"):
            with Cluster("Primary Database"):
                postgres_primary = PostgreSQL("PostgreSQL\n(Primary)")
                postgres_replica = PostgreSQL("PostgreSQL\n(Read Replica)")
                
            with Cluster("Cache Layer (Future)"):
                redis_cache = Redis("Redis Cache\n(Planned)")
                redis_session = Redis("Redis Sessions\n(Planned)")
                
            with Cluster("File Storage"):
                file_storage = S3("File Storage\n(Medical Records)")
        
        # External Services
        with Cluster("🔌 External Services (Future)"):
            email_service = Server("Email Service\n(Planned)")
            sms_service = Server("SMS Gateway\n(Planned)")
            payment_gateway = Server("Payment Gateway\n(Planned)")
            video_service = Server("Video Call Service\n(Planned)")
        
        # Monitoring & Security
        with Cluster("📊 Monitoring & Security"):
            monitoring = Prometheus("Prometheus")
            visualization = Grafana("Grafana")
            auth_provider = IAM("JWT Auth")
            security = Server("Security Scanner")
        
        # Doctor Data Specification (Matches Current Database Seed)
        with Cluster("👨‍⚕️ Doctor Specializations (Current Database)"):
            cardiology = Server("Dr. John Smith\nInterventional Cardiology")
            pulmonology = Server("Dr. Sarah Johnson\nCritical Care Pulmonology")
            neurology = Server("Dr. Michael Williams\nClinical Neurology")
            orthopedics = Server("Dr. Emily Brown\nOrthopedic Surgery")
            nephrology = Server("Dr. David Davis\nClinical Nephrology")
        
        # Define connections with labels
        # User to Frontend
        patients >> Edge(label="HTTPS") >> dns
        doctors >> Edge(label="HTTPS") >> dns
        admins >> Edge(label="HTTPS") >> dns
        
        desktop >> Edge(label="Web App") >> cdn
        mobile >> Edge(label="PWA/App") >> cdn
        tablet >> Edge(label="Responsive") >> cdn
        
        # Network Flow (Current: Direct to Docker containers)
        dns >> cdn >> load_balancer >> nginx_container
        
        # Frontend connections
        nginx_container >> Edge(label="Static Files") >> react_app
        react_app >> typescript
        react_app >> redux_toolkit
        react_app >> custom_hooks
        react_app >> tailwind
        react_app >> vite
        react_app >> router
        react_app >> formik

        # API Flow
        custom_hooks >> Edge(label="REST API") >> backend_container
        api_gateway >> Edge(label="Load Balance") >> [app_server1, app_server2]
        
        # Backend Services
        app_server1 >> auth_service
        app_server1 >> doctor_service
        app_server1 >> appointment_service
        app_server1 >> patient_service
        app_server1 >> notification_service
        
        app_server2 >> auth_service
        app_server2 >> doctor_service
        app_server2 >> appointment_service
        app_server2 >> patient_service
        app_server2 >> notification_service
        
        # Database connections
        doctor_service >> Edge(label="Prisma ORM") >> postgres_primary
        appointment_service >> Edge(label="CRUD") >> postgres_primary
        patient_service >> Edge(label="CRUD") >> postgres_primary
        auth_service >> Edge(label="User Data") >> postgres_primary
        
        postgres_primary >> Edge(label="Replication") >> postgres_replica
        
        # Cache connections (Future Implementation)
        # auth_service >> Edge(label="Sessions") >> redis_session
        # doctor_service >> Edge(label="Cache") >> redis_cache
        # appointment_service >> Edge(label="Cache") >> redis_cache
        
        # File storage
        patient_service >> Edge(label="Medical Files") >> file_storage
        
        # External services (Future Implementation)
        # notification_service >> email_service
        # notification_service >> sms_service
        # appointment_service >> payment_gateway
        # appointment_service >> video_service
        
        # Monitoring
        [app_server1, app_server2] >> monitoring
        monitoring >> visualization
        
        # Security
        api_gateway >> auth_provider
        auth_service >> auth_provider
        
        # Doctor specializations connection
        doctor_service >> Edge(label="Manages") >> [
            cardiology, pulmonology, neurology, orthopedics, nephrology
        ]

def create_data_flow_diagram():
    """Create a detailed data flow diagram"""
    
    with Diagram("Health Care System - Data Flow Architecture", 
                 show=False, 
                 direction="LR",
                 filename="healthcare_dataflow",
                 graph_attr={
                     "fontsize": "14",
                     "bgcolor": "white",
                     "pad": "1.0"
                 }):
        
        # Client Layer
        with Cluster("Client Layer"):
            browser = Client("React App")
            
        # API Layer
        with Cluster("API Layer"):
            api = Server("Express API")
            
        # Business Logic
        with Cluster("Business Logic"):
            auth = Server("Authentication")
            doctors = Server("Doctor Management")
            appointments = Server("Appointments")
            
        # Data Layer
        with Cluster("Data Layer"):
            db = PostgreSQL("PostgreSQL")
            cache = Redis("Redis Cache")
            
        # Data Flow
        browser >> Edge(label="1. HTTP Request") >> api
        api >> Edge(label="2. Validate Token") >> auth
        auth >> Edge(label="3. Check Cache") >> cache
        cache >> Edge(label="4. Cache Miss") >> doctors
        doctors >> Edge(label="5. Query DB") >> db
        db >> Edge(label="6. Return Data") >> doctors
        doctors >> Edge(label="7. Cache Result") >> cache
        doctors >> Edge(label="8. JSON Response") >> api
        api >> Edge(label="9. HTTP Response") >> browser

def create_deployment_diagram():
    """Create deployment architecture diagram"""
    
    with Diagram("Health Care System - Deployment Architecture", 
                 show=False, 
                 direction="TB",
                 filename="healthcare_deployment",
                 graph_attr={
                     "fontsize": "14",
                     "bgcolor": "white",
                     "pad": "1.0"
                 }):
        
        # Production Environment
        with Cluster("🚀 Production Environment"):
            with Cluster("Frontend Deployment"):
                vercel = Server("Vercel/Netlify")
                s3_static = S3("S3 Static Hosting")
                
            with Cluster("Backend Deployment"):
                ecs_cluster = ECS("ECS Cluster")
                ec2_instances = [EC2("EC2 Instance 1"), EC2("EC2 Instance 2")]
                
            with Cluster("Database Services"):
                rds_primary = RDS("RDS PostgreSQL")
                rds_replica = RDS("RDS Read Replica")
                elasticache = ElastiCache("ElastiCache Redis")
        
        # Current Docker Environment (Production Ready)
        with Cluster("🐳 Current Docker Environment"):
            docker_nginx = Nginx("Nginx Container\n:80/443")
            docker_frontend = React("Frontend Container\n:5173->80")
            docker_backend = Nodejs("Backend Container\n:3002")
            docker_db = PostgreSQL("Database Container\n:5432")

        # Development Environment (Local)
        with Cluster("💻 Development Environment"):
            dev_frontend = React("Vite Dev Server\n:5173")
            dev_backend = Nodejs("Express Server\n:3002")
            dev_db = PostgreSQL("Local PostgreSQL\n:5432")
        
        # Connections
        vercel >> Edge(label="API Calls") >> ecs_cluster
        ecs_cluster >> ec2_instances
        ec2_instances >> rds_primary
        rds_primary >> rds_replica
        ec2_instances >> elasticache
        
        dev_frontend >> Edge(label="API Calls") >> dev_backend
        dev_backend >> dev_db
        # dev_backend >> dev_redis  # Not implemented yet

if __name__ == "__main__":
    print("🎨 Generating Health Care Management System Architecture Diagrams...")
    
    print("📊 Creating main architecture diagram...")
    create_healthcare_architecture()
    
    print("🔄 Creating data flow diagram...")
    create_data_flow_diagram()
    
    print("🚀 Creating deployment diagram...")
    create_deployment_diagram()
    
    print("✅ All diagrams generated successfully!")
    print("\n📁 Generated files:")
    print("   - healthcare_architecture.png")
    print("   - healthcare_dataflow.png") 
    print("   - healthcare_deployment.png")
    print("\n🔧 To run this script:")
    print("   pip install diagrams")
    print("   python Architecture-Diagram-Generator.py")
