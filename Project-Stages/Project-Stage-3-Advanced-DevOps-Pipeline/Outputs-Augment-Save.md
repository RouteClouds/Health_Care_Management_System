Plan and task list
Investigate pipeline failure logs
[/] Fix ALB Controller IAM policy (IRSA)
Align Helm/GitOps Ingress to ALB where needed
Verification run plan and remediation checks
I’ll complete the ALB policy fix, then adjust any ingress/class misconfig, and outline a focused verification plan you can run.

Findings from the failed pipeline log
Root cause

The Ingress never received an Address because the AWS Load Balancer Controller lacked permission:
AccessDenied on elasticloadbalancing:DescribeListenerAttributes
Evidence from logs:
Multiple “FailedDeployModel … AccessDenied … DescribeListenerAttributes” events
Controller logs show the same AccessDenied error
Ingress shows “Ingress Class: ” but annotations include kubernetes.io/ingress.class: alb, alb.* annotations are present
Secondary observations

ALB name appears created, but the controller can’t reconcile listeners without the permission.
GitOps dev manifests define:
Ingress: gitops/environments/dev/ingress.yaml (correct ALB annotations already in place)
Services are ClusterIP as expected; frontend routing via Ingress looks good for ALB
Conclusion

Primary fix is to update/ensure the controller’s IAM policy contains all required permissions and that IRSA is correctly configured.
Fix 1 — Update ALB Controller IAM policy and IRSA
What I changed

Updated script: Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/scripts/deployment/install-aws-load-balancer-controller.sh
Behavior now:
Downloads latest upstream iam_policy.json (already present)
If policy exists:
Prunes non-default versions if the 5-version limit is hit
Creates a new policy version from upstream and sets it default
If policy doesn’t exist: creates it
Ensures OIDC provider association for the cluster (eksctl utils associate-iam-oidc-provider)
Creates/updates the iamserviceaccount with the policy attached
Re-installs/ensures the helm chart and waits for readiness
Why this fixes the error

The missing action elasticloadbalancing:DescribeListenerAttributes is included in the latest upstream policy; by setting a new default policy version, the role gains the permission.
OIDC association ensures the service account can assume the IAM role (IRSA).
Action for you

Re-run the pipeline job step “Install AWS Load Balancer Controller for ALB support” or re-trigger the Stage-3 pipeline.
The step will update the policy and reconcile the Ingress.
Task 2 — Align Helm/GitOps Ingress to ALB
Current state

GitOps dev ingress (gitops/environments/dev/ingress.yaml) already uses ALB annotations. Good.
Helm chart values still reference “nginx” class in healthcare-system/values.yaml, but this is not used in the GitOps dev path and does not affect current failure.
No changes required to GitOps dev ingress for ALB; it’s already correct.
Optional tidy

Later we can align the Helm chart defaults to alb (className: alb, alb.* annotations) to avoid confusion across environments.
I will leave Helm values as-is for now to minimize blast radius since GitOps is the live path for dev.

Verification run plan
Goal: Confirm the policy fix resolves AccessDenied and the Ingress gets an Address

Preconditions

Ensure repo variables for initial run:
ENABLE_ANSIBLE=false, FAIL_FAST=true, AUTO_IMPORT=false
For Safety Guard on first infra creation, consider:
TERRAFORM_CREATE_THRESHOLD=50 or FORCE_TERRAFORM_APPLY=true for the initial run
Run

Trigger pipeline via small change under Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/src-code/
Watch “Deploy Application” job:
Step “Install AWS Load Balancer Controller …” should succeed
Ingress apply succeeds
Validate automated database setup:
Should find ALB URL within the 10-minute window
If ALB URL still missing

Investigate controller logs:
kubectl logs -n kube-system deployment/aws-load-balancer-controller | head -n 100
Re-describe the Ingress and check class:
kubectl describe ingress healthcare-stage3-ingress -n healthcare-stage3-dev
Expect Address populated and no AccessDenied events
Connectivity checks once ALB is ready

curl -I http://$ALB_DNS should return 200 or 404 root (frontend) but paths should route
curl http://$ALB_DNS/api/health should return healthy JSON
Next steps and asks
I completed the ALB Controller IAM policy update in the install script.
Do you want me to:
Trigger a CI run now by adding a small src-code/ temp file?
Or would you prefer to push that change yourself?
After the run

If successful, we’ll flip Terraform to preserve_existing_cluster=true with captured ARNs/SG IDs as previously planned.
If not, I’ll proceed to deeper checks on target group health and security groups once we have the updated controller in place.
Would you like me to proceed with a small src-code change to trigger CI now?