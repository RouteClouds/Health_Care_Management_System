#!/usr/bin/env python3
"""
Simplified Stage 1 Architecture Diagrams
Health Care Management System - Core Diagrams Only

This script generates simplified but professional diagrams focusing on:
1. Main workflow overview
2. AWS infrastructure overview
3. Application architecture overview

Requirements:
    pip install diagrams pillow
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import EKS, EC2
from diagrams.aws.network import ELB, VPC, PrivateSubnet, PublicSubnet, InternetGateway, NATGateway
from diagrams.aws.security import IAM
from diagrams.aws.storage import EBS
from diagrams.aws.management import Cloudformation, Cloudwatch
from diagrams.onprem.client import Users
from diagrams.onprem.container import Docker
from diagrams.onprem.vcs import Github
from diagrams.k8s.compute import Pod, Deployment
from diagrams.k8s.network import Service
from diagrams.k8s.storage import PV
from diagrams.generic.device import Mobile
from diagrams.generic.network import Firewall
from diagrams.generic.storage import Storage
from diagrams.generic.compute import Rack

def create_main_workflow():
    """Create main workflow diagram"""
    
    with Diagram(
        "Stage 1: Healthcare System - Main Workflow",
        filename="Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/Stage-1-Architecture/stage1_main_workflow",
        show=False,
        direction="TB",
        graph_attr={
            "fontsize": "20",
            "bgcolor": "white",
            "pad": "1.0"
        }
    ):
        
        # Prerequisites
        with Cluster("🔧 Prerequisites", graph_attr={"bgcolor": "#E8F4FD"}):
            dev_env = Rack("Dev Environment\nkubectl, eksctl, AWS CLI")
            aws_setup = IAM("AWS Setup\nIAM Policy")
            docker_images = Docker("Docker Images\nFE & BE")
        
        # AWS Infrastructure
        with Cluster("☁️ AWS Infrastructure", graph_attr={"bgcolor": "#E8F8E8"}):
            eks_cluster = EKS("EKS Cluster v1.32\n2x t3.medium")
            vpc_network = VPC("VPC + Networking\nAuto-created")
            security = Firewall("Security Groups\nAuto-created")
        
        # Application Deployment
        with Cluster("🚀 Application", graph_attr={"bgcolor": "#F8E8F8"}):
            postgres_db = Storage("PostgreSQL 16\nDatabase")
            backend_api = Rack("Node.js Backend\n2 replicas")
            frontend_web = Rack("React Frontend\n2 replicas")
            load_balancer = ELB("Load Balancer\nExternal")
        
        # Users
        users = Users("Healthcare Users\nDoctors & Patients")
        
        # Connections
        dev_env >> aws_setup >> docker_images
        docker_images >> eks_cluster
        eks_cluster >> vpc_network >> security
        security >> postgres_db >> backend_api >> frontend_web >> load_balancer
        load_balancer >> users

def create_aws_infrastructure():
    """Create AWS infrastructure diagram"""
    
    with Diagram(
        "Stage 1: AWS Infrastructure Overview",
        filename="Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/Stage-1-Architecture/stage1_aws_overview",
        show=False,
        direction="TB",
        graph_attr={
            "fontsize": "18",
            "bgcolor": "white",
            "pad": "1.0"
        }
    ):
        
        # External
        users = Users("External Users")
        
        # AWS Infrastructure
        with Cluster("🏢 AWS Region: us-east-1", graph_attr={"bgcolor": "#FFF8DC"}):
            
            with Cluster("VPC: Healthcare (10.0.0.0/16)"):
                igw = InternetGateway("Internet Gateway")
                
                with Cluster("Public Subnets"):
                    alb = ELB("Application Load Balancer")
                
                with Cluster("Private Subnets"):
                    with Cluster("EKS Cluster"):
                        worker1 = EC2("Worker Node 1\nt3.medium")
                        worker2 = EC2("Worker Node 2\nt3.medium")
                        
                        with Cluster("Kubernetes Pods"):
                            frontend = Pod("Frontend Pods\nReact App")
                            backend = Pod("Backend Pods\nNode.js API")
                            database = Pod("Database Pod\nPostgreSQL 16")
                
                nat = NATGateway("NAT Gateway")
            
            # Management
            with Cluster("Management & Security"):
                cf = Cloudformation("CloudFormation\nInfrastructure as Code")
                iam = IAM("IAM Roles\nAuto-created")
                sg = Firewall("Security Groups\nAuto-created")
        
        # Connections
        users >> igw >> alb
        alb >> frontend >> backend >> database
        nat >> worker1
        nat >> worker2
        cf >> worker1
        cf >> worker2
        iam >> worker1
        iam >> worker2
        sg >> alb

def create_application_architecture():
    """Create application architecture diagram"""
    
    with Diagram(
        "Stage 1: Application Architecture",
        filename="Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/Stage-1-Architecture/stage1_app_architecture",
        show=False,
        direction="LR",
        graph_attr={
            "fontsize": "16",
            "bgcolor": "white",
            "pad": "1.0"
        }
    ):
        
        # Users
        web_users = Users("Web Users")
        mobile_users = Mobile("Mobile Users")
        
        # External Load Balancer
        external_lb = ELB("AWS Load Balancer\nExternal IP")
        
        # Kubernetes Application
        with Cluster("☸️ Kubernetes: healthcare namespace"):
            
            # Frontend Tier
            with Cluster("Frontend Tier"):
                frontend_svc = Service("frontend-service\nLoadBalancer")
                frontend_deploy = Deployment("Frontend Deployment\n2 replicas")
                frontend_pods = Pod("React Pods\nNginx + React App")
            
            # Backend Tier
            with Cluster("Backend Tier"):
                backend_svc = Service("backend-service\nClusterIP")
                backend_deploy = Deployment("Backend Deployment\n2 replicas")
                backend_pods = Pod("Node.js Pods\nExpress + Prisma")
            
            # Database Tier
            with Cluster("Database Tier"):
                db_svc = Service("postgres-service\nClusterIP")
                db_deploy = Deployment("PostgreSQL Deployment\n1 replica")
                db_pod = Pod("PostgreSQL 16\nHealthcare Database")
                db_storage = PV("Persistent Volume\nEBS Storage")
        
        # Connections
        web_users >> external_lb
        mobile_users >> external_lb
        external_lb >> frontend_svc >> frontend_deploy >> frontend_pods
        frontend_pods >> backend_svc >> backend_deploy >> backend_pods
        backend_pods >> db_svc >> db_deploy >> db_pod >> db_storage

def create_cost_timeline():
    """Create cost and timeline overview"""
    
    with Diagram(
        "Stage 1: Cost & Timeline Overview",
        filename="Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/Stage-1-Architecture/stage1_cost_overview",
        show=False,
        direction="TB",
        graph_attr={
            "fontsize": "16",
            "bgcolor": "white",
            "pad": "1.0"
        }
    ):
        
        # Cost Breakdown
        with Cluster("💰 Monthly Costs (~$163)", graph_attr={"bgcolor": "#FFF8DC"}):
            eks_cost = EKS("EKS Control Plane\n$73/month (45%)")
            ec2_cost = EC2("2x t3.medium\n$60/month (37%)")
            elb_cost = ELB("Load Balancer\n$20/month (12%)")
            storage_cost = EBS("Storage\n$10/month (6%)")
        
        # Timeline
        with Cluster("⏱️ Deployment Timeline", graph_attr={"bgcolor": "#F0F8FF"}):
            phase1 = Rack("Setup & Prerequisites\n45 minutes")
            phase2 = Rack("EKS Cluster Creation\n45 minutes")
            phase3 = Rack("Application Deployment\n30 minutes")
            phase4 = Rack("Verification\n15 minutes")
            phase5 = Rack("Cleanup (when done)\n30 minutes")
        
        # Flow
        phase1 >> phase2 >> phase3 >> phase4 >> phase5

if __name__ == "__main__":
    print("🎨 Generating Simplified Stage 1 Architecture Diagrams...")
    
    try:
        print("📊 Creating main workflow diagram...")
        create_main_workflow()
        print("✅ Main workflow diagram created")
        
        print("🏗️ Creating AWS infrastructure diagram...")
        create_aws_infrastructure()
        print("✅ AWS infrastructure diagram created")
        
        print("☸️ Creating application architecture diagram...")
        create_application_architecture()
        print("✅ Application architecture diagram created")
        
        print("💰 Creating cost & timeline diagram...")
        create_cost_timeline()
        print("✅ Cost & timeline diagram created")
        
        print("\n🎉 All simplified diagrams generated successfully!")
        print("📁 Location: Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/Stage-1-Architecture/")
        print("🖼️ Files:")
        print("   - stage1_main_workflow.png")
        print("   - stage1_aws_overview.png")
        print("   - stage1_app_architecture.png")
        print("   - stage1_cost_overview.png")
        
    except Exception as e:
        print(f"❌ Error generating diagrams: {e}")
        import traceback
        traceback.print_exc()
