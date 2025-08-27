Run echo "🔍 Validating automated database setup..."
🔍 Validating automated database setup...
🔍 Getting Application Load Balancer URL from Ingress...
✅ Application Load Balancer URL found: http://k8s-healthcarestage3-2fd3bd59d0-849098463.us-east-1.elb.amazonaws.com
🔗 Using Application Load Balancer: http://k8s-healthcarestage3-2fd3bd59d0-849098463.us-east-1.elb.amazonaws.com
🔍 Checking pod status...
NAME                                          READY   STATUS    RESTARTS   AGE
healthcare-backend-stage3-6684db8cc9-c99cg    1/1     Running   0          55s
healthcare-backend-stage3-6684db8cc9-n5klt    1/1     Running   0          39s
healthcare-frontend-stage3-6469c69fdb-mwwsg   1/1     Running   0          54s
healthcare-frontend-stage3-6469c69fdb-xk7cg   1/1     Running   0          43s
Name:             healthcare-backend-stage3-6684db8cc9-c99cg
Namespace:        healthcare-stage3-dev
Priority:         0
Service Account:  default
Node:             ip-10-0-1-211.ec2.internal/10.0.1.211
Start Time:       Wed, 27 Aug 2025 17:58:05 +0000
Labels:           app=healthcare-backend-stage3
                  environment=dev
                  pod-template-hash=6684db8cc9
                  stage=stage-3
                  tier=backend
Annotations:      kubectl.kubernetes.io/restartedAt: 2025-08-27T17:57:48Z
Status:           Running
IP:               10.0.1.147
IPs:
  IP:           10.0.1.147
Controlled By:  ReplicaSet/healthcare-backend-stage3-6684db8cc9
Containers:
  backend:
    Container ID:   containerd://08052094c555897f8eda127c1408dc177b70e800891ad5aa1ce0b8b242d72023
    Image:          867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:9903f3c7d27da3c7c1340aac428f2a52e481004d
    Image ID:       867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3@sha256:89189fd8d1c89f78d35ec90dea170710f6220de9f23be2ceb8fd84ad943d0d0f
    Port:           3001/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 27 Aug 2025 17:58:13 +0000
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
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-btvcq (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-btvcq:
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
  Normal  Scheduled  55s   default-scheduler  Successfully assigned healthcare-stage3-dev/healthcare-backend-stage3-6684db8cc9-c99cg to ip-10-0-1-211.ec2.internal
  Normal  Pulling    55s   kubelet            Pulling image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:9903f3c7d27da3c7c1340aac428f2a52e481004d"
  Normal  Pulled     48s   kubelet            Successfully pulled image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:9903f3c7d27da3c7c1340aac428f2a52e481004d" in 6.848s (6.848s including waiting)
  Normal  Created    48s   kubelet            Created container backend
  Normal  Started    48s   kubelet            Started container backend
Name:             healthcare-backend-stage3-6684db8cc9-n5klt
Namespace:        healthcare-stage3-dev
Priority:         0
Service Account:  default
Node:             ip-10-0-2-216.ec2.internal/10.0.2.216
Start Time:       Wed, 27 Aug 2025 17:58:21 +0000
Labels:           app=healthcare-backend-stage3
                  environment=dev
                  pod-template-hash=6684db8cc9
                  stage=stage-3
                  tier=backend
Annotations:      kubectl.kubernetes.io/restartedAt: 2025-08-27T17:57:48Z
Status:           Running
IP:               10.0.2.138
IPs:
  IP:           10.0.2.138
Controlled By:  ReplicaSet/healthcare-backend-stage3-6684db8cc9
Containers:
  backend:
    Container ID:   containerd://5b776d1ae1ff0571a9ffa408264faf13a395f82201b34987d83f6d7ee337a1ac
    Image:          867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:9903f3c7d27da3c7c1340aac428f2a52e481004d
    Image ID:       867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3@sha256:89189fd8d1c89f78d35ec90dea170710f6220de9f23be2ceb8fd84ad943d0d0f
    Port:           3001/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 27 Aug 2025 17:58:27 +0000
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
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-2bwhh (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-2bwhh:
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
  Normal  Scheduled  40s   default-scheduler  Successfully assigned healthcare-stage3-dev/healthcare-backend-stage3-6684db8cc9-n5klt to ip-10-0-2-216.ec2.internal
  Normal  Pulling    40s   kubelet            Pulling image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:9903f3c7d27da3c7c1340aac428f2a52e481004d"
  Normal  Pulled     34s   kubelet            Successfully pulled image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:9903f3c7d27da3c7c1340aac428f2a52e481004d" in 5.721s (5.721s including waiting)
  Normal  Created    34s   kubelet            Created container backend
  Normal  Started    34s   kubelet            Started container backend
Name:             healthcare-frontend-stage3-6469c69fdb-mwwsg
Namespace:        healthcare-stage3-dev
Priority:         0
Service Account:  default
Node:             ip-10-0-1-211.ec2.internal/10.0.1.211
Start Time:       Wed, 27 Aug 2025 17:58:06 +0000
Labels:           app=healthcare-frontend-stage3
                  environment=dev
                  pod-template-hash=6469c69fdb
                  stage=stage-3
                  tier=frontend
Annotations:      <none>
Status:           Running
IP:               10.0.1.5
IPs:
  IP:           10.0.1.5
Controlled By:  ReplicaSet/healthcare-frontend-stage3-6469c69fdb
Containers:
  frontend:
    Container ID:   containerd://f8b09b152ef05ebfa71a99b7ae54f84881f179ecda9dc35127f7b07223fde35f
    Image:          867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:9903f3c7d27da3c7c1340aac428f2a52e481004d
    Image ID:       867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3@sha256:7c63858a127c5cb0e04c13514c91912ecc84bd911ec540514895e6e040d2b361
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 27 Aug 2025 17:58:09 +0000
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
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-wztc4 (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-wztc4:
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
  Normal  Scheduled  54s   default-scheduler  Successfully assigned healthcare-stage3-dev/healthcare-frontend-stage3-6469c69fdb-mwwsg to ip-10-0-1-211.ec2.internal
  Normal  Pulling    54s   kubelet            Pulling image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:9903f3c7d27da3c7c1340aac428f2a52e481004d"
  Normal  Pulled     53s   kubelet            Successfully pulled image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:9903f3c7d27da3c7c1340aac428f2a52e481004d" in 1.482s (1.482s including waiting)
  Normal  Created    53s   kubelet            Created container frontend
  Normal  Started    52s   kubelet            Started container frontend
Name:             healthcare-frontend-stage3-6469c69fdb-xk7cg
Namespace:        healthcare-stage3-dev
Priority:         0
Service Account:  default
Node:             ip-10-0-2-216.ec2.internal/10.0.2.216
Start Time:       Wed, 27 Aug 2025 17:58:17 +0000
Labels:           app=healthcare-frontend-stage3
                  environment=dev
                  pod-template-hash=6469c69fdb
                  stage=stage-3
                  tier=frontend
Annotations:      <none>
Status:           Running
IP:               10.0.2.182
IPs:
  IP:           10.0.2.182
Controlled By:  ReplicaSet/healthcare-frontend-stage3-6469c69fdb
Containers:
  frontend:
    Container ID:   containerd://9ac0a081ea522852f61f0169f96b091c052c337336742f1683aad86edabf5e87
    Image:          867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:9903f3c7d27da3c7c1340aac428f2a52e481004d
    Image ID:       867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3@sha256:7c63858a127c5cb0e04c13514c91912ecc84bd911ec540514895e6e040d2b361
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 27 Aug 2025 17:58:18 +0000
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
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-nwmkm (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-nwmkm:
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
  Normal  Scheduled  44s   default-scheduler  Successfully assigned healthcare-stage3-dev/healthcare-frontend-stage3-6469c69fdb-xk7cg to ip-10-0-2-216.ec2.internal
  Normal  Pulling    44s   kubelet            Pulling image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:9903f3c7d27da3c7c1340aac428f2a52e481004d"
  Normal  Pulled     43s   kubelet            Successfully pulled image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:9903f3c7d27da3c7c1340aac428f2a52e481004d" in 607ms (607ms including waiting)
  Normal  Created    43s   kubelet            Created container frontend
  Normal  Started    43s   kubelet            Started container frontend
📋 Checking backend logs...
Found 2 pods, using pod/healthcare-backend-stage3-6684db8cc9-c99cg
> healthcare-backend-stage3@1.0.0 start
> node dist/app.js
🚀 Server running on http://localhost:3001
📊 Health check: http://localhost:3001/health
🏥 API Base: http://localhost:3001/api
👨‍⚕️ Doctors API: http://localhost:3001/api/doctors
🏢 Departments API: http://localhost:3001/api/doctors/departments
🗓️ Appointments API: http://localhost:3001/api/appointments
🔐 Auth API: http://localhost:3001/api/auth
🌍 Environment: development
::ffff:10.0.1.211 - - [27/Aug/2025:17:58:21 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.102.73 - - [27/Aug/2025:17:58:23 +0000] "GET / HTTP/1.1" 404 186 "-" "ELB-HealthChecker/2.0"
::ffff:10.0.101.173 - - [27/Aug/2025:17:58:25 +0000] "GET / HTTP/1.1" 404 186 "-" "ELB-HealthChecker/2.0"
::ffff:10.0.103.112 - - [27/Aug/2025:17:58:25 +0000] "GET / HTTP/1.1" 404 186 "-" "ELB-HealthChecker/2.0"
::ffff:10.0.1.211 - - [27/Aug/2025:17:58:26 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.1.211 - - [27/Aug/2025:17:58:31 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.1.211 - - [27/Aug/2025:17:58:36 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.102.73 - - [27/Aug/2025:17:58:38 +0000] "GET / HTTP/1.1" 404 186 "-" "ELB-HealthChecker/2.0"
::ffff:10.0.103.112 - - [27/Aug/2025:17:58:40 +0000] "GET / HTTP/1.1" 404 186 "-" "ELB-HealthChecker/2.0"
::ffff:10.0.101.173 - - [27/Aug/2025:17:58:40 +0000] "GET / HTTP/1.1" 404 186 "-" "ELB-HealthChecker/2.0"
::ffff:10.0.1.211 - - [27/Aug/2025:17:58:41 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.1.211 - - [27/Aug/2025:17:58:46 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.1.211 - - [27/Aug/2025:17:58:46 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.1.211 - - [27/Aug/2025:17:58:51 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.102.73 - - [27/Aug/2025:17:58:53 +0000] "GET / HTTP/1.1" 404 186 "-" "ELB-HealthChecker/2.0"
::ffff:10.0.103.112 - - [27/Aug/2025:17:58:55 +0000] "GET / HTTP/1.1" 404 186 "-" "ELB-HealthChecker/2.0"
::ffff:10.0.101.173 - - [27/Aug/2025:17:58:55 +0000] "GET / HTTP/1.1" 404 186 "-" "ELB-HealthChecker/2.0"
::ffff:10.0.1.211 - - [27/Aug/2025:17:58:56 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.1.211 - - [27/Aug/2025:17:58:56 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.1.211 - - [27/Aug/2025:17:59:01 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
⏳ Waiting briefly before ALB checks...
🌐 Testing basic connectivity...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
  0   464    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
HTTP/1.1 200 OK
Date: Wed, 27 Aug 2025 17:59:32 GMT
Content-Type: text/html
Content-Length: 464
Connection: keep-alive
Server: nginx/1.29.1
Last-Modified: Wed, 27 Aug 2025 17:47:41 GMT
ETag: "68af44bd-1d0"
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Referrer-Policy: no-referrer-when-downgrade
Accept-Ranges: bytes
✅ LoadBalancer is accessible
🗄️ Testing health endpoint...
Health response: {"status":"healthy","service":"healthcare-backend","timestamp":"2025-08-27T17:59:32.266Z","uptime":77.729413716,"environment":"development","version":"1.0.0","database":"connected","memory":{"rss":75460608,"heapTotal":14983168,"heapUsed":12674912,"external":1076161,"arrayBuffers":42968}}
✅ Database connection successful
👨‍⚕️ Testing doctors endpoint...
Doctors response: {"success":true,"data":{"doctors":[],"pagination":{"page":1,"limit":10,"total":0,"totalPages":0}},"message":"Found 0 doctors"}
❌ Sample data not available - investigating...
HTTP Status: 200
Error: Process completed with exit code 1.