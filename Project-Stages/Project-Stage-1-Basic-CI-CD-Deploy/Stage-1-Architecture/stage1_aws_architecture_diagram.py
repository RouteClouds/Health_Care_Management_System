#!/usr/bin/env python3
"""
Stage 1 AWS Architecture Diagram as Code
Health Care Management System - AWS Infrastructure

This script generates detailed AWS architecture diagrams showing:
1. Complete AWS infrastructure
2. Kubernetes cluster architecture
3. Application deployment architecture
4. Security and networking
5. Cost optimization view

Requirements:
    pip install diagrams pillow
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import EKS, EC2, AutoScaling
from diagrams.aws.network import ELB, VPC, PrivateSubnet, PublicSubnet, InternetGateway, NATGateway, Route53
from diagrams.aws.security import IAM
from diagrams.aws.storage import EBS, S3
from diagrams.aws.management import Cloudformation, Cloudwatch, Cloudtrail
from diagrams.aws.database import RDS
from diagrams.onprem.client import Users
from diagrams.onprem.container import Docker
from diagrams.k8s.compute import Pod, Deployment, ReplicaSet
from diagrams.k8s.network import Service, Ingress
from diagrams.k8s.storage import PV, PVC
from diagrams.k8s.rbac import ServiceAccount
from diagrams.generic.device import Mobile, Tablet
from diagrams.generic.network import Firewall
from diagrams.generic.storage import Storage

def create_aws_infrastructure_diagram():
    """Create comprehensive AWS infrastructure diagram"""
    
    with Diagram(
        "Stage 1: AWS Infrastructure Architecture",
        filename="Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/Stage-1-Architecture/stage1_aws_infrastructure",
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
        # EXTERNAL USERS
        # =============================================================================
        with Cluster("🌐 External Users", graph_attr={"bgcolor": "#F0F8FF"}):
            web_users = Users("Web Users\nDoctors & Patients")
            mobile_users = Mobile("Mobile Users\nResponsive Design")
            tablet_users = Tablet("Tablet Users\nCross-Platform")
        
        # =============================================================================
        # AWS REGION: US-EAST-1
        # =============================================================================
        with Cluster("🏢 AWS Region: us-east-1", graph_attr={"bgcolor": "#FFF8DC"}):
            
            # =============================================================================
            # VPC AND NETWORKING
            # =============================================================================
            with Cluster("🌐 Healthcare VPC (10.0.0.0/16)", graph_attr={"bgcolor": "#E8F4FD"}):
                
                vpc = VPC("Healthcare VPC\n10.0.0.0/16")
                igw = InternetGateway("Internet Gateway")
                
                # PUBLIC SUBNETS
                with Cluster("Public Subnets"):
                    pub_subnet_1a = PublicSubnet("Public 1a\n10.0.1.0/24")
                    pub_subnet_1b = PublicSubnet("Public 1b\n10.0.2.0/24")

                    # Load Balancer
                    alb = ELB("ALB\nPort 80")
                
                # NAT GATEWAY
                nat_gw = NATGateway("NAT Gateway")

                # PRIVATE SUBNETS
                with Cluster("Private Subnets"):
                    priv_subnet_1a = PrivateSubnet("Private 1a\n10.0.3.0/24")
                    priv_subnet_1b = PrivateSubnet("Private 1b\n10.0.4.0/24")
            
            # =============================================================================
            # SECURITY GROUPS (AUTO-CREATED)
            # =============================================================================
            with Cluster("🔒 Security Groups", graph_attr={"bgcolor": "#FFE8E8"}):
                cluster_sg = Firewall("Cluster SG")
                node_sg = Firewall("Node SG")
                pod_sg = Firewall("Pod SG")
                alb_sg = Firewall("ALB SG")
            
            # =============================================================================
            # EKS CLUSTER
            # =============================================================================
            with Cluster("☸️ EKS Cluster: healthcare-cluster", graph_attr={"bgcolor": "#E8F8E8"}):
                
                # EKS CONTROL PLANE
                eks_control_plane = EKS("EKS Control Plane\nv1.32")

                # MANAGED NODE GROUP
                with Cluster("Node Group"):
                    asg = AutoScaling("Auto Scaling\nMin:1 Max:4")

                    with Cluster("Worker Nodes"):
                        worker_node_1a = EC2("Worker 1a\nt3.medium")
                        worker_node_1b = EC2("Worker 1b\nt3.medium")
                
                # EBS VOLUMES
                with Cluster("Storage"):
                    ebs_1a = EBS("EBS 1a\n20GB")
                    ebs_1b = EBS("EBS 1b\n20GB")
            
            # =============================================================================
            # IAM ROLES (AUTO-CREATED)
            # =============================================================================
            with Cluster("🔐 IAM Roles", graph_attr={"bgcolor": "#F8E8F8"}):
                cluster_role = IAM("Cluster Role")
                node_role = IAM("Node Role")
                pod_role = IAM("Pod Role")
                alb_role = IAM("ALB Role")
            
            # =============================================================================
            # CLOUDFORMATION STACKS
            # =============================================================================
            with Cluster("📋 CloudFormation", graph_attr={"bgcolor": "#F0F0F0"}):
                cf_cluster = Cloudformation("Cluster Stack")
                cf_nodegroup = Cloudformation("NodeGroup Stack")
                cf_addon = Cloudformation("Addon Stack")
            
            # =============================================================================
            # MONITORING & LOGGING
            # =============================================================================
            with Cluster("📊 Monitoring", graph_attr={"bgcolor": "#E8FFE8"}):
                cloudwatch = Cloudwatch("CloudWatch")
                cloudtrail = Cloudtrail("CloudTrail")

        # =============================================================================
        # CONNECTIONS
        # =============================================================================
        
        # External Users → Load Balancer
        [web_users, mobile_users, tablet_users] >> Edge(label="HTTPS/HTTP", color="blue") >> alb
        
        # Internet Gateway → Public Subnets
        igw >> [pub_subnet_1a, pub_subnet_1b]
        
        # Load Balancer in Public Subnets
        alb >> [pub_subnet_1a, pub_subnet_1b]
        
        # NAT Gateway for Private Subnet Internet Access
        nat_gw >> [priv_subnet_1a, priv_subnet_1b]
        
        # Worker Nodes in Private Subnets
        worker_node_1a >> priv_subnet_1a
        worker_node_1b >> priv_subnet_1b
        
        # EBS Volumes attached to Worker Nodes
        worker_node_1a >> ebs_1a
        worker_node_1b >> ebs_1b
        
        # EKS Control Plane manages Worker Nodes
        eks_control_plane >> [worker_node_1a, worker_node_1b]
        
        # Auto Scaling Group manages Worker Nodes
        asg >> [worker_node_1a, worker_node_1b]
        
        # IAM Roles
        cluster_role >> eks_control_plane
        node_role >> [worker_node_1a, worker_node_1b]
        alb_role >> alb
        
        # CloudFormation Stacks
        cf_cluster >> eks_control_plane
        cf_nodegroup >> [worker_node_1a, worker_node_1b]
        
        # Monitoring
        cloudwatch >> [eks_control_plane, worker_node_1a, worker_node_1b]

def create_kubernetes_application_diagram():
    """Create Kubernetes application architecture diagram"""
    
    with Diagram(
        "Stage 1: Kubernetes Application Architecture",
        filename="Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/Stage-1-Architecture/stage1_k8s_application",
        show=False,
        direction="TB",
        graph_attr={
            "fontsize": "18",
            "bgcolor": "white",
            "pad": "1.0",
            "splines": "ortho"
        }
    ):
        
        # =============================================================================
        # EXTERNAL ACCESS
        # =============================================================================
        users = Users("Healthcare Users\nDoctors, Patients, Staff")
        
        # =============================================================================
        # KUBERNETES CLUSTER
        # =============================================================================
        with Cluster("☸️ Kubernetes Cluster: healthcare-cluster", graph_attr={"bgcolor": "#E8F4FD"}):
            
            # =============================================================================
            # HEALTHCARE NAMESPACE
            # =============================================================================
            with Cluster("🏥 Namespace: healthcare", graph_attr={"bgcolor": "#F0F8FF"}):
                
                # =============================================================================
                # FRONTEND TIER
                # =============================================================================
                with Cluster("🌐 Frontend Tier", graph_attr={"bgcolor": "#E8FFE8"}):

                    frontend_deployment = Deployment("Frontend Deploy\n2 replicas")

                    with Cluster("Frontend Pods"):
                        frontend_pod_1 = Pod("frontend-1\nReact+Nginx")
                        frontend_pod_2 = Pod("frontend-2\nReact+Nginx")

                    frontend_service = Service("frontend-svc\nLoadBalancer")

                    # Load Balancer (AWS)
                    external_lb = ELB("AWS ALB\nExternal IP")
                
                # =============================================================================
                # BACKEND TIER
                # =============================================================================
                with Cluster("⚙️ Backend Tier", graph_attr={"bgcolor": "#FFF8E8"}):

                    backend_deployment = Deployment("Backend Deploy\n2 replicas")

                    with Cluster("Backend Pods"):
                        backend_pod_1 = Pod("backend-1\nNode.js+Prisma")
                        backend_pod_2 = Pod("backend-2\nNode.js+Prisma")

                    backend_service = Service("backend-svc\nClusterIP")
                
                # =============================================================================
                # DATABASE TIER
                # =============================================================================
                with Cluster("🗄️ Database Tier", graph_attr={"bgcolor": "#FFE8F8"}):

                    postgres_deployment = Deployment("PostgreSQL Deploy\n1 replica")

                    postgres_pod = Pod("postgres\nPostgreSQL 16")

                    postgres_service = Service("postgres-svc\nClusterIP")

                    # Persistent Storage
                    postgres_pvc = PVC("postgres-pvc\n10Gi")
                    postgres_pv = PV("postgres-pv\nEBS Volume")
                
                # =============================================================================
                # SERVICE ACCOUNTS & RBAC
                # =============================================================================
                with Cluster("🔐 Security & RBAC"):
                    default_sa = ServiceAccount("default\nService Account")
                    alb_sa = ServiceAccount("aws-load-balancer-controller\nService Account")
            
            # =============================================================================
            # KUBERNETES SYSTEM COMPONENTS
            # =============================================================================
            with Cluster("🔧 System Components", graph_attr={"bgcolor": "#F5F5F5"}):
                kube_dns = Pod("CoreDNS\nCluster DNS")
                aws_node = Pod("aws-node\nVPC CNI Plugin")
                kube_proxy = Pod("kube-proxy\nNetwork Proxy")
                alb_controller = Pod("aws-load-balancer-controller\nAWS Integration")
        
        # =============================================================================
        # CONNECTIONS
        # =============================================================================
        
        # External Users → Load Balancer → Frontend
        users >> Edge(label="HTTP/HTTPS", color="blue") >> external_lb
        external_lb >> frontend_service
        frontend_service >> [frontend_pod_1, frontend_pod_2]
        
        # Frontend → Backend
        frontend_pod_1 >> Edge(label="API Calls", color="green") >> backend_service
        frontend_pod_2 >> backend_service
        backend_service >> backend_pod_1
        backend_service >> backend_pod_2

        # Backend → Database
        backend_pod_1 >> Edge(label="SQL Queries", color="orange") >> postgres_service
        backend_pod_2 >> postgres_service
        postgres_service >> postgres_pod
        
        # Persistent Storage
        postgres_pod >> postgres_pvc >> postgres_pv
        
        # Deployments manage Pods
        frontend_deployment >> frontend_pod_1
        frontend_deployment >> frontend_pod_2
        backend_deployment >> backend_pod_1
        backend_deployment >> backend_pod_2
        postgres_deployment >> postgres_pod
        
        # Service Accounts
        default_sa >> frontend_pod_1
        default_sa >> frontend_pod_2
        default_sa >> backend_pod_1
        default_sa >> backend_pod_2
        default_sa >> postgres_pod
        alb_sa >> alb_controller
        
        # System Components
        alb_controller >> external_lb

def create_cost_optimization_diagram():
    """Create cost optimization and resource utilization diagram"""
    
    with Diagram(
        "Stage 1: Cost Optimization & Resource Utilization",
        filename="Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/Stage-1-Architecture/stage1_cost_optimization",
        show=False,
        direction="LR",
        graph_attr={
            "fontsize": "16",
            "bgcolor": "white",
            "pad": "1.0"
        }
    ):
        
        with Cluster("💰 Monthly Cost Breakdown (~$163)", graph_attr={"bgcolor": "#FFF8DC"}):
            
            with Cluster("Fixed Costs"):
                eks_cost = EKS("EKS Control Plane\n$73/month\n45% of total cost")
                
            with Cluster("Variable Costs"):
                ec2_cost = EC2("2x t3.medium\n$60/month\n37% of total cost")
                elb_cost = ELB("Load Balancer\n$20/month\n12% of total cost")
                storage_cost = EBS("Storage & Transfer\n$10/month\n6% of total cost")
        
        with Cluster("🎯 Cost Optimization Strategies", graph_attr={"bgcolor": "#E8F8E8"}):
            
            with Cluster("Development Optimization"):
                spot_instances = EC2("Spot Instances\n~60% savings\nDev/Test only")
                smaller_nodes = EC2("t3.small nodes\n~50% savings\nLower workloads")
                
            with Cluster("Operational Optimization"):
                auto_scaling = AutoScaling("Auto Scaling\nScale to zero\nOff-hours")
                scheduled_stop = Cloudwatch("Scheduled Stop\nWeekends/Nights\n~70% time savings")
        
        with Cluster("📊 Resource Utilization", graph_attr={"bgcolor": "#F0F8FF"}):
            
            with Cluster("Current Allocation"):
                cpu_usage = Storage("CPU: 2 vCPU/node\n~25% utilization")
                memory_usage = Storage("Memory: 4GB/node\n~40% utilization")
                storage_usage = Storage("Storage: 20GB/node\n~15% utilization")
            
            with Cluster("Optimization Potential"):
                right_sizing = Storage("Right-sizing\n~30% cost reduction")
                resource_limits = Storage("Resource Limits\n~20% efficiency gain")

if __name__ == "__main__":
    print("🎨 Generating Stage 1 AWS Architecture Diagrams...")
    print("🏗️  Creating AWS infrastructure diagram...")
    create_aws_infrastructure_diagram()
    print("☸️  Creating Kubernetes application diagram...")
    create_kubernetes_application_diagram()
    print("💰 Creating cost optimization diagram...")
    create_cost_optimization_diagram()
    print("✅ AWS architecture diagrams generated successfully!")
    print("📁 Location: Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/Stage-1-Architecture/")
    print("🖼️  Files:")
    print("   - stage1_aws_infrastructure.png")
    print("   - stage1_k8s_application.png")
    print("   - stage1_cost_optimization.png")
