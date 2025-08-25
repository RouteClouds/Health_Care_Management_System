Run echo "🔍 Validating Terraform state and outputs before database setup..."
🔍 Validating Terraform state and outputs before database setup...
🔧 Initializing Terraform (safe, idempotent)...
Initializing the backend...
Initializing modules...
- healthcare_infrastructure in ../../modules/healthcare-platform
Downloading registry.terraform.io/terraform-aws-modules/eks/aws 19.21.0 for healthcare_infrastructure.eks...
- healthcare_infrastructure.eks in .terraform/modules/healthcare_infrastructure.eks
- healthcare_infrastructure.eks.eks_managed_node_group in .terraform/modules/healthcare_infrastructure.eks/modules/eks-managed-node-group
- healthcare_infrastructure.eks.eks_managed_node_group.user_data in .terraform/modules/healthcare_infrastructure.eks/modules/_user_data
- healthcare_infrastructure.eks.fargate_profile in .terraform/modules/healthcare_infrastructure.eks/modules/fargate-profile
Downloading registry.terraform.io/terraform-aws-modules/kms/aws 2.1.0 for healthcare_infrastructure.eks.kms...
- healthcare_infrastructure.eks.kms in .terraform/modules/healthcare_infrastructure.eks.kms
- healthcare_infrastructure.eks.self_managed_node_group in .terraform/modules/healthcare_infrastructure.eks/modules/self-managed-node-group
- healthcare_infrastructure.eks.self_managed_node_group.user_data in .terraform/modules/healthcare_infrastructure.eks/modules/_user_data
Downloading registry.terraform.io/terraform-aws-modules/vpc/aws 5.21.0 for healthcare_infrastructure.vpc...
- healthcare_infrastructure.vpc in .terraform/modules/healthcare_infrastructure.vpc
Error: Missing Required Value
  on main.tf line 2, in terraform:
   2:   backend "s3" {}
The attribute "bucket" is required by the backend.
Refer to the backend documentation for additional information which
attributes are required.
Error: Missing Required Value
  on main.tf line 2, in terraform:
   2:   backend "s3" {}
The attribute "key" is required by the backend.
Refer to the backend documentation for additional information which
attributes are required.
Error: Terraform exited with code 1.
⚠️ Terraform state is not accessible or not initialized
🔧 Running 'terraform init' before refresh attempt...
Initializing the backend...
Initializing modules...
Error: Missing Required Value
  on main.tf line 2, in terraform:
   2:   backend "s3" {}
The attribute "bucket" is required by the backend.
Refer to the backend documentation for additional information which
attributes are required.
Error: Missing Required Value
  on main.tf line 2, in terraform:
   2:   backend "s3" {}
The attribute "key" is required by the backend.
Refer to the backend documentation for additional information which
attributes are required.
Error: Terraform exited with code 1.
🔄 Attempting to refresh state (apply -refresh-only)...
╷
│ Error: Backend initialization required, please run "terraform init"
│ 
│ Reason: Initial configuration of the requested backend "s3"
│ 
│ The "backend" is the interface that Terraform uses to store state,
│ perform operations, etc. If this message is showing up, it means that the
│ Terraform configuration you're using is using a custom configuration for
│ the Terraform backend.
│ 
│ Changes to backend configurations require reinitialization. This allows
│ Terraform to set up the new configuration, copy existing state, etc. Please
│ run
│ "terraform init" with either the "-reconfigure" or "-migrate-state" flags
│ to
│ use the current configuration.
│ 
│ If the change reason above is incorrect, please verify your configuration
│ hasn't changed and try again. At this point, no changes to your existing
│ configuration or state have been made.
╵
Error: Terraform exited with code 1.
State refresh failed - will use AWS CLI fallback

Run echo "🔍 Validating automated database setup..."
🔍 Validating automated database setup...
🔍 Getting Application Load Balancer URL from Ingress...
⏳ Waiting for ALB to be provisioned... (attempt 1/20)
⏳ Waiting for ALB to be provisioned... (attempt 2/20)
⏳ Waiting for ALB to be provisioned... (attempt 3/20)
⏳ Waiting for ALB to be provisioned... (attempt 4/20)
⏳ Waiting for ALB to be provisioned... (attempt 5/20)
⏳ Waiting for ALB to be provisioned... (attempt 6/20)
⏳ Waiting for ALB to be provisioned... (attempt 7/20)
⏳ Waiting for ALB to be provisioned... (attempt 8/20)
⏳ Waiting for ALB to be provisioned... (attempt 9/20)
⏳ Waiting for ALB to be provisioned... (attempt 10/20)
⏳ Waiting for ALB to be provisioned... (attempt 11/20)
⏳ Waiting for ALB to be provisioned... (attempt 12/20)
⏳ Waiting for ALB to be provisioned... (attempt 13/20)
⏳ Waiting for ALB to be provisioned... (attempt 14/20)
⏳ Waiting for ALB to be provisioned... (attempt 15/20)
⏳ Waiting for ALB to be provisioned... (attempt 16/20)
⏳ Waiting for ALB to be provisioned... (attempt 17/20)
⏳ Waiting for ALB to be provisioned... (attempt 18/20)
⏳ Waiting for ALB to be provisioned... (attempt 19/20)
⏳ Waiting for ALB to be provisioned... (attempt 20/20)
❌ Application Load Balancer URL not found after 10 minutes
🔍 Checking Ingress status...
Name:             healthcare-stage3-ingress
Labels:           <none>
Namespace:        healthcare-stage3-dev
Address:          
Ingress Class:    <none>
Default backend:  <default>
Rules:
  Host        Path  Backends
  ----        ----  --------
  *           
              /   frontend-stage3-svc:80 (10.0.1.60:80,10.0.2.148:80)
Annotations:  alb.ingress.kubernetes.io/group.name: healthcare-stage3
              alb.ingress.kubernetes.io/healthcheck-path: /
              alb.ingress.kubernetes.io/listen-ports: [{"HTTP":80}]
              alb.ingress.kubernetes.io/scheme: internet-facing
              alb.ingress.kubernetes.io/target-type: ip
              kubernetes.io/ingress.class: alb
Events:
  Type     Reason             Age   From     Message
  ----     ------             ----  ----     -------
  Warning  FailedDeployModel  54m   ingress  Failed deploy model due to operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: 4e9d1507-5fb7-4c2f-a16e-d044b2555c37, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756133919281776315 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action
  Warning  FailedDeployModel  37m   ingress  Failed deploy model due to operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: b37d0de3-4625-4116-bb76-d747c5225efd, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756133919281776315 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action
  Warning  FailedDeployModel  20m   ingress  Failed deploy model due to operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: 7213ea5a-b4c1-40a1-b5c2-a697b7e8f538, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756133919281776315 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action
  Warning  FailedDeployModel  4m    ingress  Failed deploy model due to operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: 0f7f6543-63ef-4ba4-a79e-2a164632e0f0, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756137921752723319 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action
🔍 Checking AWS Load Balancer Controller logs...
Found 2 pods, using pod/aws-load-balancer-controller-79dc84dff7-2rszk
{"level":"info","ts":"2025-08-25T11:44:16Z","logger":"controllers.ingress","msg":"successfully built model","model":"{\"id\":\"healthcare-stage3\",\"resources\":{\"AWS::EC2::SecurityGroup\":{\"ManagedLBSecurityGroup\":{\"spec\":{\"groupName\":\"k8s-healthcarestage3-8fb288ef6a\",\"description\":\"[k8s] Managed SecurityGroup for LoadBalancer\",\"ingress\":[{\"ipProtocol\":\"tcp\",\"fromPort\":80,\"toPort\":80,\"ipRanges\":[{\"cidrIP\":\"0.0.0.0/0\"}]}]}}},\"AWS::ElasticLoadBalancingV2::Listener\":{\"80\":{\"spec\":{\"loadBalancerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::LoadBalancer/LoadBalancer/status/loadBalancerARN\"},\"port\":80,\"protocol\":\"HTTP\",\"defaultActions\":[{\"type\":\"fixed-response\",\"fixedResponseConfig\":{\"contentType\":\"text/plain\",\"statusCode\":\"404\"}}]}}},\"AWS::ElasticLoadBalancingV2::ListenerRule\":{\"80:1\":{\"spec\":{\"listenerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::Listener/80/status/listenerARN\"},\"priority\":1,\"actions\":[{\"type\":\"fo
{"level":"error","ts":"2025-08-25T11:44:17Z","msg":"Reconciler error","controller":"ingress","object":{"name":"healthcare-stage3"},"namespace":"","name":"healthcare-stage3","reconcileID":"d6182333-3784-415f-98b4-618d6ac3bb5c","error":"operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: 77c867f5-ef89-4798-8230-80b35075f9da, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756121590312166496 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action"}
{"level":"info","ts":"2025-08-25T11:55:12Z","logger":"controllers.ingress","msg":"Auto Create SG","LB SGs":[{"$ref":"#/resources/AWS::EC2::SecurityGroup/ManagedLBSecurityGroup/status/groupID"},"sg-03c0dbbf55937c065"],"backend SG":"sg-03c0dbbf55937c065"}
{"level":"info","ts":"2025-08-25T11:55:12Z","logger":"controllers.ingress","msg":"successfully built model","model":"{\"id\":\"healthcare-stage3\",\"resources\":{\"AWS::EC2::SecurityGroup\":{\"ManagedLBSecurityGroup\":{\"spec\":{\"groupName\":\"k8s-healthcarestage3-8fb288ef6a\",\"description\":\"[k8s] Managed SecurityGroup for LoadBalancer\",\"ingress\":[{\"ipProtocol\":\"tcp\",\"fromPort\":80,\"toPort\":80,\"ipRanges\":[{\"cidrIP\":\"0.0.0.0/0\"}]}]}}},\"AWS::ElasticLoadBalancingV2::Listener\":{\"80\":{\"spec\":{\"loadBalancerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::LoadBalancer/LoadBalancer/status/loadBalancerARN\"},\"port\":80,\"protocol\":\"HTTP\",\"defaultActions\":[{\"type\":\"fixed-response\",\"fixedResponseConfig\":{\"contentType\":\"text/plain\",\"statusCode\":\"404\"}}]}}},\"AWS::ElasticLoadBalancingV2::ListenerRule\":{\"80:1\":{\"spec\":{\"listenerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::Listener/80/status/listenerARN\"},\"priority\":1,\"actions\":[{\"type\":\"fo
{"level":"error","ts":"2025-08-25T11:55:13Z","msg":"Reconciler error","controller":"ingress","object":{"name":"healthcare-stage3"},"namespace":"","name":"healthcare-stage3","reconcileID":"a7325556-27f7-4b6d-b2ce-927c218418be","error":"operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: 08b97c25-1aba-4ea4-8514-e394b8657f9f, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756121590312166496 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action"}
{"level":"info","ts":"2025-08-25T12:11:53Z","logger":"controllers.ingress","msg":"Auto Create SG","LB SGs":[{"$ref":"#/resources/AWS::EC2::SecurityGroup/ManagedLBSecurityGroup/status/groupID"},"sg-03c0dbbf55937c065"],"backend SG":"sg-03c0dbbf55937c065"}
{"level":"info","ts":"2025-08-25T12:11:53Z","logger":"controllers.ingress","msg":"successfully built model","model":"{\"id\":\"healthcare-stage3\",\"resources\":{\"AWS::EC2::SecurityGroup\":{\"ManagedLBSecurityGroup\":{\"spec\":{\"groupName\":\"k8s-healthcarestage3-8fb288ef6a\",\"description\":\"[k8s] Managed SecurityGroup for LoadBalancer\",\"ingress\":[{\"ipProtocol\":\"tcp\",\"fromPort\":80,\"toPort\":80,\"ipRanges\":[{\"cidrIP\":\"0.0.0.0/0\"}]}]}}},\"AWS::ElasticLoadBalancingV2::Listener\":{\"80\":{\"spec\":{\"loadBalancerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::LoadBalancer/LoadBalancer/status/loadBalancerARN\"},\"port\":80,\"protocol\":\"HTTP\",\"defaultActions\":[{\"type\":\"fixed-response\",\"fixedResponseConfig\":{\"contentType\":\"text/plain\",\"statusCode\":\"404\"}}]}}},\"AWS::ElasticLoadBalancingV2::ListenerRule\":{\"80:1\":{\"spec\":{\"listenerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::Listener/80/status/listenerARN\"},\"priority\":1,\"actions\":[{\"type\":\"fo
{"level":"error","ts":"2025-08-25T12:11:53Z","msg":"Reconciler error","controller":"ingress","object":{"name":"healthcare-stage3"},"namespace":"","name":"healthcare-stage3","reconcileID":"32e17a64-0732-45fc-9aca-ae6d20ebf16e","error":"operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: ffef7ff4-acd6-4588-b97f-ec8812c5ceaf, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756121590312166496 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action"}
{"level":"info","ts":"2025-08-25T12:28:33Z","logger":"controllers.ingress","msg":"Auto Create SG","LB SGs":[{"$ref":"#/resources/AWS::EC2::SecurityGroup/ManagedLBSecurityGroup/status/groupID"},"sg-03c0dbbf55937c065"],"backend SG":"sg-03c0dbbf55937c065"}
{"level":"info","ts":"2025-08-25T12:28:33Z","logger":"controllers.ingress","msg":"successfully built model","model":"{\"id\":\"healthcare-stage3\",\"resources\":{\"AWS::EC2::SecurityGroup\":{\"ManagedLBSecurityGroup\":{\"spec\":{\"groupName\":\"k8s-healthcarestage3-8fb288ef6a\",\"description\":\"[k8s] Managed SecurityGroup for LoadBalancer\",\"ingress\":[{\"ipProtocol\":\"tcp\",\"fromPort\":80,\"toPort\":80,\"ipRanges\":[{\"cidrIP\":\"0.0.0.0/0\"}]}]}}},\"AWS::ElasticLoadBalancingV2::Listener\":{\"80\":{\"spec\":{\"loadBalancerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::LoadBalancer/LoadBalancer/status/loadBalancerARN\"},\"port\":80,\"protocol\":\"HTTP\",\"defaultActions\":[{\"type\":\"fixed-response\",\"fixedResponseConfig\":{\"contentType\":\"text/plain\",\"statusCode\":\"404\"}}]}}},\"AWS::ElasticLoadBalancingV2::ListenerRule\":{\"80:1\":{\"spec\":{\"listenerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::Listener/80/status/listenerARN\"},\"priority\":1,\"actions\":[{\"type\":\"fo
{"level":"error","ts":"2025-08-25T12:28:34Z","msg":"Reconciler error","controller":"ingress","object":{"name":"healthcare-stage3"},"namespace":"","name":"healthcare-stage3","reconcileID":"66625e91-0824-490b-882c-c9f0fc7ad14c","error":"operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: 5852a03f-156e-4146-80b2-5bc244113e37, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756121590312166496 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action"}
{"level":"info","ts":"2025-08-25T12:45:14Z","logger":"controllers.ingress","msg":"Auto Create SG","LB SGs":[{"$ref":"#/resources/AWS::EC2::SecurityGroup/ManagedLBSecurityGroup/status/groupID"},"sg-03c0dbbf55937c065"],"backend SG":"sg-03c0dbbf55937c065"}
{"level":"info","ts":"2025-08-25T12:45:14Z","logger":"controllers.ingress","msg":"successfully built model","model":"{\"id\":\"healthcare-stage3\",\"resources\":{\"AWS::EC2::SecurityGroup\":{\"ManagedLBSecurityGroup\":{\"spec\":{\"groupName\":\"k8s-healthcarestage3-8fb288ef6a\",\"description\":\"[k8s] Managed SecurityGroup for LoadBalancer\",\"ingress\":[{\"ipProtocol\":\"tcp\",\"fromPort\":80,\"toPort\":80,\"ipRanges\":[{\"cidrIP\":\"0.0.0.0/0\"}]}]}}},\"AWS::ElasticLoadBalancingV2::Listener\":{\"80\":{\"spec\":{\"loadBalancerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::LoadBalancer/LoadBalancer/status/loadBalancerARN\"},\"port\":80,\"protocol\":\"HTTP\",\"defaultActions\":[{\"type\":\"fixed-response\",\"fixedResponseConfig\":{\"contentType\":\"text/plain\",\"statusCode\":\"404\"}}]}}},\"AWS::ElasticLoadBalancingV2::ListenerRule\":{\"80:1\":{\"spec\":{\"listenerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::Listener/80/status/listenerARN\"},\"priority\":1,\"actions\":[{\"type\":\"fo
{"level":"error","ts":"2025-08-25T12:45:15Z","msg":"Reconciler error","controller":"ingress","object":{"name":"healthcare-stage3"},"namespace":"","name":"healthcare-stage3","reconcileID":"4473e784-d640-4c61-bce6-9c2d958132d0","error":"operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: e187af78-c326-4697-9702-b0f9dd77c9fe, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756125914427418570 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action"}
{"level":"info","ts":"2025-08-25T13:01:55Z","logger":"controllers.ingress","msg":"Auto Create SG","LB SGs":[{"$ref":"#/resources/AWS::EC2::SecurityGroup/ManagedLBSecurityGroup/status/groupID"},"sg-03c0dbbf55937c065"],"backend SG":"sg-03c0dbbf55937c065"}
{"level":"info","ts":"2025-08-25T13:01:55Z","logger":"controllers.ingress","msg":"successfully built model","model":"{\"id\":\"healthcare-stage3\",\"resources\":{\"AWS::EC2::SecurityGroup\":{\"ManagedLBSecurityGroup\":{\"spec\":{\"groupName\":\"k8s-healthcarestage3-8fb288ef6a\",\"description\":\"[k8s] Managed SecurityGroup for LoadBalancer\",\"ingress\":[{\"ipProtocol\":\"tcp\",\"fromPort\":80,\"toPort\":80,\"ipRanges\":[{\"cidrIP\":\"0.0.0.0/0\"}]}]}}},\"AWS::ElasticLoadBalancingV2::Listener\":{\"80\":{\"spec\":{\"loadBalancerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::LoadBalancer/LoadBalancer/status/loadBalancerARN\"},\"port\":80,\"protocol\":\"HTTP\",\"defaultActions\":[{\"type\":\"fixed-response\",\"fixedResponseConfig\":{\"contentType\":\"text/plain\",\"statusCode\":\"404\"}}]}}},\"AWS::ElasticLoadBalancingV2::ListenerRule\":{\"80:1\":{\"spec\":{\"listenerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::Listener/80/status/listenerARN\"},\"priority\":1,\"actions\":[{\"type\":\"fo
{"level":"error","ts":"2025-08-25T13:01:55Z","msg":"Reconciler error","controller":"ingress","object":{"name":"healthcare-stage3"},"namespace":"","name":"healthcare-stage3","reconcileID":"f11e56b7-3dbd-45a2-b3b6-258e680095be","error":"operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: 7a6b28c2-72be-49fd-937f-632926ecd2f5, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756125914427418570 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action"}
{"level":"info","ts":"2025-08-25T13:18:35Z","logger":"controllers.ingress","msg":"Auto Create SG","LB SGs":[{"$ref":"#/resources/AWS::EC2::SecurityGroup/ManagedLBSecurityGroup/status/groupID"},"sg-03c0dbbf55937c065"],"backend SG":"sg-03c0dbbf55937c065"}
{"level":"info","ts":"2025-08-25T13:18:35Z","logger":"controllers.ingress","msg":"successfully built model","model":"{\"id\":\"healthcare-stage3\",\"resources\":{\"AWS::EC2::SecurityGroup\":{\"ManagedLBSecurityGroup\":{\"spec\":{\"groupName\":\"k8s-healthcarestage3-8fb288ef6a\",\"description\":\"[k8s] Managed SecurityGroup for LoadBalancer\",\"ingress\":[{\"ipProtocol\":\"tcp\",\"fromPort\":80,\"toPort\":80,\"ipRanges\":[{\"cidrIP\":\"0.0.0.0/0\"}]}]}}},\"AWS::ElasticLoadBalancingV2::Listener\":{\"80\":{\"spec\":{\"loadBalancerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::LoadBalancer/LoadBalancer/status/loadBalancerARN\"},\"port\":80,\"protocol\":\"HTTP\",\"defaultActions\":[{\"type\":\"fixed-response\",\"fixedResponseConfig\":{\"contentType\":\"text/plain\",\"statusCode\":\"404\"}}]}}},\"AWS::ElasticLoadBalancingV2::ListenerRule\":{\"80:1\":{\"spec\":{\"listenerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::Listener/80/status/listenerARN\"},\"priority\":1,\"actions\":[{\"type\":\"fo
{"level":"error","ts":"2025-08-25T13:18:36Z","msg":"Reconciler error","controller":"ingress","object":{"name":"healthcare-stage3"},"namespace":"","name":"healthcare-stage3","reconcileID":"cc9a9b1d-b8a4-4ddf-81e5-099b26962ab4","error":"operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: a97c4d26-1979-450b-8b57-09bb009b040b, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756125914427418570 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action"}
{"level":"info","ts":"2025-08-25T13:35:16Z","logger":"controllers.ingress","msg":"Auto Create SG","LB SGs":[{"$ref":"#/resources/AWS::EC2::SecurityGroup/ManagedLBSecurityGroup/status/groupID"},"sg-03c0dbbf55937c065"],"backend SG":"sg-03c0dbbf55937c065"}
{"level":"info","ts":"2025-08-25T13:35:16Z","logger":"controllers.ingress","msg":"successfully built model","model":"{\"id\":\"healthcare-stage3\",\"resources\":{\"AWS::EC2::SecurityGroup\":{\"ManagedLBSecurityGroup\":{\"spec\":{\"groupName\":\"k8s-healthcarestage3-8fb288ef6a\",\"description\":\"[k8s] Managed SecurityGroup for LoadBalancer\",\"ingress\":[{\"ipProtocol\":\"tcp\",\"fromPort\":80,\"toPort\":80,\"ipRanges\":[{\"cidrIP\":\"0.0.0.0/0\"}]}]}}},\"AWS::ElasticLoadBalancingV2::Listener\":{\"80\":{\"spec\":{\"loadBalancerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::LoadBalancer/LoadBalancer/status/loadBalancerARN\"},\"port\":80,\"protocol\":\"HTTP\",\"defaultActions\":[{\"type\":\"fixed-response\",\"fixedResponseConfig\":{\"contentType\":\"text/plain\",\"statusCode\":\"404\"}}]}}},\"AWS::ElasticLoadBalancingV2::ListenerRule\":{\"80:1\":{\"spec\":{\"listenerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::Listener/80/status/listenerARN\"},\"priority\":1,\"actions\":[{\"type\":\"fo
{"level":"error","ts":"2025-08-25T13:35:16Z","msg":"Reconciler error","controller":"ingress","object":{"name":"healthcare-stage3"},"namespace":"","name":"healthcare-stage3","reconcileID":"5572c93f-bda9-48fd-84aa-03c750ccc9dc","error":"operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: aa33c632-8017-4c60-914e-dc3cf53bdf10, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756125914427418570 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action"}
{"level":"info","ts":"2025-08-25T13:51:57Z","logger":"controllers.ingress","msg":"Auto Create SG","LB SGs":[{"$ref":"#/resources/AWS::EC2::SecurityGroup/ManagedLBSecurityGroup/status/groupID"},"sg-03c0dbbf55937c065"],"backend SG":"sg-03c0dbbf55937c065"}
{"level":"info","ts":"2025-08-25T13:51:57Z","logger":"controllers.ingress","msg":"successfully built model","model":"{\"id\":\"healthcare-stage3\",\"resources\":{\"AWS::EC2::SecurityGroup\":{\"ManagedLBSecurityGroup\":{\"spec\":{\"groupName\":\"k8s-healthcarestage3-8fb288ef6a\",\"description\":\"[k8s] Managed SecurityGroup for LoadBalancer\",\"ingress\":[{\"ipProtocol\":\"tcp\",\"fromPort\":80,\"toPort\":80,\"ipRanges\":[{\"cidrIP\":\"0.0.0.0/0\"}]}]}}},\"AWS::ElasticLoadBalancingV2::Listener\":{\"80\":{\"spec\":{\"loadBalancerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::LoadBalancer/LoadBalancer/status/loadBalancerARN\"},\"port\":80,\"protocol\":\"HTTP\",\"defaultActions\":[{\"type\":\"fixed-response\",\"fixedResponseConfig\":{\"contentType\":\"text/plain\",\"statusCode\":\"404\"}}]}}},\"AWS::ElasticLoadBalancingV2::ListenerRule\":{\"80:1\":{\"spec\":{\"listenerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::Listener/80/status/listenerARN\"},\"priority\":1,\"actions\":[{\"type\":\"fo
{"level":"error","ts":"2025-08-25T13:51:57Z","msg":"Reconciler error","controller":"ingress","object":{"name":"healthcare-stage3"},"namespace":"","name":"healthcare-stage3","reconcileID":"b0d371f1-1ef4-4926-9fa9-1828dd537442","error":"operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: 0d1bf0d1-7d8d-43ed-94d4-37a157a0530f, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756129916940463729 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action"}
{"level":"info","ts":"2025-08-25T14:08:37Z","logger":"controllers.ingress","msg":"Auto Create SG","LB SGs":[{"$ref":"#/resources/AWS::EC2::SecurityGroup/ManagedLBSecurityGroup/status/groupID"},"sg-03c0dbbf55937c065"],"backend SG":"sg-03c0dbbf55937c065"}
{"level":"info","ts":"2025-08-25T14:08:37Z","logger":"controllers.ingress","msg":"successfully built model","model":"{\"id\":\"healthcare-stage3\",\"resources\":{\"AWS::EC2::SecurityGroup\":{\"ManagedLBSecurityGroup\":{\"spec\":{\"groupName\":\"k8s-healthcarestage3-8fb288ef6a\",\"description\":\"[k8s] Managed SecurityGroup for LoadBalancer\",\"ingress\":[{\"ipProtocol\":\"tcp\",\"fromPort\":80,\"toPort\":80,\"ipRanges\":[{\"cidrIP\":\"0.0.0.0/0\"}]}]}}},\"AWS::ElasticLoadBalancingV2::Listener\":{\"80\":{\"spec\":{\"loadBalancerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::LoadBalancer/LoadBalancer/status/loadBalancerARN\"},\"port\":80,\"protocol\":\"HTTP\",\"defaultActions\":[{\"type\":\"fixed-response\",\"fixedResponseConfig\":{\"contentType\":\"text/plain\",\"statusCode\":\"404\"}}]}}},\"AWS::ElasticLoadBalancingV2::ListenerRule\":{\"80:1\":{\"spec\":{\"listenerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::Listener/80/status/listenerARN\"},\"priority\":1,\"actions\":[{\"type\":\"fo
{"level":"error","ts":"2025-08-25T14:08:38Z","msg":"Reconciler error","controller":"ingress","object":{"name":"healthcare-stage3"},"namespace":"","name":"healthcare-stage3","reconcileID":"adda3eb5-ba59-4e64-998b-b890efb68d9e","error":"operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: 3b2e078f-0658-43fa-9c95-42496d186a1d, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756129916940463729 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action"}
{"level":"info","ts":"2025-08-25T14:25:18Z","logger":"controllers.ingress","msg":"Auto Create SG","LB SGs":[{"$ref":"#/resources/AWS::EC2::SecurityGroup/ManagedLBSecurityGroup/status/groupID"},"sg-03c0dbbf55937c065"],"backend SG":"sg-03c0dbbf55937c065"}
{"level":"info","ts":"2025-08-25T14:25:18Z","logger":"controllers.ingress","msg":"successfully built model","model":"{\"id\":\"healthcare-stage3\",\"resources\":{\"AWS::EC2::SecurityGroup\":{\"ManagedLBSecurityGroup\":{\"spec\":{\"groupName\":\"k8s-healthcarestage3-8fb288ef6a\",\"description\":\"[k8s] Managed SecurityGroup for LoadBalancer\",\"ingress\":[{\"ipProtocol\":\"tcp\",\"fromPort\":80,\"toPort\":80,\"ipRanges\":[{\"cidrIP\":\"0.0.0.0/0\"}]}]}}},\"AWS::ElasticLoadBalancingV2::Listener\":{\"80\":{\"spec\":{\"loadBalancerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::LoadBalancer/LoadBalancer/status/loadBalancerARN\"},\"port\":80,\"protocol\":\"HTTP\",\"defaultActions\":[{\"type\":\"fixed-response\",\"fixedResponseConfig\":{\"contentType\":\"text/plain\",\"statusCode\":\"404\"}}]}}},\"AWS::ElasticLoadBalancingV2::ListenerRule\":{\"80:1\":{\"spec\":{\"listenerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::Listener/80/status/listenerARN\"},\"priority\":1,\"actions\":[{\"type\":\"fo
{"level":"error","ts":"2025-08-25T14:25:18Z","msg":"Reconciler error","controller":"ingress","object":{"name":"healthcare-stage3"},"namespace":"","name":"healthcare-stage3","reconcileID":"b67e3560-7ed3-46d9-96de-4eab12a9d23e","error":"operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: 0be4a974-259e-42a2-96eb-a04b96c7e1a3, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756129916940463729 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action"}
{"level":"info","ts":"2025-08-25T14:41:58Z","logger":"controllers.ingress","msg":"Auto Create SG","LB SGs":[{"$ref":"#/resources/AWS::EC2::SecurityGroup/ManagedLBSecurityGroup/status/groupID"},"sg-03c0dbbf55937c065"],"backend SG":"sg-03c0dbbf55937c065"}
{"level":"info","ts":"2025-08-25T14:41:58Z","logger":"controllers.ingress","msg":"successfully built model","model":"{\"id\":\"healthcare-stage3\",\"resources\":{\"AWS::EC2::SecurityGroup\":{\"ManagedLBSecurityGroup\":{\"spec\":{\"groupName\":\"k8s-healthcarestage3-8fb288ef6a\",\"description\":\"[k8s] Managed SecurityGroup for LoadBalancer\",\"ingress\":[{\"ipProtocol\":\"tcp\",\"fromPort\":80,\"toPort\":80,\"ipRanges\":[{\"cidrIP\":\"0.0.0.0/0\"}]}]}}},\"AWS::ElasticLoadBalancingV2::Listener\":{\"80\":{\"spec\":{\"loadBalancerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::LoadBalancer/LoadBalancer/status/loadBalancerARN\"},\"port\":80,\"protocol\":\"HTTP\",\"defaultActions\":[{\"type\":\"fixed-response\",\"fixedResponseConfig\":{\"contentType\":\"text/plain\",\"statusCode\":\"404\"}}]}}},\"AWS::ElasticLoadBalancingV2::ListenerRule\":{\"80:1\":{\"spec\":{\"listenerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::Listener/80/status/listenerARN\"},\"priority\":1,\"actions\":[{\"type\":\"fo
{"level":"error","ts":"2025-08-25T14:41:59Z","msg":"Reconciler error","controller":"ingress","object":{"name":"healthcare-stage3"},"namespace":"","name":"healthcare-stage3","reconcileID":"3756b42c-3a9b-467a-8195-90d7020ed8fb","error":"operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: a71008c6-ede5-45ef-917a-562676b40ef5, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756129916940463729 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action"}
{"level":"info","ts":"2025-08-25T14:58:39Z","logger":"controllers.ingress","msg":"Auto Create SG","LB SGs":[{"$ref":"#/resources/AWS::EC2::SecurityGroup/ManagedLBSecurityGroup/status/groupID"},"sg-03c0dbbf55937c065"],"backend SG":"sg-03c0dbbf55937c065"}
{"level":"info","ts":"2025-08-25T14:58:39Z","logger":"controllers.ingress","msg":"successfully built model","model":"{\"id\":\"healthcare-stage3\",\"resources\":{\"AWS::EC2::SecurityGroup\":{\"ManagedLBSecurityGroup\":{\"spec\":{\"groupName\":\"k8s-healthcarestage3-8fb288ef6a\",\"description\":\"[k8s] Managed SecurityGroup for LoadBalancer\",\"ingress\":[{\"ipProtocol\":\"tcp\",\"fromPort\":80,\"toPort\":80,\"ipRanges\":[{\"cidrIP\":\"0.0.0.0/0\"}]}]}}},\"AWS::ElasticLoadBalancingV2::Listener\":{\"80\":{\"spec\":{\"loadBalancerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::LoadBalancer/LoadBalancer/status/loadBalancerARN\"},\"port\":80,\"protocol\":\"HTTP\",\"defaultActions\":[{\"type\":\"fixed-response\",\"fixedResponseConfig\":{\"contentType\":\"text/plain\",\"statusCode\":\"404\"}}]}}},\"AWS::ElasticLoadBalancingV2::ListenerRule\":{\"80:1\":{\"spec\":{\"listenerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::Listener/80/status/listenerARN\"},\"priority\":1,\"actions\":[{\"type\":\"fo
{"level":"error","ts":"2025-08-25T14:58:39Z","msg":"Reconciler error","controller":"ingress","object":{"name":"healthcare-stage3"},"namespace":"","name":"healthcare-stage3","reconcileID":"23bfee0b-60de-4cb3-a55c-369a6c965431","error":"operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: 134045d1-8efd-4217-8ac7-8f775dc2c3de, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756133919281776315 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action"}
{"level":"info","ts":"2025-08-25T15:15:19Z","logger":"controllers.ingress","msg":"Auto Create SG","LB SGs":[{"$ref":"#/resources/AWS::EC2::SecurityGroup/ManagedLBSecurityGroup/status/groupID"},"sg-03c0dbbf55937c065"],"backend SG":"sg-03c0dbbf55937c065"}
{"level":"info","ts":"2025-08-25T15:15:19Z","logger":"controllers.ingress","msg":"successfully built model","model":"{\"id\":\"healthcare-stage3\",\"resources\":{\"AWS::EC2::SecurityGroup\":{\"ManagedLBSecurityGroup\":{\"spec\":{\"groupName\":\"k8s-healthcarestage3-8fb288ef6a\",\"description\":\"[k8s] Managed SecurityGroup for LoadBalancer\",\"ingress\":[{\"ipProtocol\":\"tcp\",\"fromPort\":80,\"toPort\":80,\"ipRanges\":[{\"cidrIP\":\"0.0.0.0/0\"}]}]}}},\"AWS::ElasticLoadBalancingV2::Listener\":{\"80\":{\"spec\":{\"loadBalancerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::LoadBalancer/LoadBalancer/status/loadBalancerARN\"},\"port\":80,\"protocol\":\"HTTP\",\"defaultActions\":[{\"type\":\"fixed-response\",\"fixedResponseConfig\":{\"contentType\":\"text/plain\",\"statusCode\":\"404\"}}]}}},\"AWS::ElasticLoadBalancingV2::ListenerRule\":{\"80:1\":{\"spec\":{\"listenerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::Listener/80/status/listenerARN\"},\"priority\":1,\"actions\":[{\"type\":\"fo
{"level":"error","ts":"2025-08-25T15:15:20Z","msg":"Reconciler error","controller":"ingress","object":{"name":"healthcare-stage3"},"namespace":"","name":"healthcare-stage3","reconcileID":"77146205-8cff-4972-9de7-c943f476edb8","error":"operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: 4e9d1507-5fb7-4c2f-a16e-d044b2555c37, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756133919281776315 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action"}
{"level":"info","ts":"2025-08-25T15:32:00Z","logger":"controllers.ingress","msg":"Auto Create SG","LB SGs":[{"$ref":"#/resources/AWS::EC2::SecurityGroup/ManagedLBSecurityGroup/status/groupID"},"sg-03c0dbbf55937c065"],"backend SG":"sg-03c0dbbf55937c065"}
{"level":"info","ts":"2025-08-25T15:32:00Z","logger":"controllers.ingress","msg":"successfully built model","model":"{\"id\":\"healthcare-stage3\",\"resources\":{\"AWS::EC2::SecurityGroup\":{\"ManagedLBSecurityGroup\":{\"spec\":{\"groupName\":\"k8s-healthcarestage3-8fb288ef6a\",\"description\":\"[k8s] Managed SecurityGroup for LoadBalancer\",\"ingress\":[{\"ipProtocol\":\"tcp\",\"fromPort\":80,\"toPort\":80,\"ipRanges\":[{\"cidrIP\":\"0.0.0.0/0\"}]}]}}},\"AWS::ElasticLoadBalancingV2::Listener\":{\"80\":{\"spec\":{\"loadBalancerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::LoadBalancer/LoadBalancer/status/loadBalancerARN\"},\"port\":80,\"protocol\":\"HTTP\",\"defaultActions\":[{\"type\":\"fixed-response\",\"fixedResponseConfig\":{\"contentType\":\"text/plain\",\"statusCode\":\"404\"}}]}}},\"AWS::ElasticLoadBalancingV2::ListenerRule\":{\"80:1\":{\"spec\":{\"listenerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::Listener/80/status/listenerARN\"},\"priority\":1,\"actions\":[{\"type\":\"fo
{"level":"error","ts":"2025-08-25T15:32:01Z","msg":"Reconciler error","controller":"ingress","object":{"name":"healthcare-stage3"},"namespace":"","name":"healthcare-stage3","reconcileID":"eed6bea7-6c82-44e5-a7c5-d58fb2519b3c","error":"operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: b37d0de3-4625-4116-bb76-d747c5225efd, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756133919281776315 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action"}
{"level":"info","ts":"2025-08-25T15:48:41Z","logger":"controllers.ingress","msg":"Auto Create SG","LB SGs":[{"$ref":"#/resources/AWS::EC2::SecurityGroup/ManagedLBSecurityGroup/status/groupID"},"sg-03c0dbbf55937c065"],"backend SG":"sg-03c0dbbf55937c065"}
{"level":"info","ts":"2025-08-25T15:48:41Z","logger":"controllers.ingress","msg":"successfully built model","model":"{\"id\":\"healthcare-stage3\",\"resources\":{\"AWS::EC2::SecurityGroup\":{\"ManagedLBSecurityGroup\":{\"spec\":{\"groupName\":\"k8s-healthcarestage3-8fb288ef6a\",\"description\":\"[k8s] Managed SecurityGroup for LoadBalancer\",\"ingress\":[{\"ipProtocol\":\"tcp\",\"fromPort\":80,\"toPort\":80,\"ipRanges\":[{\"cidrIP\":\"0.0.0.0/0\"}]}]}}},\"AWS::ElasticLoadBalancingV2::Listener\":{\"80\":{\"spec\":{\"loadBalancerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::LoadBalancer/LoadBalancer/status/loadBalancerARN\"},\"port\":80,\"protocol\":\"HTTP\",\"defaultActions\":[{\"type\":\"fixed-response\",\"fixedResponseConfig\":{\"contentType\":\"text/plain\",\"statusCode\":\"404\"}}]}}},\"AWS::ElasticLoadBalancingV2::ListenerRule\":{\"80:1\":{\"spec\":{\"listenerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::Listener/80/status/listenerARN\"},\"priority\":1,\"actions\":[{\"type\":\"fo
{"level":"error","ts":"2025-08-25T15:48:41Z","msg":"Reconciler error","controller":"ingress","object":{"name":"healthcare-stage3"},"namespace":"","name":"healthcare-stage3","reconcileID":"cf8c2017-9a27-49f7-ac55-291c36fbd290","error":"operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: 7213ea5a-b4c1-40a1-b5c2-a697b7e8f538, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756133919281776315 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action"}
{"level":"info","ts":"2025-08-25T16:05:21Z","logger":"controllers.ingress","msg":"Auto Create SG","LB SGs":[{"$ref":"#/resources/AWS::EC2::SecurityGroup/ManagedLBSecurityGroup/status/groupID"},"sg-03c0dbbf55937c065"],"backend SG":"sg-03c0dbbf55937c065"}
{"level":"info","ts":"2025-08-25T16:05:21Z","logger":"controllers.ingress","msg":"successfully built model","model":"{\"id\":\"healthcare-stage3\",\"resources\":{\"AWS::EC2::SecurityGroup\":{\"ManagedLBSecurityGroup\":{\"spec\":{\"groupName\":\"k8s-healthcarestage3-8fb288ef6a\",\"description\":\"[k8s] Managed SecurityGroup for LoadBalancer\",\"ingress\":[{\"ipProtocol\":\"tcp\",\"fromPort\":80,\"toPort\":80,\"ipRanges\":[{\"cidrIP\":\"0.0.0.0/0\"}]}]}}},\"AWS::ElasticLoadBalancingV2::Listener\":{\"80\":{\"spec\":{\"loadBalancerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::LoadBalancer/LoadBalancer/status/loadBalancerARN\"},\"port\":80,\"protocol\":\"HTTP\",\"defaultActions\":[{\"type\":\"fixed-response\",\"fixedResponseConfig\":{\"contentType\":\"text/plain\",\"statusCode\":\"404\"}}]}}},\"AWS::ElasticLoadBalancingV2::ListenerRule\":{\"80:1\":{\"spec\":{\"listenerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::Listener/80/status/listenerARN\"},\"priority\":1,\"actions\":[{\"type\":\"fo
{"level":"error","ts":"2025-08-25T16:05:22Z","msg":"Reconciler error","controller":"ingress","object":{"name":"healthcare-stage3"},"namespace":"","name":"healthcare-stage3","reconcileID":"a192b23b-6e96-4640-b0c8-4960e37425be","error":"operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: 0f7f6543-63ef-4ba4-a79e-2a164632e0f0, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756137921752723319 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action"}
🔍 Checking for any ALBs in the region...
ℹ️ Using fallback ALB DNS: http://k8s-healthcarestage3-2fd3bd59d0-1581054579.us-east-1.elb.amazonaws.com
🔗 Using Application Load Balancer: http://k8s-healthcarestage3-2fd3bd59d0-1581054579.us-east-1.elb.amazonaws.com
🔗 Using Application Load Balancer: http://
🔍 Checking pod status...
NAME                                          READY   STATUS    RESTARTS   AGE
healthcare-backend-stage3-d56b7644b-cntd2     1/1     Running   0          11m
healthcare-backend-stage3-d56b7644b-rchpk     1/1     Running   0          11m
healthcare-frontend-stage3-646f75855b-btr5t   1/1     Running   0          11m
healthcare-frontend-stage3-646f75855b-kjpzq   1/1     Running   0          11m
Name:             healthcare-backend-stage3-d56b7644b-cntd2
Namespace:        healthcare-stage3-dev
Priority:         0
Service Account:  default
Node:             ip-10-0-1-22.ec2.internal/10.0.1.22
Start Time:       Mon, 25 Aug 2025 15:58:24 +0000
Labels:           app=healthcare-backend-stage3
                  environment=dev
                  pod-template-hash=d56b7644b
                  stage=stage-3
                  tier=backend
Annotations:      kubectl.kubernetes.io/restartedAt: 2025-08-25T15:57:50Z
Status:           Running
IP:               10.0.1.246
IPs:
  IP:           10.0.1.246
Controlled By:  ReplicaSet/healthcare-backend-stage3-d56b7644b
Containers:
  backend:
    Container ID:   containerd://bbb2e20795191d292c798560fa8f0af35ce1613bdae3451b816749d029780921
    Image:          867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:adb732d62b0513d7a4f46ebfcf31588a098b932f
    Image ID:       867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3@sha256:613c3350a56a56994cca58a3f796ac0f18cbe04a5ee0a3fccb176427eeb3de0f
    Port:           3001/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Mon, 25 Aug 2025 15:58:30 +0000
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     400m
      memory:  512Mi
    Requests:
      cpu:      200m
      memory:   256Mi
    Liveness:   http-get http://:3001/health delay=30s timeout=1s period=10s #success=1 #failure=3
    Readiness:  http-get http://:3001/health delay=5s timeout=1s period=5s #success=1 #failure=3
    Environment:
      NODE_ENV:      development
      PORT:          3001
      DATABASE_URL:  <set to the key 'url' in secret 'database-credentials-stage3'>  Optional: false
      FRONTEND_URL:  http://a46a32210135848f797d5b74ea975657-537872179.us-east-1.elb.amazonaws.com
      STAGE:         stage-3
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-lwq9q (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-lwq9q:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  11m   default-scheduler  Successfully assigned healthcare-stage3-dev/healthcare-backend-stage3-d56b7644b-cntd2 to ip-10-0-1-22.ec2.internal
  Normal  Pulling    11m   kubelet            Pulling image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:adb732d62b0513d7a4f46ebfcf31588a098b932f"
  Normal  Pulled     10m   kubelet            Successfully pulled image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:adb732d62b0513d7a4f46ebfcf31588a098b932f" in 5.803s (5.803s including waiting)
  Normal  Created    10m   kubelet            Created container backend
  Normal  Started    10m   kubelet            Started container backend
Name:             healthcare-backend-stage3-d56b7644b-rchpk
Namespace:        healthcare-stage3-dev
Priority:         0
Service Account:  default
Node:             ip-10-0-2-80.ec2.internal/10.0.2.80
Start Time:       Mon, 25 Aug 2025 15:58:08 +0000
Labels:           app=healthcare-backend-stage3
                  environment=dev
                  pod-template-hash=d56b7644b
                  stage=stage-3
                  tier=backend
Annotations:      kubectl.kubernetes.io/restartedAt: 2025-08-25T15:57:50Z
Status:           Running
IP:               10.0.2.109
IPs:
  IP:           10.0.2.109
Controlled By:  ReplicaSet/healthcare-backend-stage3-d56b7644b
Containers:
  backend:
    Container ID:   containerd://f2410c062fdb0831a3ca96266ddf9ae83f261226f8005f4fda82ffcd8d897962
    Image:          867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:adb732d62b0513d7a4f46ebfcf31588a098b932f
    Image ID:       867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3@sha256:613c3350a56a56994cca58a3f796ac0f18cbe04a5ee0a3fccb176427eeb3de0f
    Port:           3001/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Mon, 25 Aug 2025 15:58:15 +0000
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     400m
      memory:  512Mi
    Requests:
      cpu:      200m
      memory:   256Mi
    Liveness:   http-get http://:3001/health delay=30s timeout=1s period=10s #success=1 #failure=3
    Readiness:  http-get http://:3001/health delay=5s timeout=1s period=5s #success=1 #failure=3
    Environment:
      NODE_ENV:      development
      PORT:          3001
      DATABASE_URL:  <set to the key 'url' in secret 'database-credentials-stage3'>  Optional: false
      FRONTEND_URL:  http://a46a32210135848f797d5b74ea975657-537872179.us-east-1.elb.amazonaws.com
      STAGE:         stage-3
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-zqnpd (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-zqnpd:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  11m   default-scheduler  Successfully assigned healthcare-stage3-dev/healthcare-backend-stage3-d56b7644b-rchpk to ip-10-0-2-80.ec2.internal
  Normal  Pulling    11m   kubelet            Pulling image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:adb732d62b0513d7a4f46ebfcf31588a098b932f"
  Normal  Pulled     11m   kubelet            Successfully pulled image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:adb732d62b0513d7a4f46ebfcf31588a098b932f" in 6.508s (6.508s including waiting)
  Normal  Created    11m   kubelet            Created container backend
  Normal  Started    11m   kubelet            Started container backend
Name:             healthcare-frontend-stage3-646f75855b-btr5t
Namespace:        healthcare-stage3-dev
Priority:         0
Service Account:  default
Node:             ip-10-0-2-80.ec2.internal/10.0.2.80
Start Time:       Mon, 25 Aug 2025 15:58:20 +0000
Labels:           app=healthcare-frontend-stage3
                  environment=dev
                  pod-template-hash=646f75855b
                  stage=stage-3
                  tier=frontend
Annotations:      <none>
Status:           Running
IP:               10.0.2.148
IPs:
  IP:           10.0.2.148
Controlled By:  ReplicaSet/healthcare-frontend-stage3-646f75855b
Containers:
  frontend:
    Container ID:   containerd://13cf4954b0d8ed6215f0098176065a53570aff4418a9290e0e9b143563c9d037
    Image:          867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:adb732d62b0513d7a4f46ebfcf31588a098b932f
    Image ID:       867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3@sha256:e0e68565a181304f96e09fc1836e62e38f9b9b1052e146e2f17b98582d88c311
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Mon, 25 Aug 2025 15:58:22 +0000
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     200m
      memory:  256Mi
    Requests:
      cpu:      100m
      memory:   128Mi
    Liveness:   http-get http://:80/ delay=30s timeout=1s period=10s #success=1 #failure=3
    Readiness:  http-get http://:80/ delay=5s timeout=1s period=5s #success=1 #failure=3
    Environment:
      REACT_APP_API_URL:      http://backend-stage3-svc.healthcare-stage3-dev.svc.cluster.local:3001
      REACT_APP_ENVIRONMENT:  dev
      REACT_APP_STAGE:        stage-3
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-r4wb9 (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-r4wb9:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  11m   default-scheduler  Successfully assigned healthcare-stage3-dev/healthcare-frontend-stage3-646f75855b-btr5t to ip-10-0-2-80.ec2.internal
  Normal  Pulling    11m   kubelet            Pulling image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:adb732d62b0513d7a4f46ebfcf31588a098b932f"
  Normal  Pulled     11m   kubelet            Successfully pulled image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:adb732d62b0513d7a4f46ebfcf31588a098b932f" in 810ms (810ms including waiting)
  Normal  Created    11m   kubelet            Created container frontend
  Normal  Started    11m   kubelet            Started container frontend
Name:             healthcare-frontend-stage3-646f75855b-kjpzq
Namespace:        healthcare-stage3-dev
Priority:         0
Service Account:  default
Node:             ip-10-0-1-22.ec2.internal/10.0.1.22
Start Time:       Mon, 25 Aug 2025 15:58:10 +0000
Labels:           app=healthcare-frontend-stage3
                  environment=dev
                  pod-template-hash=646f75855b
                  stage=stage-3
                  tier=frontend
Annotations:      <none>
Status:           Running
IP:               10.0.1.60
IPs:
  IP:           10.0.1.60
Controlled By:  ReplicaSet/healthcare-frontend-stage3-646f75855b
Containers:
  frontend:
    Container ID:   containerd://adafeeca58f215427ac004605c3dbd90b1690e9c09172be6aa05667c0e21a429
    Image:          867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:adb732d62b0513d7a4f46ebfcf31588a098b932f
    Image ID:       867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3@sha256:e0e68565a181304f96e09fc1836e62e38f9b9b1052e146e2f17b98582d88c311
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Mon, 25 Aug 2025 15:58:11 +0000
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     200m
      memory:  256Mi
    Requests:
      cpu:      100m
      memory:   128Mi
    Liveness:   http-get http://:80/ delay=30s timeout=1s period=10s #success=1 #failure=3
    Readiness:  http-get http://:80/ delay=5s timeout=1s period=5s #success=1 #failure=3
    Environment:
      REACT_APP_API_URL:      http://backend-stage3-svc.healthcare-stage3-dev.svc.cluster.local:3001
      REACT_APP_ENVIRONMENT:  dev
      REACT_APP_STAGE:        stage-3
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-msfhx (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-msfhx:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  11m   default-scheduler  Successfully assigned healthcare-stage3-dev/healthcare-frontend-stage3-646f75855b-kjpzq to ip-10-0-1-22.ec2.internal
  Normal  Pulling    11m   kubelet            Pulling image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:adb732d62b0513d7a4f46ebfcf31588a098b932f"
  Normal  Pulled     11m   kubelet            Successfully pulled image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:adb732d62b0513d7a4f46ebfcf31588a098b932f" in 681ms (681ms including waiting)
  Normal  Created    11m   kubelet            Created container frontend
  Normal  Started    11m   kubelet            Started container frontend
📋 Checking backend logs...
Found 2 pods, using pod/healthcare-backend-stage3-d56b7644b-rchpk
::ffff:10.0.2.80 - - [25/Aug/2025:16:06:39 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:06:44 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:06:49 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:06:49 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:06:54 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:06:59 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:06:59 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:07:04 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:07:09 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:07:09 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:07:14 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:07:19 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:07:19 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:07:24 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:07:29 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:07:29 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:07:34 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:07:39 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:07:39 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:07:44 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:07:49 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:07:49 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:07:54 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:07:59 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:07:59 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:08:04 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:08:09 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:08:09 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:08:14 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:08:19 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:08:19 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:08:24 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:08:29 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:08:29 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:08:34 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:08:39 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:08:39 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:08:44 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:08:49 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:08:49 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:08:54 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:08:59 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:08:59 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:09:04 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:09:09 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:09:09 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:09:14 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:09:19 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:09:19 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:09:24 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
⏳ Waiting briefly before ALB checks...
🌐 Testing basic connectivity...
curl: (3) URL rejected: No host part in the URL
❌ LoadBalancer is not accessible
Error: Process completed with exit code 1.