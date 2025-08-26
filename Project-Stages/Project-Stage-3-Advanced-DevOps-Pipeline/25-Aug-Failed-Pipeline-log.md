Run echo "🔍 Validating automated database setup..."
🔍 Validating automated database setup...
🔍 Getting Application Load Balancer URL from Ingress...
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
              /   frontend-stage3-svc:80 (10.0.1.134:80,10.0.2.11:80)
Annotations:  alb.ingress.kubernetes.io/group.name: healthcare-stage3
              alb.ingress.kubernetes.io/healthcheck-path: /
              alb.ingress.kubernetes.io/listen-ports: [{"HTTP":80}]
              alb.ingress.kubernetes.io/scheme: internet-facing
              alb.ingress.kubernetes.io/target-type: ip
              kubernetes.io/ingress.class: alb
Events:
  Type     Reason             Age                  From     Message
  ----     ------             ----                 ----     -------
  Warning  FailedDeployModel  46m                  ingress  Failed deploy model due to operation error Elastic Load Balancing v2: DescribeListenerAttributes, https response error StatusCode: 403, RequestID: d1d43afd-3dc8-4468-8278-6786ae5fce09, api error AccessDenied: User: arn:aws:sts::867344452513:assumed-role/AmazonEKSLoadBalancerControllerRole/1756143407689695256 is not authorized to perform: elasticloadbalancing:DescribeListenerAttributes because no identity-based policy allows the elasticloadbalancing:DescribeListenerAttributes action
  
🔍 Checking for any ALBs in the region...
ℹ️ Using fallback ALB DNS: http://k8s-healthcarestage3-2fd3bd59d0-1581054579.us-east-1.elb.amazonaws.com
🔗 Using Application Load Balancer: http://k8s-healthcarestage3-2fd3bd59d0-1581054579.us-east-1.elb.amazonaws.com
🔍 Checking pod status...
NAME                                          READY   STATUS    RESTARTS   AGE
healthcare-backend-stage3-f988fc767-l5xmp     1/1     Running   0          14m
healthcare-backend-stage3-f988fc767-v6jgr     1/1     Running   0          14m
healthcare-frontend-stage3-6ddf96dfdf-ql75w   1/1     Running   0          14m
healthcare-frontend-stage3-6ddf96dfdf-wm9xc   1/1     Running   0          14m
Name:             healthcare-backend-stage3-f988fc767-l5xmp
Namespace:        healthcare-stage3-dev
Priority:         0
Service Account:  default
Node:             ip-10-0-1-22.ec2.internal/10.0.1.22
Start Time:       Mon, 25 Aug 2025 18:08:16 +0000
Labels:           app=healthcare-backend-stage3
                  environment=dev
                  pod-template-hash=f988fc767
                  stage=stage-3
                  tier=backend
Annotations:      kubectl.kubernetes.io/restartedAt: 2025-08-25T18:07:43Z
Status:           Running
IP:               10.0.1.149
IPs:
  IP:           10.0.1.149
Controlled By:  ReplicaSet/healthcare-backend-stage3-f988fc767
Containers:
  backend:
    Container ID:   containerd://5943aa6f95e805a0d4ac1eabbc97d0cbf93c3613b72830ecdcd9d795455fa296
    Image:          867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:fd1e0c0ff3c530c0fa7daa668f6bb8d8095d3182
    Image ID:       867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3@sha256:cbdab0c5c148472198f45df26d435b40329f58917f5689ac0e9a39258367d929
    Port:           3001/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Mon, 25 Aug 2025 18:08:22 +0000
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
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-jjhxz (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-jjhxz:
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
  Normal  Scheduled  14m   default-scheduler  Successfully assigned healthcare-stage3-dev/healthcare-backend-stage3-f988fc767-l5xmp to ip-10-0-1-22.ec2.internal
  Normal  Pulling    14m   kubelet            Pulling image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:fd1e0c0ff3c530c0fa7daa668f6bb8d8095d3182"
  Normal  Pulled     14m   kubelet            Successfully pulled image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:fd1e0c0ff3c530c0fa7daa668f6bb8d8095d3182" in 5.771s (5.771s including waiting)
  Normal  Created    14m   kubelet            Created container backend
  Normal  Started    14m   kubelet            Started container backend


Name:             healthcare-backend-stage3-f988fc767-v6jgr
Namespace:        healthcare-stage3-dev
Priority:         0
Service Account:  default
Node:             ip-10-0-2-80.ec2.internal/10.0.2.80
Start Time:       Mon, 25 Aug 2025 18:08:00 +0000
Labels:           app=healthcare-backend-stage3
                  environment=dev
                  pod-template-hash=f988fc767
                  stage=stage-3
                  tier=backend
Annotations:      kubectl.kubernetes.io/restartedAt: 2025-08-25T18:07:43Z
Status:           Running
IP:               10.0.2.231
IPs:
  IP:           10.0.2.231
Controlled By:  ReplicaSet/healthcare-backend-stage3-f988fc767
Containers:
  backend:
    Container ID:   containerd://845bc4f18d665a264c8107787517abe0a5c9cf0ecfb733ac17d24df9ca6eca48
    Image:          867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:fd1e0c0ff3c530c0fa7daa668f6bb8d8095d3182
    Image ID:       867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3@sha256:cbdab0c5c148472198f45df26d435b40329f58917f5689ac0e9a39258367d929
    Port:           3001/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Mon, 25 Aug 2025 18:08:08 +0000
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
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-v68kn (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-v68kn:
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
  Normal  Scheduled  14m   default-scheduler  Successfully assigned healthcare-stage3-dev/healthcare-backend-stage3-f988fc767-v6jgr to ip-10-0-2-80.ec2.internal
  Normal  Pulling    14m   kubelet            Pulling image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:fd1e0c0ff3c530c0fa7daa668f6bb8d8095d3182"
  Normal  Pulled     14m   kubelet            Successfully pulled image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:fd1e0c0ff3c530c0fa7daa668f6bb8d8095d3182" in 6.828s (6.829s including waiting)
  Normal  Created    14m   kubelet            Created container backend
  Normal  Started    14m   kubelet            Started container backend


Name:             healthcare-frontend-stage3-6ddf96dfdf-ql75w
Namespace:        healthcare-stage3-dev
Priority:         0
Service Account:  default
Node:             ip-10-0-1-22.ec2.internal/10.0.1.22
Start Time:       Mon, 25 Aug 2025 18:08:01 +0000
Labels:           app=healthcare-frontend-stage3
                  environment=dev
                  pod-template-hash=6ddf96dfdf
                  stage=stage-3
                  tier=frontend
Annotations:      <none>
Status:           Running
IP:               10.0.1.134
IPs:
  IP:           10.0.1.134
Controlled By:  ReplicaSet/healthcare-frontend-stage3-6ddf96dfdf
Containers:
  frontend:
    Container ID:   containerd://f2739ee0bfbfc4c122811401d359a6fd57c9a45c456008f30d07dced5d06eec9
    Image:          867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:fd1e0c0ff3c530c0fa7daa668f6bb8d8095d3182
    Image ID:       867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3@sha256:da878d71b361261b2e4ac04bc492fafaca5c1ef9aa1d9dd94cc50a5896bab5c1
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Mon, 25 Aug 2025 18:08:03 +0000
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
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-kcsgh (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-kcsgh:
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
  Normal  Scheduled  14m   default-scheduler  Successfully assigned healthcare-stage3-dev/healthcare-frontend-stage3-6ddf96dfdf-ql75w to ip-10-0-1-22.ec2.internal
  Normal  Pulling    14m   kubelet            Pulling image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:fd1e0c0ff3c530c0fa7daa668f6bb8d8095d3182"
  Normal  Pulled     14m   kubelet            Successfully pulled image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:fd1e0c0ff3c530c0fa7daa668f6bb8d8095d3182" in 807ms (807ms including waiting)
  Normal  Created    14m   kubelet            Created container frontend
  Normal  Started    14m   kubelet            Started container frontend


Name:             healthcare-frontend-stage3-6ddf96dfdf-wm9xc
Namespace:        healthcare-stage3-dev
Priority:         0
Service Account:  default
Node:             ip-10-0-2-80.ec2.internal/10.0.2.80
Start Time:       Mon, 25 Aug 2025 18:08:12 +0000
Labels:           app=healthcare-frontend-stage3
                  environment=dev
                  pod-template-hash=6ddf96dfdf
                  stage=stage-3
                  tier=frontend
Annotations:      <none>
Status:           Running
IP:               10.0.2.11
IPs:
  IP:           10.0.2.11
Controlled By:  ReplicaSet/healthcare-frontend-stage3-6ddf96dfdf
Containers:
  frontend:
    Container ID:   containerd://d64c8de91c23e8d78fea1fedfa0486da918a5da5d3b986bc9b825d0c7c48b6bc
    Image:          867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:fd1e0c0ff3c530c0fa7daa668f6bb8d8095d3182
    Image ID:       867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3@sha256:da878d71b361261b2e4ac04bc492fafaca5c1ef9aa1d9dd94cc50a5896bab5c1
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Mon, 25 Aug 2025 18:08:13 +0000
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
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-5mzjq (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-5mzjq:
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
  Normal  Scheduled  14m   default-scheduler  Successfully assigned healthcare-stage3-dev/healthcare-frontend-stage3-6ddf96dfdf-wm9xc to ip-10-0-2-80.ec2.internal
  Normal  Pulling    14m   kubelet            Pulling image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:fd1e0c0ff3c530c0fa7daa668f6bb8d8095d3182"
  Normal  Pulled     14m   kubelet            Successfully pulled image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:fd1e0c0ff3c530c0fa7daa668f6bb8d8095d3182" in 617ms (617ms including waiting)
  Normal  Created    14m   kubelet            Created container frontend
  Normal  Started    14m   kubelet            Started container frontend
📋 Checking backend logs...
Found 2 pods, using pod/healthcare-backend-stage3-f988fc767-v6jgr

::ffff:10.0.2.80 - - [25/Aug/2025:18:22:51 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
⏳ Waiting briefly before ALB checks...
🌐 Testing basic connectivity...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed

  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
HTTP/1.1 404 Not Found
Server: awselb/2.0
Date: Mon, 25 Aug 2025 18:23:24 GMT
Content-Type: text/plain; charset=utf-8
Content-Length: 0
Connection: keep-alive

  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
✅ LoadBalancer is accessible
🗄️ Testing health endpoint...
Health response: 
❌ Database connection failed or health endpoint not working
🔍 Debugging backend issues...
Found 2 pods, using pod/healthcare-backend-stage3-f988fc767-v6jgr

::ffff:10.0.2.80 - - [25/Aug/2025:18:23:21 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.80 - - [25/Aug/2025:18:23:21 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
Error: Process completed with exit code 1.