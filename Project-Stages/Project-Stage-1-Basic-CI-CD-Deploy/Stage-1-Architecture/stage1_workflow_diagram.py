#!/usr/bin/env python3
"""
Stage 1 Complete Workflow Diagram as Code
Health Care Management System - Basic CI/CD Deployment

This script generates a comprehensive architecture diagram showing:
1. Prerequisites and Setup
2. Deployment Workflow
3. Application Architecture
4. Destruction Process
5. Cost Management

Requirements:
    pip install diagrams pillow
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import EKS, EC2
from diagrams.aws.network import ELB, VPC, PrivateSubnet, PublicSubnet, InternetGateway, NATGateway
from diagrams.aws.security import IAM
from diagrams.aws.storage import EBS
from diagrams.aws.management import Cloudformation, Cloudwatch
from diagrams.aws.database import RDS
from diagrams.onprem.client import Users, Client
from diagrams.onprem.container import Docker
from diagrams.onprem.vcs import Github
from diagrams.onprem.ci import Jenkins
from diagrams.programming.language import JavaScript, Python
from diagrams.k8s.compute import Pod, Deployment
from diagrams.k8s.network import Service
from diagrams.k8s.storage import PV
from diagrams.generic.device import Mobile, Tablet
from diagrams.generic.network import Firewall
from diagrams.generic.storage import Storage
from diagrams.generic.compute import Rack

def create_stage1_workflow_diagram():
    """Create comprehensive Stage 1 workflow diagram"""
    
    with Diagram(
        "Stage 1: Health Care Management System - Complete Workflow",
        filename="Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/Stage-1-Architecture/stage1_complete_workflow",
        show=False,
        direction="TB",
        graph_attr={
            "fontsize": "20",
            "bgcolor": "white",
            "pad": "1.0",
            "splines": "ortho"
        }
    ):
        
        # =============================================================================
        # PHASE 1: PREREQUISITES & SETUP
        # =============================================================================
        with Cluster("🔧 Phase 1: Prerequisites & Setup (45 min)", graph_attr={"bgcolor": "#E8F4FD"}):
            
            with Cluster("Local Development Environment"):
                dev_machine = Client("Developer Machine\nUbuntu 20.04+")

                with Cluster("Required Tools"):
                    kubectl = Python("kubectl v1.33.3\nEKS Compatible")
                    eksctl = Python("eksctl 0.211.0\nLatest")
                    aws_cli = Python("AWS CLI v2.15+\nLatest")
                    docker = Docker("Docker 24.0+\nContainer Runtime")
                    postgres_local = Storage("PostgreSQL 16.9\nMatches Container")
            
            with Cluster("AWS Account Setup"):
                iam_policy = IAM("EKS-Stage1-Policy\nFull Permissions")
                aws_creds = Firewall("AWS Credentials\nConfigured")
                billing = Cloudwatch("Billing Alerts\nCost Monitor")
        
        # =============================================================================
        # PHASE 2: DOCKER HUB PREPARATION
        # =============================================================================
        with Cluster("🐳 Phase 2: Docker Hub Preparation (20 min)", graph_attr={"bgcolor": "#FFF2E8"}):
            
            with Cluster("Source Code"):
                github_repo = Github("Health Care Repo\n✅ Source Code")
                frontend_code = JavaScript("React Frontend\nNode.js 20 LTS")
                backend_code = JavaScript("Node.js Backend\nExpress + Prisma")
            
            with Cluster("Docker Images"):
                frontend_image = Docker("healthcare-frontend:v1.0\n✅ Built & Pushed")
                backend_image = Docker("healthcare-backend:v1.0\n✅ Built & Pushed")
                postgres_image = Docker("postgres:16-alpine\n✅ Matches System")
            
            docker_hub = Storage("Docker Hub Registry\n✅ Public Images")

        # =============================================================================
        # PHASE 3: AWS EKS INFRASTRUCTURE
        # =============================================================================
        with Cluster("☁️ Phase 3: AWS EKS Infrastructure (45 min)", graph_attr={"bgcolor": "#E8F8E8"}):
            
            with Cluster("EKS Cluster (Automatic Creation)"):
                eks_cluster = EKS("healthcare-cluster\nEKS v1.32\n✅ Perfect Compatibility")
                
                with Cluster("Managed Node Group"):
                    worker_node1 = EC2("Worker Node 1\nt3.medium")
                    worker_node2 = EC2("Worker Node 2\nt3.medium")
                
                with Cluster("Networking (Auto-Created)"):
                    vpc = VPC("Healthcare VPC\n10.0.0.0/16")
                    igw = InternetGateway("Internet Gateway")
                    
                    with Cluster("Public Subnets"):
                        pub_subnet1 = PublicSubnet("Public Subnet 1\n10.0.1.0/24")
                        pub_subnet2 = PublicSubnet("Public Subnet 2\n10.0.2.0/24")
                    
                    with Cluster("Private Subnets"):
                        priv_subnet1 = PrivateSubnet("Private Subnet 1\n10.0.3.0/24")
                        priv_subnet2 = PrivateSubnet("Private Subnet 2\n10.0.4.0/24")
                    
                    nat_gw = NATGateway("NAT Gateway")
                
                with Cluster("Security (Auto-Created)"):
                    cluster_sg = Firewall("Cluster Security Group")
                    node_sg = Firewall("Node Security Group")
                    pod_sg = Firewall("Pod Security Group")
                
                with Cluster("IAM Roles (Auto-Created)"):
                    cluster_role = IAM("EKS Cluster Role")
                    node_role = IAM("Node Group Role")
                    pod_role = IAM("Pod Execution Role")
                
                cf_stack = Cloudformation("CloudFormation Stacks\n✅ Infrastructure as Code")

        # =============================================================================
        # PHASE 4: APPLICATION DEPLOYMENT
        # =============================================================================
        with Cluster("🚀 Phase 4: Application Deployment (30 min)", graph_attr={"bgcolor": "#F8E8F8"}):
            
            with Cluster("Kubernetes Namespace"):
                namespace = Rack("healthcare namespace\n✅ Isolated Environment")
                
                with Cluster("Database Tier"):
                    postgres_deploy = Deployment("PostgreSQL Deployment\nPostgreSQL 16-alpine")
                    postgres_pod = Pod("postgres-db\n✅ Health Checks")
                    postgres_service = Service("postgres-service\nClusterIP:5432")
                    postgres_storage = PV("Persistent Volume\nDatabase Storage")
                
                with Cluster("Backend Tier"):
                    backend_deploy = Deployment("Backend Deployment\n2 Replicas")
                    backend_pod1 = Pod("backend-pod-1\n✅ Health Checks")
                    backend_pod2 = Pod("backend-pod-2\n✅ Health Checks")
                    backend_service = Service("backend-service\nClusterIP:3002")
                
                with Cluster("Frontend Tier"):
                    frontend_deploy = Deployment("Frontend Deployment\n2 Replicas")
                    frontend_pod1 = Pod("frontend-pod-1\n✅ Health Checks")
                    frontend_pod2 = Pod("frontend-pod-2\n✅ Health Checks")
                    frontend_service = Service("frontend-service\nLoadBalancer:80")
                
                load_balancer = ELB("AWS Load Balancer\n✅ External Access")

        # =============================================================================
        # PHASE 5: VERIFICATION & MONITORING
        # =============================================================================
        with Cluster("✅ Phase 5: Verification & Monitoring (15 min)", graph_attr={"bgcolor": "#F0F8FF"}):
            
            with Cluster("Health Checks"):
                health_check = Cloudwatch("Application Health\n✅ All Services Running")
                metrics = Cloudwatch("Resource Metrics\n✅ CPU, Memory, Network")
                logs = Cloudwatch("Application Logs\n✅ Error Monitoring")
            
            with Cluster("External Access"):
                external_ip = InternetGateway("External IP\nhttp://xxx.elb.amazonaws.com")
                
            with Cluster("User Access"):
                web_users = Users("Web Users\n✅ Registration & Login")
                mobile_users = Mobile("Mobile Users\n✅ Responsive Design")
                tablet_users = Tablet("Tablet Users\n✅ Cross-Platform")

        # =============================================================================
        # PHASE 6: DESTRUCTION PROCESS
        # =============================================================================
        with Cluster("🗑️ Phase 6: Cost-Safe Destruction (30 min)", graph_attr={"bgcolor": "#FFE8E8"}):
            
            with Cluster("Cleanup Order (Critical)"):
                step1 = Rack("1. Delete Applications\nkubectl delete namespace")
                step2 = Rack("2. Delete Load Balancers\n✅ Prevent Stuck Resources")
                step3 = Rack("3. Delete EKS Cluster\neksctl delete cluster")
                step4 = Rack("4. Verify AWS Resources\n✅ No Ongoing Charges")
            
            with Cluster("Cost Prevention"):
                cost_monitor = Cloudwatch("Cost Monitoring\n✅ $0 After Cleanup")
                billing_alert = Cloudwatch("Billing Alerts\n✅ Unexpected Charges")

        # =============================================================================
        # WORKFLOW CONNECTIONS
        # =============================================================================
        
        # Phase 1 → Phase 2
        dev_machine >> Edge(label="setup-tools.sh", style="bold", color="blue") >> github_repo
        aws_creds >> Edge(label="aws configure", style="bold", color="green") >> docker_hub
        
        # Phase 2 → Phase 3
        docker_hub >> Edge(label="create-eks-cluster.sh", style="bold", color="orange") >> eks_cluster
        
        # Phase 3 → Phase 4
        eks_cluster >> Edge(label="deploy-to-eks.sh", style="bold", color="purple") >> namespace
        
        # Phase 4 Internal Connections
        postgres_deploy >> postgres_pod >> postgres_service
        backend_deploy >> backend_pod1 >> backend_service
        backend_deploy >> backend_pod2 >> backend_service
        frontend_deploy >> frontend_pod1 >> frontend_service >> load_balancer
        frontend_deploy >> frontend_pod2 >> frontend_service

        # Phase 4 → Phase 5
        load_balancer >> Edge(label="verify-deployment.sh", style="bold", color="green") >> external_ip
        external_ip >> web_users
        external_ip >> mobile_users
        external_ip >> tablet_users
        
        # Phase 5 → Phase 6
        health_check >> Edge(label="cleanup.sh", style="bold", color="red") >> step1
        step1 >> step2 >> step3 >> step4 >> cost_monitor

def create_cost_breakdown_diagram():
    """Create cost breakdown and timeline diagram"""
    
    with Diagram(
        "Stage 1: Cost Breakdown & Timeline",
        filename="Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/Stage-1-Architecture/stage1_cost_timeline",
        show=False,
        direction="LR",
        graph_attr={
            "fontsize": "16",
            "bgcolor": "white",
            "pad": "1.0"
        }
    ):
        
        with Cluster("💰 Monthly Cost Breakdown (~$163)", graph_attr={"bgcolor": "#FFF8DC"}):
            eks_cost = Cloudwatch("EKS Control Plane\n$73/month")
            ec2_cost = EC2("2x t3.medium Nodes\n$60/month")
            elb_cost = ELB("Load Balancer\n$20/month")
            storage_cost = EBS("Storage & Transfer\n$10/month")
        
        with Cluster("⏱️ Deployment Timeline (2.5 hours)", graph_attr={"bgcolor": "#F0F8FF"}):
            timeline1 = Rack("Setup Tools\n45 minutes")
            timeline2 = Rack("Docker Images\n20 minutes")
            timeline3 = Rack("EKS Cluster\n45 minutes")
            timeline4 = Rack("App Deployment\n30 minutes")
            timeline5 = Rack("Verification\n15 minutes")
            timeline6 = Rack("Cleanup\n30 minutes")
        
        timeline1 >> timeline2 >> timeline3 >> timeline4 >> timeline5 >> timeline6

if __name__ == "__main__":
    print("🎨 Generating Stage 1 Workflow Diagrams...")
    print("📊 Creating comprehensive workflow diagram...")
    create_stage1_workflow_diagram()
    print("💰 Creating cost and timeline diagram...")
    create_cost_breakdown_diagram()
    print("✅ Diagrams generated successfully!")
    print("📁 Location: Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/Stage-1-Architecture/")
    print("🖼️  Files:")
    print("   - stage1_complete_workflow.png")
    print("   - stage1_cost_timeline.png")
