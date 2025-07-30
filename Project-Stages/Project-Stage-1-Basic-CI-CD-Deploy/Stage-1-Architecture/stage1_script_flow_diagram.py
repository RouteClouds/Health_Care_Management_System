#!/usr/bin/env python3
"""
Stage 1 Script Flow Diagram as Code
Health Care Management System - Script Execution Workflow

This script generates a detailed diagram showing:
1. Script execution order
2. Prerequisites validation
3. Error handling paths
4. Success/failure flows
5. Cleanup procedures

Requirements:
    pip install diagrams pillow
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.programming.language import Python, Bash
from diagrams.aws.compute import EKS, EC2
from diagrams.aws.network import ELB
from diagrams.aws.management import Cloudformation
from diagrams.onprem.container import Docker
from diagrams.onprem.vcs import Github
from diagrams.k8s.compute import Pod
from diagrams.k8s.network import Service
from diagrams.generic.compute import Rack
from diagrams.generic.network import Firewall
from diagrams.generic.storage import Storage

def create_script_execution_flow():
    """Create detailed script execution flow diagram"""
    
    with Diagram(
        "Stage 1: Script Execution Flow & Decision Points",
        filename="Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/Stage-1-Architecture/stage1_script_execution_flow",
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
        # SCRIPT 1: SETUP-TOOLS.SH
        # =============================================================================
        with Cluster("🔧 Script 1: setup-tools.sh", graph_attr={"bgcolor": "#E8F4FD"}):
            
            start = Rack("START\nUser runs setup-tools.sh")
            
            with Cluster("Tool Verification"):
                check_docker = Firewall("Check Docker\n✅ Already Installed")
                check_kubectl = Python("Check kubectl v1.33.3\n✅ Perfect for EKS 1.32")
                check_aws = Python("Check AWS CLI v2.15.0+\n✅ Latest Version")
                check_eksctl = Python("Check eksctl 0.211.0\n✅ Latest Version")
                check_postgres = Storage("Check PostgreSQL 16.9\n✅ Matches Container")
            
            with Cluster("Validation Results"):
                all_good = Rack("✅ All Tools Compatible\nReady for EKS 1.32")
                need_config = Rack("⚠️ Need AWS Configure\nRun: aws configure")
                version_issue = Rack("❌ Version Incompatible\nSee troubleshooting guide")
            
            next_steps = Rack("Next: aws configure\nThen: create-eks-cluster.sh")

        # =============================================================================
        # SCRIPT 2: CREATE-EKS-CLUSTER.SH
        # =============================================================================
        with Cluster("☁️ Script 2: create-eks-cluster.sh", graph_attr={"bgcolor": "#E8F8E8"}):
            
            cluster_start = Rack("START\nUser runs create-eks-cluster.sh")
            
            with Cluster("Prerequisites Check"):
                check_aws_creds = Firewall("AWS Credentials\naws sts get-caller-identity")
                check_existing = EKS("Existing Cluster?\neksctl get cluster")
                check_permissions = Firewall("IAM Permissions\nHealthCare-EKS-Stage1-Policy")
            
            with Cluster("User Confirmation"):
                cost_warning = Rack("💰 Cost Warning\n~$163/month")
                user_confirm = Rack("User Confirmation\ntype 'yes' to proceed")
            
            with Cluster("Cluster Creation (15-20 min)"):
                eksctl_create = EKS("eksctl create cluster\n--version 1.32")
                cf_stacks = Cloudformation("CloudFormation Stacks\nInfrastructure Creation")
                kubectl_config = Python("kubectl Configuration\naws eks update-kubeconfig")
            
            with Cluster("Verification"):
                cluster_ready = EKS("✅ Cluster Ready\nkubectl cluster-info")
                nodes_ready = EC2("✅ Nodes Ready\nkubectl get nodes")
                version_check = Python("✅ Version Compatible\nkubectl version --short")
            
            cluster_success = Rack("SUCCESS\nReady for deployment")

        # =============================================================================
        # SCRIPT 3: DEPLOY-TO-EKS.SH
        # =============================================================================
        with Cluster("🚀 Script 3: deploy-to-eks.sh", graph_attr={"bgcolor": "#F8E8F8"}):
            
            deploy_start = Rack("START\nUser runs deploy-to-eks.sh")
            
            with Cluster("Deployment Prerequisites"):
                check_cluster = EKS("Cluster Access\nkubectl cluster-info")
                check_manifests = Storage("K8s Manifests\nk8s/ directory exists")
                check_images = Docker("Docker Images\nUpdate image names")
            
            with Cluster("Sequential Deployment"):
                deploy_namespace = Rack("1. Create Namespace\nkubectl apply namespace.yaml")
                deploy_db = Pod("2. Deploy Database\nPostgreSQL 16-alpine")
                deploy_backend = Pod("3. Deploy Backend\n2 replicas with health checks")
                deploy_frontend = Service("4. Deploy Frontend\nLoadBalancer service")
            
            with Cluster("Wait & Verify"):
                wait_pods = Pod("Wait for Pods\nkubectl wait --for=condition=available")
                check_services = Service("Check Services\nkubectl get services")
                get_external_ip = ELB("Get External IP\n5-10 minutes for LB")
            
            with Cluster("Health Validation"):
                test_access = Firewall("Test HTTP Access\ncurl external-ip")
                app_ready = Rack("✅ Application Ready\nAll components running")
            
            deploy_success = Rack("SUCCESS\nApplication deployed")

        # =============================================================================
        # SCRIPT 4: VERIFY-DEPLOYMENT.SH
        # =============================================================================
        with Cluster("✅ Script 4: verify-deployment.sh", graph_attr={"bgcolor": "#F0F8FF"}):
            
            verify_start = Rack("START\nUser runs verify-deployment.sh")
            
            with Cluster("Comprehensive Checks"):
                verify_cluster = EKS("Cluster Status\nkubectl cluster-info")
                verify_nodes = EC2("Node Status\nkubectl get nodes -o wide")
                verify_pods = Pod("Pod Status\nAll pods Running")
                verify_services = Service("Service Status\nEndpoints available")
            
            with Cluster("Application Testing"):
                test_frontend = Firewall("Frontend Access\nHTTP 200 response")
                test_api = Firewall("API Health\n/api/health endpoint")
                test_database = Storage("Database Connection\nPostgreSQL 16 ready")
            
            with Cluster("Performance Check"):
                resource_usage = Rack("Resource Usage\nkubectl top nodes/pods")
                response_time = Rack("Response Time\nApplication performance")
            
            verify_success = Rack("✅ VERIFICATION COMPLETE\nAll systems operational")

        # =============================================================================
        # SCRIPT 5: CLEANUP.SH
        # =============================================================================
        with Cluster("🗑️ Script 5: cleanup.sh", graph_attr={"bgcolor": "#FFE8E8"}):
            
            cleanup_start = Rack("START\nUser runs cleanup.sh")
            
            with Cluster("Safety Confirmation"):
                cost_reminder = Rack("💰 Cost Reminder\n$163/month if not cleaned")
                destruction_warning = Rack("⚠️ PERMANENT DELETION\nAll data will be lost")
                user_confirm_cleanup = Rack("User Confirmation\ntype 'yes' to proceed")
            
            with Cluster("Ordered Cleanup (Critical)"):
                delete_apps = Pod("1. Delete Applications\nkubectl delete namespace")
                wait_lb_cleanup = ELB("2. Wait for LB Cleanup\n5-10 minutes")
                delete_cluster = EKS("3. Delete EKS Cluster\neksctl delete cluster --wait")
                verify_cleanup = Cloudformation("4. Verify CF Stacks\nAll stacks deleted")
            
            with Cluster("Final Verification"):
                check_no_cluster = EKS("No EKS Clusters\neksctl get cluster")
                check_no_instances = EC2("No EC2 Instances\naws ec2 describe-instances")
                check_no_lb = ELB("No Load Balancers\naws elbv2 describe-load-balancers")
                check_billing = Rack("💰 Billing Check\n$0 ongoing charges")
            
            cleanup_success = Rack("✅ CLEANUP COMPLETE\nNo ongoing costs")

        # =============================================================================
        # WORKFLOW CONNECTIONS
        # =============================================================================
        
        # Script 1 Flow
        start >> check_docker
        start >> check_kubectl
        start >> check_aws
        start >> check_eksctl
        start >> check_postgres
        check_docker >> all_good
        check_kubectl >> all_good
        check_aws >> all_good
        check_eksctl >> all_good
        check_postgres >> all_good
        all_good >> next_steps
        
        # Script 1 → Script 2
        next_steps >> Edge(label="aws configure", style="bold", color="blue") >> cluster_start
        
        # Script 2 Flow
        cluster_start >> check_aws_creds
        cluster_start >> check_existing
        cluster_start >> check_permissions
        check_aws_creds >> cost_warning
        check_existing >> cost_warning
        check_permissions >> cost_warning
        cost_warning >> user_confirm
        user_confirm >> eksctl_create >> cf_stacks >> kubectl_config
        kubectl_config >> cluster_ready
        kubectl_config >> nodes_ready
        kubectl_config >> version_check
        cluster_ready >> cluster_success
        nodes_ready >> cluster_success
        version_check >> cluster_success
        
        # Script 2 → Script 3
        cluster_success >> Edge(label="Build & Push Images", style="bold", color="orange") >> deploy_start
        
        # Script 3 Flow
        deploy_start >> [check_cluster, check_manifests, check_images]
        [check_cluster, check_manifests, check_images] >> deploy_namespace
        deploy_namespace >> deploy_db >> deploy_backend >> deploy_frontend
        deploy_frontend >> wait_pods >> check_services >> get_external_ip
        get_external_ip >> test_access >> app_ready >> deploy_success
        
        # Script 3 → Script 4
        deploy_success >> Edge(label="Automatic", style="bold", color="green") >> verify_start
        
        # Script 4 Flow
        verify_start >> [verify_cluster, verify_nodes, verify_pods, verify_services]
        [verify_cluster, verify_nodes, verify_pods, verify_services] >> [test_frontend, test_api, test_database]
        [test_frontend, test_api, test_database] >> [resource_usage, response_time] >> verify_success
        
        # Script 4 → Script 5 (Optional)
        verify_success >> Edge(label="When Done Testing", style="dashed", color="red") >> cleanup_start
        
        # Script 5 Flow
        cleanup_start >> [cost_reminder, destruction_warning] >> user_confirm_cleanup
        user_confirm_cleanup >> delete_apps >> wait_lb_cleanup >> delete_cluster >> verify_cleanup
        verify_cleanup >> [check_no_cluster, check_no_instances, check_no_lb, check_billing] >> cleanup_success

def create_error_handling_diagram():
    """Create error handling and troubleshooting flow"""
    
    with Diagram(
        "Stage 1: Error Handling & Troubleshooting Flow",
        filename="Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/Stage-1-Architecture/stage1_error_handling",
        show=False,
        direction="TB",
        graph_attr={
            "fontsize": "16",
            "bgcolor": "white",
            "pad": "1.0"
        }
    ):
        
        with Cluster("🚨 Common Error Scenarios", graph_attr={"bgcolor": "#FFE8E8"}):
            
            with Cluster("Setup Errors"):
                version_mismatch = Rack("❌ Version Mismatch\nkubectl incompatible")
                aws_not_configured = Rack("❌ AWS Not Configured\nCredentials missing")
                permission_denied = Rack("❌ Permission Denied\nIAM policy missing")
            
            with Cluster("Deployment Errors"):
                image_pull_error = Docker("❌ ImagePullBackOff\nDocker Hub access")
                cluster_not_ready = EKS("❌ Cluster Not Ready\nEKS creation failed")
                pod_crash_loop = Pod("❌ CrashLoopBackOff\nApplication errors")
                external_ip_pending = ELB("❌ External IP Pending\nLoad balancer issues")
            
            with Cluster("Cleanup Errors"):
                stuck_resources = Cloudformation("❌ Stuck Resources\nCloudFormation issues")
                ongoing_charges = Rack("❌ Ongoing Charges\nIncomplete cleanup")
        
        with Cluster("🔧 Resolution Paths", graph_attr={"bgcolor": "#E8F8E8"}):
            
            with Cluster("Automated Solutions"):
                script_retry = Bash("Retry Script\nMost issues self-resolve")
                troubleshooting_guide = Storage("Troubleshooting Guide\ndocs/troubleshooting.md")
                verification_script = Python("Verification Script\nverify-deployment.sh")
            
            with Cluster("Manual Interventions"):
                aws_console = Rack("AWS Console\nManual resource check")
                kubectl_debug = Python("kubectl Debug\nPod logs and describe")
                force_cleanup = Bash("Force Cleanup\nManual resource deletion")

        # Error → Resolution Connections
        version_mismatch >> troubleshooting_guide
        aws_not_configured >> script_retry
        permission_denied >> troubleshooting_guide
        
        image_pull_error >> kubectl_debug
        cluster_not_ready >> aws_console
        pod_crash_loop >> kubectl_debug
        external_ip_pending >> verification_script
        
        stuck_resources >> force_cleanup
        ongoing_charges >> aws_console

if __name__ == "__main__":
    print("🎨 Generating Stage 1 Script Flow Diagrams...")
    print("📊 Creating script execution flow diagram...")
    create_script_execution_flow()
    print("🚨 Creating error handling diagram...")
    create_error_handling_diagram()
    print("✅ Script flow diagrams generated successfully!")
    print("📁 Location: Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/Stage-1-Architecture/")
    print("🖼️  Files:")
    print("   - stage1_script_execution_flow.png")
    print("   - stage1_error_handling.png")
