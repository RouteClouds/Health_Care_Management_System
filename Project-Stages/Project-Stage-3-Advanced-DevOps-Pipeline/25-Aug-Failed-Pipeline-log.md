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
              /   frontend-stage3-svc:80 (10.0.1.23:80,10.0.2.125:80)
Annotations:  alb.ingress.kubernetes.io/group.name: healthcare-stage3
              alb.ingress.kubernetes.io/healthcheck-path: /
              alb.ingress.kubernetes.io/listen-ports: [{"HTTP":80}]
              alb.ingress.kubernetes.io/scheme: internet-facing
              alb.ingress.kubernetes.io/target-type: ip
              kubernetes.io/ingress.class: alb
Events:
  Type     Reason             Age   From     Message
  ----     ------             ----  ----     -------
  Warning  FailedDeployModel  50m   ingress  Failed deploy model due to operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: 0f7f6543-63ef-4ba4-a79e-2a164632e0f0, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756137921752723319 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action
  Warning  FailedDeployModel  33m   ingress  Failed deploy model due to operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: e6c2ca30-3d16-4da3-bc5b-3b597d43a26c, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756137921752723319 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action
  Warning  FailedDeployModel  17m   ingress  Failed deploy model due to operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: b64f4010-67b7-4826-a9a8-091101c16f95, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756137921752723319 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action
  Warning  FailedDeployModel  20s   ingress  Failed deploy model due to operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: 7ffe74cc-befe-48de-9459-89f219be14b1, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756137921752723319 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action
🔍 Checking AWS Load Balancer Controller logs...
Found 2 pods, using pod/aws-load-balancer-controller-79dc84dff7-2rszk
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
{"level":"info","ts":"2025-08-25T16:22:02Z","logger":"controllers.ingress","msg":"Auto Create SG","LB SGs":[{"$ref":"#/resources/AWS::EC2::SecurityGroup/ManagedLBSecurityGroup/status/groupID"},"sg-03c0dbbf55937c065"],"backend SG":"sg-03c0dbbf55937c065"}
{"level":"info","ts":"2025-08-25T16:22:02Z","logger":"controllers.ingress","msg":"successfully built model","model":"{\"id\":\"healthcare-stage3\",\"resources\":{\"AWS::EC2::SecurityGroup\":{\"ManagedLBSecurityGroup\":{\"spec\":{\"groupName\":\"k8s-healthcarestage3-8fb288ef6a\",\"description\":\"[k8s] Managed SecurityGroup for LoadBalancer\",\"ingress\":[{\"ipProtocol\":\"tcp\",\"fromPort\":80,\"toPort\":80,\"ipRanges\":[{\"cidrIP\":\"0.0.0.0/0\"}]}]}}},\"AWS::ElasticLoadBalancingV2::Listener\":{\"80\":{\"spec\":{\"loadBalancerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::LoadBalancer/LoadBalancer/status/loadBalancerARN\"},\"port\":80,\"protocol\":\"HTTP\",\"defaultActions\":[{\"type\":\"fixed-response\",\"fixedResponseConfig\":{\"contentType\":\"text/plain\",\"statusCode\":\"404\"}}]}}},\"AWS::ElasticLoadBalancingV2::ListenerRule\":{\"80:1\":{\"spec\":{\"listenerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::Listener/80/status/listenerARN\"},\"priority\":1,\"actions\":[{\"type\":\"fo
{"level":"error","ts":"2025-08-25T16:22:03Z","msg":"Reconciler error","controller":"ingress","object":{"name":"healthcare-stage3"},"namespace":"","name":"healthcare-stage3","reconcileID":"9cb05165-1947-4aed-be44-bad0e3a03350","error":"operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: e6c2ca30-3d16-4da3-bc5b-3b597d43a26c, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756137921752723319 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action"}
{"level":"info","ts":"2025-08-25T16:38:43Z","logger":"controllers.ingress","msg":"Auto Create SG","LB SGs":[{"$ref":"#/resources/AWS::EC2::SecurityGroup/ManagedLBSecurityGroup/status/groupID"},"sg-03c0dbbf55937c065"],"backend SG":"sg-03c0dbbf55937c065"}
{"level":"info","ts":"2025-08-25T16:38:43Z","logger":"controllers.ingress","msg":"successfully built model","model":"{\"id\":\"healthcare-stage3\",\"resources\":{\"AWS::EC2::SecurityGroup\":{\"ManagedLBSecurityGroup\":{\"spec\":{\"groupName\":\"k8s-healthcarestage3-8fb288ef6a\",\"description\":\"[k8s] Managed SecurityGroup for LoadBalancer\",\"ingress\":[{\"ipProtocol\":\"tcp\",\"fromPort\":80,\"toPort\":80,\"ipRanges\":[{\"cidrIP\":\"0.0.0.0/0\"}]}]}}},\"AWS::ElasticLoadBalancingV2::Listener\":{\"80\":{\"spec\":{\"loadBalancerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::LoadBalancer/LoadBalancer/status/loadBalancerARN\"},\"port\":80,\"protocol\":\"HTTP\",\"defaultActions\":[{\"type\":\"fixed-response\",\"fixedResponseConfig\":{\"contentType\":\"text/plain\",\"statusCode\":\"404\"}}]}}},\"AWS::ElasticLoadBalancingV2::ListenerRule\":{\"80:1\":{\"spec\":{\"listenerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::Listener/80/status/listenerARN\"},\"priority\":1,\"actions\":[{\"type\":\"fo
{"level":"error","ts":"2025-08-25T16:38:43Z","msg":"Reconciler error","controller":"ingress","object":{"name":"healthcare-stage3"},"namespace":"","name":"healthcare-stage3","reconcileID":"4e00a556-e95d-4078-96ba-456e11b19613","error":"operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: b64f4010-67b7-4826-a9a8-091101c16f95, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756137921752723319 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action"}
{"level":"info","ts":"2025-08-25T16:55:23Z","logger":"controllers.ingress","msg":"Auto Create SG","LB SGs":[{"$ref":"#/resources/AWS::EC2::SecurityGroup/ManagedLBSecurityGroup/status/groupID"},"sg-03c0dbbf55937c065"],"backend SG":"sg-03c0dbbf55937c065"}
{"level":"info","ts":"2025-08-25T16:55:23Z","logger":"controllers.ingress","msg":"successfully built model","model":"{\"id\":\"healthcare-stage3\",\"resources\":{\"AWS::EC2::SecurityGroup\":{\"ManagedLBSecurityGroup\":{\"spec\":{\"groupName\":\"k8s-healthcarestage3-8fb288ef6a\",\"description\":\"[k8s] Managed SecurityGroup for LoadBalancer\",\"ingress\":[{\"ipProtocol\":\"tcp\",\"fromPort\":80,\"toPort\":80,\"ipRanges\":[{\"cidrIP\":\"0.0.0.0/0\"}]}]}}},\"AWS::ElasticLoadBalancingV2::Listener\":{\"80\":{\"spec\":{\"loadBalancerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::LoadBalancer/LoadBalancer/status/loadBalancerARN\"},\"port\":80,\"protocol\":\"HTTP\",\"defaultActions\":[{\"type\":\"fixed-response\",\"fixedResponseConfig\":{\"contentType\":\"text/plain\",\"statusCode\":\"404\"}}]}}},\"AWS::ElasticLoadBalancingV2::ListenerRule\":{\"80:1\":{\"spec\":{\"listenerARN\":{\"$ref\":\"#/resources/AWS::ElasticLoadBalancingV2::Listener/80/status/listenerARN\"},\"priority\":1,\"actions\":[{\"type\":\"fo
{"level":"error","ts":"2025-08-25T16:55:24Z","msg":"Reconciler error","controller":"ingress","object":{"name":"healthcare-stage3"},"namespace":"","name":"healthcare-stage3","reconcileID":"9fa7b353-b747-4398-a72e-07bd3059c9db","error":"operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: 7ffe74cc-befe-48de-9459-89f219be14b1, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756137921752723319 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action"}
🔍 Checking for any ALBs in the region...
ℹ️ Using fallback ALB DNS: http://k8s-healthcarestage3-2fd3bd59d0-1581054579.us-east-1.elb.amazonaws.com
🔗 Using Application Load Balancer: http://k8s-healthcarestage3-2fd3bd59d0-1581054579.us-east-1.elb.amazonaws.com
🔍 Checking pod status...
NAME                                          READY   STATUS    RESTARTS   AGE
healthcare-backend-stage3-6ff8dc4897-2khn9    1/1     Running   0          10m
healthcare-backend-stage3-6ff8dc4897-c529h    1/1     Running   0          11m
healthcare-frontend-stage3-785b4dfc5b-76fdx   1/1     Running   0          10m
healthcare-frontend-stage3-785b4dfc5b-fv8pg   1/1     Running   0          11m
Name:             healthcare-backend-stage3-6ff8dc4897-2khn9
Namespace:        healthcare-stage3-dev
Priority:         0
Service Account:  default
Node:             ip-10-0-1-22.ec2.internal/10.0.1.22
Start Time:       Mon, 25 Aug 2025 16:44:51 +0000
Labels:           app=healthcare-backend-stage3
                  environment=dev
                  pod-template-hash=6ff8dc4897
                  stage=stage-3
                  tier=backend
Annotations:      kubectl.kubernetes.io/restartedAt: 2025-08-25T16:44:18Z
Status:           Running
IP:               10.0.1.24
IPs:
  IP:           10.0.1.24
Controlled By:  ReplicaSet/healthcare-backend-stage3-6ff8dc4897
Containers:
  backend:
    Container ID:   containerd://d2c8913d072edd496dac72e0e8325d934bf0ecd1c995a1b42e47ea0b7e405c72
    Image:          867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:583b1b5587aa731d4173097d10c70b7219c40352
    Image ID:       867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3@sha256:5b47f558d7d6f108eff2a79f80d99c16851a6e52e62b3b41f474a1f5bbad3b29
    Port:           3001/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Mon, 25 Aug 2025 16:44:57 +0000
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
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-7767l (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-7767l:
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
  Normal  Scheduled  10m   default-scheduler  Successfully assigned healthcare-stage3-dev/healthcare-backend-stage3-6ff8dc4897-2khn9 to ip-10-0-1-22.ec2.internal
  Normal  Pulling    10m   kubelet            Pulling image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:583b1b5587aa731d4173097d10c70b7219c40352"
  Normal  Pulled     10m   kubelet            Successfully pulled image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:583b1b5587aa731d4173097d10c70b7219c40352" in 5.788s (5.789s including waiting)
  Normal  Created    10m   kubelet            Created container backend
  Normal  Started    10m   kubelet            Started container backend
Name:             healthcare-backend-stage3-6ff8dc4897-c529h
Namespace:        healthcare-stage3-dev
Priority:         0
Service Account:  default
Node:             ip-10-0-2-80.ec2.internal/10.0.2.80
Start Time:       Mon, 25 Aug 2025 16:44:35 +0000
Labels:           app=healthcare-backend-stage3
                  environment=dev
                  pod-template-hash=6ff8dc4897
                  stage=stage-3
                  tier=backend
Annotations:      kubectl.kubernetes.io/restartedAt: 2025-08-25T16:44:18Z
Status:           Running
IP:               10.0.2.231
IPs:
  IP:           10.0.2.231
Controlled By:  ReplicaSet/healthcare-backend-stage3-6ff8dc4897
Containers:
  backend:
    Container ID:   containerd://8fb3fd12fc43f0578254a5eed966d87b709601bb7db27a053af665f342bf9b5b
    Image:          867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:583b1b5587aa731d4173097d10c70b7219c40352
    Image ID:       867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3@sha256:5b47f558d7d6f108eff2a79f80d99c16851a6e52e62b3b41f474a1f5bbad3b29
    Port:           3001/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Mon, 25 Aug 2025 16:44:43 +0000
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
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-4bbdn (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-4bbdn:
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
  Normal  Scheduled  11m   default-scheduler  Successfully assigned healthcare-stage3-dev/healthcare-backend-stage3-6ff8dc4897-c529h to ip-10-0-2-80.ec2.internal
  Normal  Pulling    11m   kubelet            Pulling image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:583b1b5587aa731d4173097d10c70b7219c40352"
  Normal  Pulled     11m   kubelet            Successfully pulled image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:583b1b5587aa731d4173097d10c70b7219c40352" in 6.975s (6.975s including waiting)
  Normal  Created    11m   kubelet            Created container backend
  Normal  Started    11m   kubelet            Started container backend
Name:             healthcare-frontend-stage3-785b4dfc5b-76fdx
Namespace:        healthcare-stage3-dev
Priority:         0
Service Account:  default
Node:             ip-10-0-2-80.ec2.internal/10.0.2.80
Start Time:       Mon, 25 Aug 2025 16:44:47 +0000
Labels:           app=healthcare-frontend-stage3
                  environment=dev
                  pod-template-hash=785b4dfc5b
                  stage=stage-3
                  tier=frontend
Annotations:      <none>
Status:           Running
IP:               10.0.2.125
IPs:
  IP:           10.0.2.125
Controlled By:  ReplicaSet/healthcare-frontend-stage3-785b4dfc5b
Containers:
  frontend:
    Container ID:   containerd://4801f8eca76e1f1fa6a5d361bb46b5f78c7fd87fbc091a54104365de19408d81
    Image:          867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:583b1b5587aa731d4173097d10c70b7219c40352
    Image ID:       867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3@sha256:22aba8d914f2f3b7975368a5777b83637c7bec24662a5c6235a0b0cf3855205d
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Mon, 25 Aug 2025 16:44:48 +0000
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
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-5rwj9 (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-5rwj9:
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
  Normal  Scheduled  11m   default-scheduler  Successfully assigned healthcare-stage3-dev/healthcare-frontend-stage3-785b4dfc5b-76fdx to ip-10-0-2-80.ec2.internal
  Normal  Pulling    11m   kubelet            Pulling image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:583b1b5587aa731d4173097d10c70b7219c40352"
  Normal  Pulled     10m   kubelet            Successfully pulled image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:583b1b5587aa731d4173097d10c70b7219c40352" in 709ms (709ms including waiting)
  Normal  Created    10m   kubelet            Created container frontend
  Normal  Started    10m   kubelet            Started container frontend
Name:             healthcare-frontend-stage3-785b4dfc5b-fv8pg
Namespace:        healthcare-stage3-dev
Priority:         0
Service Account:  default
Node:             ip-10-0-1-22.ec2.internal/10.0.1.22
Start Time:       Mon, 25 Aug 2025 16:44:36 +0000
Labels:           app=healthcare-frontend-stage3
                  environment=dev
                  pod-template-hash=785b4dfc5b
                  stage=stage-3
                  tier=frontend
Annotations:      <none>
Status:           Running
IP:               10.0.1.23
IPs:
  IP:           10.0.1.23
Controlled By:  ReplicaSet/healthcare-frontend-stage3-785b4dfc5b
Containers:
  frontend:
    Container ID:   containerd://2d119bff4481651208edce5d56a17dc64273d064fefc4cf0eed27600b1006933
    Image:          867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:583b1b5587aa731d4173097d10c70b7219c40352
    Image ID:       867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3@sha256:22aba8d914f2f3b7975368a5777b83637c7bec24662a5c6235a0b0cf3855205d
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Mon, 25 Aug 2025 16:44:37 +0000
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
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-vhlqq (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-vhlqq:
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
  Normal  Scheduled  11m   default-scheduler  Successfully assigned healthcare-stage3-dev/healthcare-frontend-stage3-785b4dfc5b-fv8pg to ip-10-0-1-22.ec2.internal
  Normal  Pulling    11m   kubelet            Pulling image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:583b1b5587aa731d4173097d10c70b7219c40352"
  Normal  Pulled     11m   kubelet            Successfully pulled image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:583b1b5587aa731d4173097d10c70b7219c40352" in 607ms (607ms including waiting)
  Normal  Created    11m   kubelet            Created container frontend
  Normal  Started    11m   kubelet            Started container frontend
📋 Checking backend logs...
Found 2 pods, using pod/healthcare-backend-stage3-6ff8dc4897-c529h
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:06 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:06 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:11 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:16 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:16 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:21 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:26 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:26 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:31 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:36 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:36 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:41 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:46 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:46 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:51 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:56 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:56 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:01 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:06 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:06 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:11 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:16 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:16 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:21 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:26 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:26 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:31 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:36 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:36 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:41 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:46 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:46 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:51 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:56 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:56 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:01 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:06 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:06 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:11 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:16 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:16 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:21 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:26 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:26 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:31 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:36 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:36 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:41 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:46 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:46 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
⏳ Waiting briefly before ALB checks...
🌐 Testing basic connectivity...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
HTTP/1.1 404 Not Found
Server: awselb/2.0
Date: Mon, 25 Aug 2025 16:56:18 GMT
Content-Type: text/plain; charset=utf-8
Content-Length: 0
Connection: keep-alive
✅ LoadBalancer is accessible
🗄️ Testing health endpoint...
Health response: 
❌ Database connection failed or health endpoint not working
🔍 Debugging backend issues...
Found 2 pods, using pod/healthcare-backend-stage3-6ff8dc4897-c529h
::ffff:10.0.2.80 - - [25/Aug/2025:16:50:46 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:50:51 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:50:56 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:50:56 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:51:01 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:51:06 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:51:06 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:51:11 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:51:16 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:51:16 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:51:21 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:51:26 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:51:26 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:51:31 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:51:36 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:51:36 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:51:41 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:51:46 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:51:46 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:51:51 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:51:56 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:51:56 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:52:01 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:52:06 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:52:06 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:52:11 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:52:16 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:52:16 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:52:21 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:52:26 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:52:26 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:52:31 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:52:36 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:52:36 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:52:41 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:52:46 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:52:46 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:52:51 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:52:56 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:52:56 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:01 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:06 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:06 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:11 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:16 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:16 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:21 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:26 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:26 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:31 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:36 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:36 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:41 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:46 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:46 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:51 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:56 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:53:56 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:01 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:06 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:06 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:11 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:16 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:16 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:21 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:26 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:26 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:31 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:36 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:36 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:41 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:46 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:46 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:51 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:56 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:54:56 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:01 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:06 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:06 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:11 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:16 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:16 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:21 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:26 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:26 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:31 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:36 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:36 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:41 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:46 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:46 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:51 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:56 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:55:56 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:56:01 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:56:06 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:56:06 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:56:11 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:56:16 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:16:56:16 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
Error: Process completed with exit code 1.
0s
Run echo "🧹 Cleaning up temporary files..."
🧹 Cleaning up temporary files...
ℹ️ No backup file found, skipping restore
0s
Post job cleanup.
1s
Post job cleanup.
/usr/bin/git version
git version 2.51.0
Temporarily overriding HOME='/home/runner/work/_temp/957e22e8-5868-4160-8eb2-c90afa2cca95' before making global git config changes
Adding repository directory to the temporary git global config as a safe directory
/usr/bin/git config --global --add safe.directory /home/runner/work/Health_Care_Management_System/Health_Care_Management_System
/usr/bin/git config --local --name-only --get-regexp core\.sshCommand
/usr/bin/git submodule foreach --recursive sh -c "git config --local --name-only --get-regexp 'core\.sshCommand' && git config --local --unset-all 'core.sshCommand' || :"
/usr/bin/git config --local --name-only --get-regexp http\.https\:\/\/github\.com\/\.extraheader
http.https://github.com/.extraheader
/usr/bin/git config --local --unset-all http.https://github.com/.extraheader
/usr/bin/git submodule foreach --recursive sh -c "git config --local --name-only --get-regexp 'http\.https\:\/\/github\.com\/\.extraheader' && git config --local --unset-all 'http.https://github.com/.extraheader' || :"