#!/usr/bin/env python3
"""
Stage-3 Architecture Diagrams Generator (Final Working Version)
Healthcare Management System - Advanced DevOps Implementation
"""

import os
import sys
from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import EKS, EC2
from diagrams.aws.database import RDS, ElastiCache
from diagrams.aws.network import VPC, ALB, Route53, CloudFront
from diagrams.aws.storage import S3
from diagrams.aws.security import SecretsManager, IAM
from diagrams.aws.management import Cloudwatch
from diagrams.k8s import K8S
from diagrams.onprem.monitoring import Prometheus, Grafana
from diagrams.onprem.logging import FluentBit
from diagrams.onprem.network import Istio
from diagrams.onprem.gitops import ArgoCD
from diagrams.onprem.client import Client
from diagrams.onprem.compute import Server
from diagrams.onprem.database import PostgreSQL
from diagrams.onprem.inmemory import Redis
from diagrams.onprem.network import Internet
from diagrams.onprem.security import Vault
from diagrams.onprem.ci import GithubActions
from diagrams.onprem.vcs import Git
from diagrams.onprem.iac import Terraform
from diagrams.onprem.container import Helm
from diagrams.onprem.network import Nginx
from diagrams.onprem.compute import Docker
from diagrams.onprem.security import Trivy
from diagrams.onprem.analytics import Metabase

# Set output directory
OUTPUT_DIR = "generated_diagrams"
os.makedirs(OUTPUT_DIR, exist_ok=True)

def generate_overall_architecture():
    """Generate the overall Stage-3 architecture diagram"""
    
    with Diagram("Stage-3 Overall Architecture", 
                 filename=f"{OUTPUT_DIR}/01_overall_architecture",
                 show=False,
                 direction="TB",
                 graph_attr={"rankdir": "TB", "splines": "ortho", "nodesep": "0.8", "ranksep": "1.0"}):
        
        # External components
        internet = Internet("Internet")
        client = Client("End Users")
        git_repo = Git("Git Repository")
        
        # AWS Infrastructure
        with Cluster("AWS Cloud Infrastructure"):
            with Cluster("Global Services"):
                route53 = Route53("Route 53\n(DNS)")
                cloudfront = CloudFront("CloudFront\n(CDN)")
                s3 = S3("S3\n(Static Assets)")
            
            with Cluster("VPC - Multi-AZ"):
                with Cluster("Public Subnets"):
                    alb = ALB("Application\nLoad Balancer")
                
                with Cluster("Private Subnets"):
                    with Cluster("EKS Cluster"):
                        with Cluster("Istio Service Mesh"):
                            istio_gateway = Istio("Istio Gateway")
                            istio_control = Istio("Istio Control Plane")
                        
                        with Cluster("Application Pods"):
                            frontend = K8S("Frontend\n(React)")
                            backend = K8S("Backend\n(Node.js)")
                            nginx = Nginx("Nginx\n(Reverse Proxy)")
                        
                        with Cluster("DevOps Tools"):
                            argocd = ArgoCD("ArgoCD\n(GitOps)")
                            prometheus = Prometheus("Prometheus\n(Metrics)")
                            grafana = Grafana("Grafana\n(Dashboards)")
                            jaeger = Server("Jaeger\n(Tracing)")
                        
                        with Cluster("Logging Stack"):
                            elasticsearch = Server("Elasticsearch\n(Log Storage)")
                            kibana = Server("Kibana\n(Log Analytics)")
                            fluentd = FluentBit("FluentBit\n(Log Aggregation)")
                
                with Cluster("Data Layer"):
                    rds = RDS("RDS PostgreSQL\n(Multi-AZ)")
                    redis = ElastiCache("ElastiCache Redis\n(Caching)")
                
                with Cluster("Security & Management"):
                    secrets = SecretsManager("Secrets Manager")
                    cloudwatch = Cloudwatch("CloudWatch\n(Monitoring)")
                    iam = IAM("IAM\n(Access Control)")
        
        # CI/CD Pipeline
        with Cluster("CI/CD Pipeline"):
            github_actions = GithubActions("GitHub Actions\n(CI/CD)")
            terraform = Terraform("Terraform\n(IaC)")
            helm = Helm("Helm\n(K8s Charts)")
            trivy = Trivy("Trivy\n(Security)")
            sonarqube = Server("SonarQube\n(Quality)")
        
        # Connections
        client >> internet
        internet >> route53
        route53 >> cloudfront
        cloudfront >> s3
        cloudfront >> alb
        
        alb >> istio_gateway
        istio_gateway >> frontend
        istio_gateway >> backend
        frontend >> backend
        backend >> nginx
        nginx >> rds
        backend >> redis
        
        # Monitoring connections
        prometheus >> frontend
        prometheus >> backend
        prometheus >> rds
        grafana >> prometheus
        jaeger >> frontend
        jaeger >> backend
        
        # Logging connections
        fluentd >> frontend
        fluentd >> backend
        fluentd >> elasticsearch
        kibana >> elasticsearch
        
        # GitOps
        git_repo >> github_actions
        github_actions >> terraform
        github_actions >> helm
        argocd >> git_repo
        argocd >> frontend
        argocd >> backend
        
        # Security
        secrets >> backend
        secrets >> rds
        iam >> alb
        iam >> rds

def generate_infrastructure_diagram():
    """Generate detailed infrastructure diagram"""
    
    with Diagram("Stage-3 Infrastructure Architecture", 
                 filename=f"{OUTPUT_DIR}/02_infrastructure_architecture",
                 show=False,
                 direction="TB",
                 graph_attr={"rankdir": "TB", "splines": "ortho", "nodesep": "1.0", "ranksep": "1.2"}):
        
        with Cluster("AWS Global Infrastructure"):
            with Cluster("Route 53 (DNS)"):
                route53 = Route53("Primary DNS")
                route53_failover = Route53("Failover DNS")
            
            with Cluster("CloudFront (CDN)"):
                cf_edge = CloudFront("Edge Location 1")
                cf_edge2 = CloudFront("Edge Location 2")
                cf_origin = CloudFront("Origin")
            
            with Cluster("S3 Storage"):
                s3_static = S3("Static Assets")
                s3_logs = S3("Access Logs")
                s3_backup = S3("Backups")
        
        with Cluster("VPC - us-east-1"):
            with Cluster("Public Subnets (AZ-a, AZ-b)"):
                with Cluster("Internet Gateway"):
                    igw = Internet("IGW")
                
                with Cluster("NAT Gateway"):
                    nat_a = EC2("NAT Gateway AZ-a")
                    nat_b = EC2("NAT Gateway AZ-b")
                
                with Cluster("Application Load Balancer"):
                    alb = ALB("ALB")
                    alb_target1 = ALB("Target Group 1")
                    alb_target2 = ALB("Target Group 2")
            
            with Cluster("Private Subnets (AZ-a, AZ-b)"):
                with Cluster("EKS Cluster"):
                    with Cluster("Control Plane"):
                        eks_cp = EKS("EKS Control Plane")
                    
                    with Cluster("Worker Nodes AZ-a"):
                        node1 = EC2("Worker Node 1")
                        node2 = EC2("Worker Node 2")
                    
                    with Cluster("Worker Nodes AZ-b"):
                        node3 = EC2("Worker Node 3")
                        node4 = EC2("Worker Node 4")
                
                with Cluster("RDS PostgreSQL (Multi-AZ)"):
                    rds_primary = RDS("Primary DB\n(AZ-a)")
                    rds_replica = RDS("Read Replica\n(AZ-b)")
                    rds_backup = RDS("Backup Storage")
                
                with Cluster("ElastiCache Redis"):
                    redis_primary = ElastiCache("Primary Cache\n(AZ-a)")
                    redis_replica = ElastiCache("Replica Cache\n(AZ-b)")
            
            with Cluster("Security Groups"):
                sg_alb = IAM("ALB Security Group")
                sg_eks = IAM("EKS Security Group")
                sg_rds = IAM("RDS Security Group")
                sg_redis = IAM("Redis Security Group")
        
        # Connections
        route53 >> cf_edge
        route53 >> cf_edge2
        cf_edge >> cf_origin
        cf_edge2 >> cf_origin
        cf_origin >> s3_static
        
        igw >> nat_a
        igw >> nat_b
        nat_a >> alb
        nat_b >> alb
        
        alb >> alb_target1
        alb >> alb_target2
        alb_target1 >> node1
        alb_target1 >> node2
        alb_target2 >> node3
        alb_target2 >> node4
        
        node1 >> rds_primary
        node2 >> rds_primary
        node3 >> rds_replica
        node4 >> rds_replica
        rds_primary >> rds_replica
        
        node1 >> redis_primary
        node2 >> redis_primary
        node3 >> redis_replica
        node4 >> redis_replica
        redis_primary >> redis_replica

def generate_cicd_pipeline_diagram():
    """Generate CI/CD pipeline diagram"""
    
    with Diagram("Stage-3 CI/CD Pipeline", 
                 filename=f"{OUTPUT_DIR}/03_cicd_pipeline",
                 show=False,
                 direction="LR",
                 graph_attr={"rankdir": "LR", "splines": "ortho", "nodesep": "1.0", "ranksep": "1.5"}):
        
        with Cluster("Source Code Management"):
            git_repo = Git("GitHub Repository")
            git_webhook = Git("Webhook Trigger")
        
        with Cluster("CI/CD Platform"):
            github_actions = GithubActions("GitHub Actions")
        
        with Cluster("Security & Quality Gates"):
            trivy = Trivy("Trivy\n(Vulnerability Scan)")
            sonarqube = Server("SonarQube\n(Code Quality)")
            trivy_image = Trivy("Trivy\n(Image Scan)")
        
        with Cluster("Testing Pipeline"):
            unit_tests = Server("Unit Tests\n(Jest)")
            integration_tests = Server("Integration Tests\n(API)")
            e2e_tests = Server("E2E Tests\n(Selenium)")
            performance_tests = Server("Performance Tests\n(Load)")
        
        with Cluster("Infrastructure as Code"):
            terraform_plan = Terraform("Terraform Plan")
            terraform_apply = Terraform("Terraform Apply")
            terraform_destroy = Terraform("Terraform Destroy")
        
        with Cluster("Container Build"):
            docker_build = Docker("Docker Build")
            docker_push = Docker("Docker Push")
            registry = Docker("Container Registry")
        
        with Cluster("Deployment"):
            helm_package = Helm("Helm Package")
            argocd_sync = ArgoCD("ArgoCD Sync")
            kubectl_apply = K8S("kubectl Apply")
        
        with Cluster("Environments"):
            dev_env = K8S("Development")
            staging_env = K8S("Staging")
            prod_env = K8S("Production")
        
        with Cluster("Monitoring & Validation"):
            prometheus = Prometheus("Prometheus")
            grafana = Grafana("Grafana")
            jaeger = Server("Jaeger")
            health_check = Server("Health Check")
        
        # Pipeline flow
        git_repo >> git_webhook
        git_webhook >> github_actions
        
        github_actions >> trivy
        github_actions >> sonarqube
        github_actions >> unit_tests
        github_actions >> integration_tests
        
        unit_tests >> docker_build
        integration_tests >> docker_build
        
        docker_build >> trivy_image
        trivy_image >> docker_push
        docker_push >> registry
        
        registry >> e2e_tests
        e2e_tests >> performance_tests
        
        performance_tests >> terraform_plan
        terraform_plan >> terraform_apply
        
        terraform_apply >> helm_package
        helm_package >> argocd_sync
        
        argocd_sync >> dev_env
        dev_env >> staging_env
        staging_env >> prod_env
        
        prod_env >> prometheus
        prod_env >> grafana
        prod_env >> jaeger
        prod_env >> health_check

def generate_monitoring_observability_diagram():
    """Generate monitoring and observability diagram"""
    
    with Diagram("Stage-3 Monitoring & Observability", 
                 filename=f"{OUTPUT_DIR}/04_monitoring_observability",
                 show=False,
                 direction="TB",
                 graph_attr={"rankdir": "TB", "splines": "ortho", "nodesep": "1.0", "ranksep": "1.2"}):
        
        with Cluster("Application Layer"):
            frontend = K8S("Frontend App")
            backend = K8S("Backend API")
            database = PostgreSQL("PostgreSQL")
            cache = Redis("Redis Cache")
        
        with Cluster("Metrics Collection"):
            prometheus = Prometheus("Prometheus\n(Metrics Server)")
            node_exporter = Prometheus("Node Exporter\n(System Metrics)")
            cadvisor = Prometheus("cAdvisor\n(Container Metrics)")
            kube_state = Prometheus("kube-state-metrics\n(K8s Metrics)")
        
        with Cluster("Distributed Tracing"):
            jaeger_collector = Server("Jaeger Collector")
            jaeger_query = Server("Jaeger Query")
            jaeger_storage = Server("Jaeger Storage")
            opentelemetry = Server("OpenTelemetry\n(Instrumentation)")
        
        with Cluster("Logging Stack"):
            fluentd = FluentBit("FluentBit\n(Log Collector)")
            elasticsearch = Server("Elasticsearch\n(Log Storage)")
            kibana = Server("Kibana\n(Log Analytics)")
            logstash = FluentBit("FluentBit\n(Log Processing)")
        
        with Cluster("Visualization & Alerting"):
            grafana = Grafana("Grafana\n(Dashboards)")
            alertmanager = Prometheus("AlertManager\n(Alerting)")
            pagerduty = Server("PagerDuty\n(Incident Mgmt)")
            slack = Server("Slack\n(Notifications)")
        
        with Cluster("AWS Native Monitoring"):
            cloudwatch = Cloudwatch("CloudWatch\n(Metrics)")
            cloudwatch_logs = Cloudwatch("CloudWatch Logs")
            cloudwatch_alarms = Cloudwatch("CloudWatch Alarms")
        
        # Metrics flow
        frontend >> opentelemetry
        backend >> opentelemetry
        database >> opentelemetry
        cache >> opentelemetry
        
        opentelemetry >> prometheus
        node_exporter >> prometheus
        cadvisor >> prometheus
        kube_state >> prometheus
        
        prometheus >> grafana
        prometheus >> alertmanager
        
        # Tracing flow
        frontend >> jaeger_collector
        backend >> jaeger_collector
        jaeger_collector >> jaeger_storage
        jaeger_query >> jaeger_storage
        jaeger_query >> grafana
        
        # Logging flow
        frontend >> fluentd
        backend >> fluentd
        database >> fluentd
        cache >> fluentd
        
        fluentd >> logstash
        logstash >> elasticsearch
        elasticsearch >> kibana
        elasticsearch >> grafana
        
        # Alerting flow
        alertmanager >> pagerduty
        alertmanager >> slack
        alertmanager >> cloudwatch_alarms
        
        # AWS integration
        cloudwatch >> grafana
        cloudwatch_logs >> elasticsearch

def generate_gitops_workflow_diagram():
    """Generate GitOps workflow diagram"""
    
    with Diagram("Stage-3 GitOps Workflow", 
                 filename=f"{OUTPUT_DIR}/05_gitops_workflow",
                 show=False,
                 direction="TB",
                 graph_attr={"rankdir": "TB", "splines": "ortho", "nodesep": "1.0", "ranksep": "1.2"}):
        
        with Cluster("Git Repositories"):
            app_repo = Git("Application Repo\n(Source Code)")
            config_repo = Git("Config Repo\n(K8s Manifests)")
            helm_repo = Git("Helm Repo\n(Charts)")
            terraform_repo = Git("Terraform Repo\n(IaC)")
        
        with Cluster("CI Pipeline"):
            github_actions = GithubActions("GitHub Actions")
            terraform = Terraform("Terraform")
            helm = Helm("Helm")
            docker = Docker("Docker")
        
        with Cluster("ArgoCD (GitOps Controller)"):
            argocd_server = ArgoCD("ArgoCD Server")
            argocd_repo = ArgoCD("Repo Server")
            argocd_app = ArgoCD("Application Controller")
        
        with Cluster("Kubernetes Clusters"):
            with Cluster("Development"):
                dev_cluster = K8S("Dev Cluster")
                dev_apps = K8S("Dev Applications")
            
            with Cluster("Staging"):
                staging_cluster = K8S("Staging Cluster")
                staging_apps = K8S("Staging Applications")
            
            with Cluster("Production"):
                prod_cluster = K8S("Production Cluster")
                prod_apps = K8S("Production Applications")
        
        with Cluster("Monitoring & Validation"):
            prometheus = Prometheus("Prometheus")
            grafana = Grafana("Grafana")
            health_check = Server("Health Check")
        
        # GitOps flow
        app_repo >> github_actions
        config_repo >> argocd_server
        helm_repo >> argocd_server
        terraform_repo >> github_actions
        
        github_actions >> terraform
        github_actions >> helm
        github_actions >> docker
        
        terraform >> dev_cluster
        terraform >> staging_cluster
        terraform >> prod_cluster
        
        argocd_server >> argocd_repo
        argocd_repo >> argocd_app
        
        argocd_app >> dev_apps
        argocd_app >> staging_apps
        argocd_app >> prod_apps
        
        dev_apps >> prometheus
        staging_apps >> prometheus
        prod_apps >> prometheus
        
        prometheus >> grafana
        prod_apps >> health_check

def generate_service_mesh_diagram():
    """Generate Istio service mesh diagram"""
    
    with Diagram("Stage-3 Istio Service Mesh", 
                 filename=f"{OUTPUT_DIR}/06_service_mesh",
                 show=False,
                 direction="TB",
                 graph_attr={"rankdir": "TB", "splines": "ortho", "nodesep": "1.0", "ranksep": "1.2"}):
        
        with Cluster("External Traffic"):
            internet = Internet("Internet")
            alb = ALB("Application Load Balancer")
        
        with Cluster("Istio Gateway"):
            gateway = Istio("Istio Gateway")
            ingress = Istio("Ingress Gateway")
        
        with Cluster("Istio Control Plane"):
            pilot = Istio("Pilot\n(Service Discovery)")
            citadel = Istio("Citadel\n(Security)")
            galley = Istio("Galley\n(Configuration)")
            mixer = Istio("Mixer\n(Telemetry)")
        
        with Cluster("Application Services"):
            with Cluster("Frontend Service"):
                frontend = K8S("Frontend Pod")
                frontend_proxy = Istio("Envoy Proxy")
            
            with Cluster("Backend Service"):
                backend = K8S("Backend Pod")
                backend_proxy = Istio("Envoy Proxy")
            
            with Cluster("Database Service"):
                database = PostgreSQL("Database Pod")
                db_proxy = Istio("Envoy Proxy")
        
        with Cluster("Traffic Management"):
            virtual_service = Istio("Virtual Service")
            destination_rule = Istio("Destination Rule")
            service_entry = Istio("Service Entry")
        
        with Cluster("Security"):
            authorization_policy = Istio("Authorization Policy")
            peer_authentication = Istio("Peer Authentication")
            request_authentication = Istio("Request Authentication")
        
        with Cluster("Observability"):
            prometheus = Prometheus("Prometheus")
            grafana = Grafana("Grafana")
            jaeger = Server("Jaeger")
            kiali = Istio("Kiali\n(Service Mesh UI)")
        
        # Traffic flow
        internet >> alb
        alb >> gateway
        gateway >> ingress
        
        ingress >> virtual_service
        virtual_service >> destination_rule
        
        destination_rule >> frontend_proxy
        destination_rule >> backend_proxy
        
        frontend_proxy >> frontend
        backend_proxy >> backend
        backend_proxy >> db_proxy
        db_proxy >> database
        
        # Control plane
        pilot >> frontend_proxy
        pilot >> backend_proxy
        pilot >> db_proxy
        
        citadel >> authorization_policy
        citadel >> peer_authentication
        citadel >> request_authentication
        
        galley >> virtual_service
        galley >> destination_rule
        
        mixer >> prometheus
        mixer >> jaeger
        
        # Observability
        frontend_proxy >> prometheus
        backend_proxy >> prometheus
        db_proxy >> prometheus
        
        prometheus >> grafana
        prometheus >> kiali
        jaeger >> kiali

def generate_security_architecture_diagram():
    """Generate security architecture diagram"""
    
    with Diagram("Stage-3 Security Architecture", 
                 filename=f"{OUTPUT_DIR}/07_security_architecture",
                 show=False,
                 direction="TB",
                 graph_attr={"rankdir": "TB", "splines": "ortho", "nodesep": "1.0", "ranksep": "1.2"}):
        
        with Cluster("External Security"):
            internet = Internet("Internet")
            waf = ALB("AWS WAF\n(Web Application Firewall)")
            shield = IAM("AWS Shield\n(DDoS Protection)")
        
        with Cluster("Network Security"):
            vpc = VPC("VPC")
            with Cluster("Security Groups"):
                sg_alb = IAM("ALB Security Group")
                sg_eks = IAM("EKS Security Group")
                sg_rds = IAM("RDS Security Group")
                sg_redis = IAM("Redis Security Group")
            
            with Cluster("Network ACLs"):
                nacl_public = IAM("Public NACL")
                nacl_private = IAM("Private NACL")
        
        with Cluster("Identity & Access Management"):
            iam = IAM("IAM")
            with Cluster("IAM Roles"):
                eks_role = IAM("EKS Role")
                rds_role = IAM("RDS Role")
                lambda_role = IAM("Lambda Role")
            
            with Cluster("IAM Policies"):
                eks_policy = IAM("EKS Policy")
                rds_policy = IAM("RDS Policy")
                s3_policy = IAM("S3 Policy")
        
        with Cluster("Secrets Management"):
            secrets_manager = SecretsManager("AWS Secrets Manager")
            vault = Vault("HashiCorp Vault")
            k8s_secrets = K8S("Kubernetes Secrets")
            external_secrets = K8S("External Secrets Operator")
        
        with Cluster("Container Security"):
            trivy = Trivy("Trivy\n(Container Scanning)")
            falco = Server("Falco\n(Runtime Security)")
            opa_gatekeeper = Server("OPA Gatekeeper\n(Policy Enforcement)")
            pod_security = K8S("Pod Security Standards")
        
        with Cluster("Application Security"):
            with Cluster("API Security"):
                api_gateway = ALB("API Gateway")
                rate_limiting = Server("Rate Limiting")
                authentication = Server("JWT Authentication")
                authorization = Server("RBAC Authorization")
            
            with Cluster("Data Security"):
                encryption_at_rest = IAM("Encryption at Rest")
                encryption_in_transit = IAM("Encryption in Transit")
                data_classification = IAM("Data Classification")
        
        with Cluster("Monitoring & Compliance"):
            cloudtrail = Cloudwatch("CloudTrail\n(Audit Logs)")
            config = Cloudwatch("AWS Config\n(Compliance)")
            guardduty = Cloudwatch("GuardDuty\n(Threat Detection)")
            security_hub = Cloudwatch("Security Hub\n(Security Findings)")
        
        # Security flow
        internet >> waf
        internet >> shield
        waf >> vpc
        
        vpc >> sg_alb
        sg_alb >> sg_eks
        sg_eks >> sg_rds
        sg_eks >> sg_redis
        
        iam >> eks_role
        iam >> rds_role
        iam >> lambda_role
        
        eks_role >> eks_policy
        rds_role >> rds_policy
        lambda_role >> s3_policy
        
        secrets_manager >> external_secrets
        vault >> external_secrets
        external_secrets >> k8s_secrets
        
        trivy >> falco
        falco >> opa_gatekeeper
        opa_gatekeeper >> pod_security
        
        api_gateway >> rate_limiting
        rate_limiting >> authentication
        authentication >> authorization
        
        encryption_at_rest >> encryption_in_transit
        encryption_in_transit >> data_classification
        
        cloudtrail >> config
        config >> guardduty
        guardduty >> security_hub

def generate_performance_scaling_diagram():
    """Generate performance and scaling diagram"""
    
    with Diagram("Stage-3 Performance & Scaling", 
                 filename=f"{OUTPUT_DIR}/08_performance_scaling",
                 show=False,
                 direction="TB",
                 graph_attr={"rankdir": "TB", "splines": "ortho", "nodesep": "1.0", "ranksep": "1.2"}):
        
        with Cluster("Load Distribution"):
            cloudfront = CloudFront("CloudFront\n(CDN)")
            alb = ALB("Application Load Balancer")
            with Cluster("Target Groups"):
                tg_frontend = ALB("Frontend TG")
                tg_backend = ALB("Backend TG")
        
        with Cluster("Auto Scaling"):
            with Cluster("Horizontal Pod Autoscaler (HPA)"):
                hpa_frontend = K8S("Frontend HPA")
                hpa_backend = K8S("Backend HPA")
                hpa_metrics = Prometheus("HPA Metrics")
            
            with Cluster("Vertical Pod Autoscaler (VPA)"):
                vpa_frontend = K8S("Frontend VPA")
                vpa_backend = K8S("Backend VPA")
            
            with Cluster("Cluster Autoscaler"):
                cluster_autoscaler = K8S("Cluster Autoscaler")
                node_groups = EC2("Node Groups")
        
        with Cluster("Application Layer"):
            with Cluster("Frontend Service"):
                frontend_pod1 = K8S("Frontend Pod 1")
                frontend_pod2 = K8S("Frontend Pod 2")
                frontend_pod3 = K8S("Frontend Pod 3")
            
            with Cluster("Backend Service"):
                backend_pod1 = K8S("Backend Pod 1")
                backend_pod2 = K8S("Backend Pod 2")
                backend_pod3 = K8S("Backend Pod 3")
                backend_pod4 = K8S("Backend Pod 4")
        
        with Cluster("Caching Layer"):
            redis_primary = ElastiCache("Redis Primary")
            redis_replica1 = ElastiCache("Redis Replica 1")
            redis_replica2 = ElastiCache("Redis Replica 2")
            redis_replica3 = ElastiCache("Redis Replica 3")
        
        with Cluster("Database Layer"):
            rds_primary = RDS("RDS Primary")
            rds_replica1 = RDS("RDS Replica 1")
            rds_replica2 = RDS("RDS Replica 2")
            rds_read_cluster = RDS("Read Cluster")
        
        with Cluster("Performance Monitoring"):
            prometheus = Prometheus("Prometheus")
            grafana = Grafana("Grafana")
            with Cluster("Performance Metrics"):
                response_time = Server("Response Time")
                throughput = Server("Throughput")
                error_rate = Server("Error Rate")
                resource_usage = Server("Resource Usage")
        
        # Scaling flow
        cloudfront >> alb
        alb >> tg_frontend
        alb >> tg_backend
        
        tg_frontend >> frontend_pod1
        tg_frontend >> frontend_pod2
        tg_frontend >> frontend_pod3
        
        tg_backend >> backend_pod1
        tg_backend >> backend_pod2
        tg_backend >> backend_pod3
        tg_backend >> backend_pod4
        
        # Auto scaling
        hpa_metrics >> hpa_frontend
        hpa_metrics >> hpa_backend
        hpa_frontend >> frontend_pod1
        hpa_frontend >> frontend_pod2
        hpa_frontend >> frontend_pod3
        hpa_backend >> backend_pod1
        hpa_backend >> backend_pod2
        hpa_backend >> backend_pod3
        hpa_backend >> backend_pod4
        
        vpa_frontend >> frontend_pod1
        vpa_backend >> backend_pod1
        
        cluster_autoscaler >> node_groups
        
        # Caching
        backend_pod1 >> redis_primary
        backend_pod2 >> redis_primary
        backend_pod3 >> redis_replica1
        backend_pod4 >> redis_replica2
        
        redis_primary >> redis_replica1
        redis_primary >> redis_replica2
        redis_primary >> redis_replica3
        
        # Database
        backend_pod1 >> rds_primary
        backend_pod2 >> rds_primary
        backend_pod3 >> rds_replica1
        backend_pod4 >> rds_replica2
        
        rds_primary >> rds_replica1
        rds_primary >> rds_replica2
        rds_replica1 >> rds_read_cluster
        rds_replica2 >> rds_read_cluster
        
        # Monitoring
        frontend_pod1 >> prometheus
        backend_pod1 >> prometheus
        redis_primary >> prometheus
        rds_primary >> prometheus
        
        prometheus >> grafana
        prometheus >> response_time
        prometheus >> throughput
        prometheus >> error_rate
        prometheus >> resource_usage

def main():
    """Generate all Stage-3 architecture diagrams"""
    print("🚀 Generating Stage-3 Architecture Diagrams...")
    
    try:
        # Generate all diagrams
        print("📊 1. Overall Architecture...")
        generate_overall_architecture()
        
        print("🏗️ 2. Infrastructure Architecture...")
        generate_infrastructure_diagram()
        
        print("🔄 3. CI/CD Pipeline...")
        generate_cicd_pipeline_diagram()
        
        print("📈 4. Monitoring & Observability...")
        generate_monitoring_observability_diagram()
        
        print("🎯 5. GitOps Workflow...")
        generate_gitops_workflow_diagram()
        
        print("🔗 6. Service Mesh (Istio)...")
        generate_service_mesh_diagram()
        
        print("🔒 7. Security Architecture...")
        generate_security_architecture_diagram()
        
        print("⚡ 8. Performance & Scaling...")
        generate_performance_scaling_diagram()
        
        print(f"✅ All diagrams generated successfully in '{OUTPUT_DIR}' directory!")
        print("\n📋 Generated Diagrams:")
        print("1. 01_overall_architecture.png - Complete Stage-3 architecture")
        print("2. 02_infrastructure_architecture.png - Detailed infrastructure")
        print("3. 03_cicd_pipeline.png - CI/CD workflow")
        print("4. 04_monitoring_observability.png - Monitoring stack")
        print("5. 05_gitops_workflow.png - GitOps deployment")
        print("6. 06_service_mesh.png - Istio service mesh")
        print("7. 07_security_architecture.png - Security framework")
        print("8. 08_performance_scaling.png - Performance optimization")
        
    except Exception as e:
        print(f"❌ Error generating diagrams: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main() 