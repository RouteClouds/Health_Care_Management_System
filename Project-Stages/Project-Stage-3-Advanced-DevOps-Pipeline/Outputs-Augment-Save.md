Plan: Full teardown and clean rebuild to eliminate ALB controller IAM issues
You asked for a reliable, repeatable destruction-and-rebuild process. I reviewed your destruction guide and scripts, analyzed gaps, and implemented script upgrades to ensure complete cleanup of stubborn resources (especially IAM and ELBv2 artifacts), plus a rebuild plan that bakes in the fixes we learned.

Below is the concise summary and step-by-step execution guide.

What I reviewed
Stage-3 destruction guide: Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/Stage-3-Destruction-Guide.md
Cleanup scripts: Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/scripts/cleanup
Complete destroy script: destroy-complete-infrastructure.sh
Infrastructure components to destroy
EKS cluster: healthcare-eks-stage3-dev
Nodegroups and associated ASGs
RDS instance and DB subnet group(s)
VPCs and all networking components: subnets, route tables, IGWs, NAT GWs, NACLs, endpoints
ALBs/CLBs and ELBv2 target groups/listeners
Security groups
IAM roles, policies, inline policies, OIDC providers (ALB controller role included)
ECR repos and images
S3 Terraform backend bucket and any stage3 buckets
DynamoDB (state lock)
CloudFormation stacks created by eksctl or ancillary tooling
Duplicate/orphaned resources from prior failed runs
Enhancements I implemented
I upgraded destroy-complete-infrastructure.sh to make cleanup robust and comprehensive, focusing on ELBv2 and IAM/IRSA artifacts that often linger and cause permission drift:

ELBv2 target groups cleanup, after ALB deletion
New Phase 2.1 deletes orphaned target groups that block future ALB provisioning.
VPC catch-all networking cleanup
Delete VPC endpoints and non-default NACLs, and catch-all NAT gateways within each VPC.
Dedicated IAM cleanup phase (8.5)
Deletes the ALB controller role (AmazonEKSLoadBalancerControllerRole) after detaching attached and deleting inline policies
Deletes local customer-managed policies like AWSLoadBalancerControllerIAMPolicy and ALBControllerExtraPermissions (clean policy versions, then delete)
Deletes EKS OIDC providers in the region matching oidc.eks.$REGION.amazonaws.com
Destruction order improvements
Calls new phases in dependency order:
Load balancers
Target groups
EKS cluster
RDS
ECR
S3
CloudFormation
Terraform destroy
IAM resources
NAT/EIPs
VPC/networking
This order avoids dependency conflicts and ensures IAM artifacts are fully removed before tearing down the final networking layer.

Where to find the changes:

Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/scripts/cleanup/destroy-complete-infrastructure.sh
Rebuild strategy
When you’re ready to rebuild:

AWS Load Balancer Controller IAM:
Create ALB Controller role with the latest upstream IAM policy
Attach an explicit inline policy allowing:
elasticloadbalancing:DescribeListenerAttributes
elasticloadbalancing:DescribeListeners
elasticloadbalancing:DescribeLoadBalancerAttributes
Create IRSA service account and annotate with the role ARN
Only then deploy the Helm chart
Kubernetes Ingress:
Use explicit spec.ingressClassName: alb
Keep annotations and service routing
Ensure ingress.yaml routes:
/ -> frontend-stage3-svc:80
/api -> backend-stage3-svc:3001
Pipeline validations:
Wait for Ingress Address
Fallback only if necessary and log diagnostics
For health checks, test http://ALB_DNS/api/health and dump backend pod logs on failure
Lessons applied:

IAM propagation delays are real—add waits and verify after changes
Delete/recreate both service account and IAM role to avoid stale cached permissions
ELBv2 target groups must be cleaned up between runs to avoid collisions
Step-by-step execution plan
A) Destruction (safe process)

Backup anything needed (optional)
Follow “Data Backup Procedures” and “Configuration Backup” in Stage-3-Destruction-Guide.md if you need backups.
Run automated destruction
Navigate to Stage-3 folder:
cd Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline
Dry run first (recommended):
./scripts/cleanup/destroy-complete-infrastructure.sh true
Live run:
./scripts/cleanup/destroy-complete-infrastructure.sh
Confirm prompts:
Type DESTROY-EVERYTHING and YES as requested
Verify cleanup
Run the audit script (already in repo):
./scripts/cleanup/audit-aws-resources.sh
Confirm no clusters, LB, VPCs, ECR, RDS, S3, DynamoDB, IAM roles/policies remain for stage3/healthcare
B) Rebuild sequence

Provision Terraform backend and infra
Let pipeline create S3 and DynamoDB or run terraform init/apply manually if you’re doing it outside CI
Ensure VPC subnets, SGs, EKS, RDS are created
Setup ALB controller IAM and IRSA before Helm install
Create ALB Controller IAM policy and role from upstream JSON
Attach inline “extra” policy granting DescribeListenerAttributes, DescribeListeners, DescribeLoadBalancerAttributes
Create service account with eksctl and annotate with the role
Deploy Helm chart for AWS Load Balancer Controller
Deploy application via GitOps
Apply Ingress with spec.ingressClassName: alb and proper routing
Allow Ingress to provision ALB and establish Address
Validate
kubectl get ingress healthcare-stage3-ingress -n healthcare-stage3-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
curl http://ALB_DNS/api/health should return JSON with database: "connected"
If not, dump controller logs and check for any IAM errors—these should be eliminated by the fresh, explicit IAM setup
C) Manual steps (if needed)

If pipelines manage everything, no manual steps needed
If doing manual rebuild, follow the ordering above; ensure IAM roles and service account are in place before Helm chart
Request for confirmation
Would you like me to add a dedicated “rebuild” script (scripts/deployment/rebuild-stage3.sh) that automates the IAM setup + controller install + ingress verification as a single command? I can add it to the repo to complement the destruction script and make the process fully repeatable.
Once you confirm, I can:

Add that rebuild script
Update the Stage-3-Destruction-Guide.md with a “Rebuild” section
Adjust CI to call rebuild when needed, keeping to your pipeline trigger preferences
After the teardown, re-run the pipeline. The ALB controller IAM issues should be fully eliminated.