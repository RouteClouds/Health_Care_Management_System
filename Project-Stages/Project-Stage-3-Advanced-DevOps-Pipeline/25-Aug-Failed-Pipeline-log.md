Please check the following failed Logs 
1.Unit Tests (Node 18.x)
Install dependencies 
Run `npm audit` for details.
Error: The operation was canceled.
2.Pipeline from Stage Build & Push Images to Deploy Application with Automation skipped
3.Automated GitOps Recovery failed at Validate Recovery Success
Run echo "🔍 Validating recovery success..."
🔍 Validating recovery success...
❌ Application Load Balancer URL not available
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
              /      frontend-stage3-svc:80 (10.0.1.134:80,10.0.2.11:80,10.0.1.23:80)
              /api   backend-stage3-svc:3001 (10.0.2.231:3001,10.0.1.149:3001,10.0.2.35:3001)
Annotations:  alb.ingress.kubernetes.io/group.name: healthcare-stage3
              alb.ingress.kubernetes.io/healthcheck-path: /
              alb.ingress.kubernetes.io/listen-ports: [{"HTTP":80}]
              alb.ingress.kubernetes.io/scheme: internet-facing
              alb.ingress.kubernetes.io/target-type: ip
              kubernetes.io/ingress.class: alb
Events:
  Type     Reason             Age   From     Message
  ----     ------             ----  ----     -------
  
  Warning  FailedDeployModel  10m   ingress  Failed deploy model due to operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: 7c8512f8-e579-49d6-8380-633d0bbe11e5, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756213906717302249 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action
Error: Process completed with exit code 1.
