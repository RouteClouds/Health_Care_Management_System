Run echo "🔍 Validating automated database setup..."
  echo "🔍 Validating automated database setup..."
  
  # Get Application Load Balancer URL from Ingress
  echo "🔍 Getting Application Load Balancer URL from Ingress..."
  
  # Wait for Ingress to get ALB address
  for i in {1..20}; do
    ALB_URL=$(kubectl get ingress healthcare-stage3-ingress -n healthcare-stage3-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
    if [[ -n "$ALB_URL" ]]; then
      echo "✅ Application Load Balancer URL found: http://$ALB_URL"
      break
    else
      echo "⏳ Waiting for ALB to be provisioned... (attempt $i/20)"
      sleep 30
    fi
  done
  
  if [[ -z "$ALB_URL" ]]; then
    echo "❌ Application Load Balancer URL not found after 10 minutes"
    echo "🔍 Checking Ingress status..."
    kubectl describe ingress healthcare-stage3-ingress -n healthcare-stage3-dev || true
    echo "🔍 Checking AWS Load Balancer Controller logs..."
    kubectl logs deployment/aws-load-balancer-controller -n kube-system --tail=50 || echo "Controller logs not available"
  
    # Fallback: try to get any ALB in the region and use its DNS as LB_URL
    echo "🔍 Checking for any ALBs in the region..."
    FALLBACK_ALB=$(aws elbv2 describe-load-balancers --region us-east-1 --query 'LoadBalancers[?Type==`application`].[DNSName]' --output text | head -n1 || true)
    if [[ -n "$FALLBACK_ALB" ]]; then
      LB_URL="$FALLBACK_ALB"
      echo "ℹ️ Using fallback ALB DNS: http://$LB_URL"
    else
      echo "❌ No ALBs found via fallback"
      exit 1
    fi
  else
    LB_URL="$ALB_URL"
  fi
  
  echo "🔗 Using Application Load Balancer: http://$LB_URL"
  
  # Ensure LB_URL is set only once
  :
  
  # Check pod status first
  echo "🔍 Checking pod status..."
  kubectl get pods -n healthcare-stage3-dev
  kubectl describe pods -n healthcare-stage3-dev
  
  # Check backend logs for errors
  echo "📋 Checking backend logs..."
  kubectl logs deployment/healthcare-backend-stage3 -n healthcare-stage3-dev --tail=50 || echo "Could not get backend logs"
  
  # Wait for LoadBalancer to be ready
  echo "⏳ Waiting briefly before ALB checks..."
  sleep 30
  
  # Test basic connectivity first
  echo "🌐 Testing basic connectivity..."
  if curl -I "http://${LB_URL}" --connect-timeout 10 --max-time 30; then
    echo "✅ LoadBalancer is accessible"
  else
    echo "❌ LoadBalancer is not accessible"
    exit 1
  fi
  
  # Test health endpoint with detailed output
  echo "🗄️ Testing health endpoint..."
  HEALTH_RESPONSE=$(curl -s "http://${LB_URL}/api/health" || echo "CURL_FAILED")
  echo "Health response: $HEALTH_RESPONSE"
  
  if echo "$HEALTH_RESPONSE" | jq -e '.database == "connected"' >/dev/null 2>&1; then
    echo "✅ Database connection successful"
  else
    echo "❌ Database connection failed or health endpoint not working"
    echo "🔍 Debugging backend issues..."
    echo "📋 Checking backend logs..."
    BACKEND_POD=$(kubectl get pods -n healthcare-stage3-dev -l app=healthcare-backend-stage3 -o jsonpath='{.items[0].metadata.name}')
    echo "Found 1 pod, using pod/$BACKEND_POD"
    kubectl logs "$BACKEND_POD" -n healthcare-stage3-dev --tail=200 || true
    exit 1
  fi
  
  # Test doctors endpoint with detailed debugging
  echo "👨‍⚕️ Testing doctors endpoint..."
  DOCTORS_RESPONSE=$(curl -s "http://${LB_URL}/api/doctors" || echo "CURL_FAILED")
  echo "Doctors response: $DOCTORS_RESPONSE"
  
  if echo "$DOCTORS_RESPONSE" | jq -e '.data.doctors | length > 0' >/dev/null 2>&1; then
    echo "✅ Sample data available - automated database seeding successful"
  else
    echo "❌ Sample data not available - investigating..."
  
    # Check if it's a 500 error or other issue
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://${LB_URL}/api/doctors")
    echo "HTTP Status: $HTTP_STATUS"
  
    if [[ "$HTTP_STATUS" == "500" ]]; then
      echo "🔍 500 Internal Server Error detected - checking backend logs..."
      kubectl logs deployment/healthcare-backend-stage3 -n healthcare-stage3-dev --tail=100
  
      # Check database connection from backend pod
      echo "🗄️ Testing database connection from backend pod..."
      BACKEND_POD=$(kubectl get pods -n healthcare-stage3-dev -l app=healthcare-backend-stage3 -o jsonpath='{.items[0].metadata.name}')
      if [[ -n "$BACKEND_POD" ]]; then
        echo "Testing from pod: $BACKEND_POD"
        kubectl exec -n healthcare-stage3-dev "$BACKEND_POD" -- env | grep -E "(DATABASE|DB_)" || echo "No database env vars found"
      fi
    fi
  
    exit 1
  fi
  
  echo "🎉 Automated database setup validation completed successfully!"
  shell: /usr/bin/bash -e {0}
  env:
    SOURCE_CODE_PATH: ./Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/src-code
    TERRAFORM_PATH: ./Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/terraform
    STAGE: stage-3
    AWS_REGION: us-east-1
    AWS_DEFAULT_REGION: us-east-1
    AWS_ACCESS_KEY_ID: ***
    AWS_SECRET_ACCESS_KEY: ***
    TERRAFORM_CLI_PATH: /home/runner/work/_temp/4bbd613c-3ba9-477d-b5b3-4ab048eecdfa
🔍 Validating automated database setup...
🔍 Getting Application Load Balancer URL from Ingress...
✅ Application Load Balancer URL found: http://k8s-healthcarestage3-2fd3bd59d0-849098463.us-east-1.elb.amazonaws.com
🔗 Using Application Load Balancer: http://k8s-healthcarestage3-2fd3bd59d0-849098463.us-east-1.elb.amazonaws.com
🔍 Checking pod status...
NAME                                         READY   STATUS    RESTARTS   AGE
healthcare-backend-stage3-74449f58b6-52kwm   1/1     Running   0          41s
healthcare-backend-stage3-74449f58b6-p47nv   1/1     Running   0          57s
healthcare-frontend-stage3-9c555f644-48pk4   1/1     Running   0          56s
healthcare-frontend-stage3-9c555f644-g6jt8   1/1     Running   0          45s
Name:             healthcare-backend-stage3-74449f58b6-52kwm
Namespace:        healthcare-stage3-dev
Priority:         0
Service Account:  default
Node:             ip-10-0-2-216.ec2.internal/10.0.2.216
Start Time:       Wed, 27 Aug 2025 19:20:05 +0000
Labels:           app=healthcare-backend-stage3
                  environment=dev
                  pod-template-hash=74449f58b6
                  stage=stage-3
                  tier=backend
Annotations:      kubectl.kubernetes.io/restartedAt: 2025-08-27T19:19:32Z
Status:           Running
IP:               10.0.2.124
IPs:
  IP:           10.0.2.124
Controlled By:  ReplicaSet/healthcare-backend-stage3-74449f58b6
Containers:
  backend:
    Container ID:   containerd://e626f0ca29cad9018ae7e9a01ff4d40a1bc3983f38f9efb7dd56200b20783da2
    Image:          867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:80823bd681e17f8eaa9426432b5eafd1de13b9f3
    Image ID:       867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3@sha256:9fa028e64433a5625edcdaca8d542c843e6f1d9794a2cb6f4b93f89a3ce20eae
    Port:           3001/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 27 Aug 2025 19:20:11 +0000
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
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-qbkhn (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-qbkhn:
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
  Normal  Scheduled  42s   default-scheduler  Successfully assigned healthcare-stage3-dev/healthcare-backend-stage3-74449f58b6-52kwm to ip-10-0-2-216.ec2.internal
  Normal  Pulling    42s   kubelet            Pulling image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:80823bd681e17f8eaa9426432b5eafd1de13b9f3"
  Normal  Pulled     36s   kubelet            Successfully pulled image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:80823bd681e17f8eaa9426432b5eafd1de13b9f3" in 5.702s (5.702s including waiting)
  Normal  Created    36s   kubelet            Created container backend
  Normal  Started    36s   kubelet            Started container backend
Name:             healthcare-backend-stage3-74449f58b6-p47nv
Namespace:        healthcare-stage3-dev
Priority:         0
Service Account:  default
Node:             ip-10-0-1-211.ec2.internal/10.0.1.211
Start Time:       Wed, 27 Aug 2025 19:19:49 +0000
Labels:           app=healthcare-backend-stage3
                  environment=dev
                  pod-template-hash=74449f58b6
                  stage=stage-3
                  tier=backend
Annotations:      kubectl.kubernetes.io/restartedAt: 2025-08-27T19:19:32Z
Status:           Running
IP:               10.0.1.161
IPs:
  IP:           10.0.1.161
Controlled By:  ReplicaSet/healthcare-backend-stage3-74449f58b6
Containers:
  backend:
    Container ID:   containerd://d714a47f1507c2aa809358414d224558f9806210c62c1791d2be39c15cb415a8
    Image:          867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:80823bd681e17f8eaa9426432b5eafd1de13b9f3
    Image ID:       867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3@sha256:9fa028e64433a5625edcdaca8d542c843e6f1d9794a2cb6f4b93f89a3ce20eae
    Port:           3001/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 27 Aug 2025 19:19:56 +0000
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
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-vvsgb (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-vvsgb:
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
  Normal  Scheduled  58s   default-scheduler  Successfully assigned healthcare-stage3-dev/healthcare-backend-stage3-74449f58b6-p47nv to ip-10-0-1-211.ec2.internal
  Normal  Pulling    58s   kubelet            Pulling image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:80823bd681e17f8eaa9426432b5eafd1de13b9f3"
  Normal  Pulled     52s   kubelet            Successfully pulled image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:80823bd681e17f8eaa9426432b5eafd1de13b9f3" in 6.171s (6.171s including waiting)
  Normal  Created    52s   kubelet            Created container backend
  Normal  Started    52s   kubelet            Started container backend
Name:             healthcare-frontend-stage3-9c555f644-48pk4
Namespace:        healthcare-stage3-dev
Priority:         0
Service Account:  default
Node:             ip-10-0-2-216.ec2.internal/10.0.2.216
Start Time:       Wed, 27 Aug 2025 19:19:50 +0000
Labels:           app=healthcare-frontend-stage3
                  environment=dev
                  pod-template-hash=9c555f644
                  stage=stage-3
                  tier=frontend
Annotations:      <none>
Status:           Running
IP:               10.0.2.60
IPs:
  IP:           10.0.2.60
Controlled By:  ReplicaSet/healthcare-frontend-stage3-9c555f644
Containers:
  frontend:
    Container ID:   containerd://862afcc9995a113cc1ea638efc8d2bd53a070b9b406487a991735fb12158c91a
    Image:          867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:80823bd681e17f8eaa9426432b5eafd1de13b9f3
    Image ID:       867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3@sha256:a97fd7edd2b916cb7d4d96855f8755333cbc41eaa1b0ea7796891c22981d4abe
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 27 Aug 2025 19:19:52 +0000
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
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-bpvs7 (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-bpvs7:
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
  Normal  Scheduled  57s   default-scheduler  Successfully assigned healthcare-stage3-dev/healthcare-frontend-stage3-9c555f644-48pk4 to ip-10-0-2-216.ec2.internal
  Normal  Pulling    57s   kubelet            Pulling image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:80823bd681e17f8eaa9426432b5eafd1de13b9f3"
  Normal  Pulled     56s   kubelet            Successfully pulled image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:80823bd681e17f8eaa9426432b5eafd1de13b9f3" in 816ms (816ms including waiting)
  Normal  Created    56s   kubelet            Created container frontend
  Normal  Started    56s   kubelet            Started container frontend
Name:             healthcare-frontend-stage3-9c555f644-g6jt8
Namespace:        healthcare-stage3-dev
Priority:         0
Service Account:  default
Node:             ip-10-0-1-211.ec2.internal/10.0.1.211
Start Time:       Wed, 27 Aug 2025 19:20:01 +0000
Labels:           app=healthcare-frontend-stage3
                  environment=dev
                  pod-template-hash=9c555f644
                  stage=stage-3
                  tier=frontend
Annotations:      <none>
Status:           Running
IP:               10.0.1.171
IPs:
  IP:           10.0.1.171
Controlled By:  ReplicaSet/healthcare-frontend-stage3-9c555f644
Containers:
  frontend:
    Container ID:   containerd://f6c60754f52ff90d67c4dad7a46ed17f53825b867d35ee594d743cf6493095c4
    Image:          867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:80823bd681e17f8eaa9426432b5eafd1de13b9f3
    Image ID:       867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3@sha256:a97fd7edd2b916cb7d4d96855f8755333cbc41eaa1b0ea7796891c22981d4abe
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 27 Aug 2025 19:20:03 +0000
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
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-vkn97 (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-vkn97:
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
  Normal  Scheduled  46s   default-scheduler  Successfully assigned healthcare-stage3-dev/healthcare-frontend-stage3-9c555f644-g6jt8 to ip-10-0-1-211.ec2.internal
  Normal  Pulling    46s   kubelet            Pulling image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:80823bd681e17f8eaa9426432b5eafd1de13b9f3"
  Normal  Pulled     45s   kubelet            Successfully pulled image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:80823bd681e17f8eaa9426432b5eafd1de13b9f3" in 628ms (629ms including waiting)
  Normal  Created    45s   kubelet            Created container frontend
  Normal  Started    45s   kubelet            Started container frontend
📋 Checking backend logs...
Found 2 pods, using pod/healthcare-backend-stage3-74449f58b6-p47nv
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
::ffff:10.0.1.211 - - [27/Aug/2025:19:20:05 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.103.112 - - [27/Aug/2025:19:20:06 +0000] "GET / HTTP/1.1" 404 186 "-" "ELB-HealthChecker/2.0"
::ffff:10.0.102.73 - - [27/Aug/2025:19:20:07 +0000] "GET / HTTP/1.1" 404 186 "-" "ELB-HealthChecker/2.0"
::ffff:10.0.1.211 - - [27/Aug/2025:19:20:10 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.101.173 - - [27/Aug/2025:19:20:10 +0000] "GET / HTTP/1.1" 404 186 "-" "ELB-HealthChecker/2.0"
::ffff:10.0.1.211 - - [27/Aug/2025:19:20:15 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.1.211 - - [27/Aug/2025:19:20:20 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.103.112 - - [27/Aug/2025:19:20:21 +0000] "GET / HTTP/1.1" 404 186 "-" "ELB-HealthChecker/2.0"
::ffff:10.0.102.73 - - [27/Aug/2025:19:20:22 +0000] "GET / HTTP/1.1" 404 186 "-" "ELB-HealthChecker/2.0"
::ffff:10.0.1.211 - - [27/Aug/2025:19:20:25 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.101.173 - - [27/Aug/2025:19:20:25 +0000] "GET / HTTP/1.1" 404 186 "-" "ELB-HealthChecker/2.0"
::ffff:10.0.1.211 - - [27/Aug/2025:19:20:30 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.1.211 - - [27/Aug/2025:19:20:30 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.1.211 - - [27/Aug/2025:19:20:35 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.103.112 - - [27/Aug/2025:19:20:36 +0000] "GET / HTTP/1.1" 404 186 "-" "ELB-HealthChecker/2.0"
::ffff:10.0.102.73 - - [27/Aug/2025:19:20:37 +0000] "GET / HTTP/1.1" 404 186 "-" "ELB-HealthChecker/2.0"
::ffff:10.0.1.211 - - [27/Aug/2025:19:20:40 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.1.211 - - [27/Aug/2025:19:20:40 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.101.173 - - [27/Aug/2025:19:20:40 +0000] "GET / HTTP/1.1" 404 186 "-" "ELB-HealthChecker/2.0"
::ffff:10.0.1.211 - - [27/Aug/2025:19:20:45 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
⏳ Waiting briefly before ALB checks...
🌐 Testing basic connectivity...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
HTTP/1.1 200 OK
Date: Wed, 27 Aug 2025 19:21:19 GMT
Content-Type: text/html
Content-Length: 464
Connection: keep-alive
Server: nginx/1.29.1
Last-Modified: Wed, 27 Aug 2025 19:10:39 GMT
ETag: "68af582f-1d0"
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Referrer-Policy: no-referrer-when-downgrade
Accept-Ranges: bytes
  0   464    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
✅ LoadBalancer is accessible
🗄️ Testing health endpoint...
Health response: {"status":"healthy","service":"healthcare-backend","timestamp":"2025-08-27T19:21:19.229Z","uptime":66.355348816,"environment":"development","version":"1.0.0","database":"connected","memory":{"rss":75124736,"heapTotal":13934592,"heapUsed":12773752,"external":1074355,"arrayBuffers":41162}}
✅ Database connection successful
👨‍⚕️ Testing doctors endpoint...
Doctors response: {"success":true,"data":{"doctors":[],"pagination":{"page":1,"limit":10,"total":0,"totalPages":0}},"message":"Found 0 doctors"}
❌ Sample data not available - investigating...
HTTP Status: 200
Error: Process completed with exit code 1.
0s
Run echo "🧹 Cleaning up temporary files..."
  
0s
Post job cleanup.
0s
Post job cleanup.
/usr/bin/git version
git version 2.51.0
Temporarily overriding HOME='/home/runner/work/_temp/6c7ede8f-50f4-468e-b67d-6e5e51117884' before making global git config changes
Adding repository directory to the temporary git global config as a safe directory
/usr/bin/git config --global --add safe.directory /home/runner/work/Health_Care_Management_System/Health_Care_Management_System
/usr/bin/git config --local --name-only --get-regexp core\.sshCommand
/usr/bin/git submodule foreach --recursive sh -c "git config --local --name-only --get-regexp 'core\.sshCommand' && git config --local --unset-all 'core.sshCommand' || :"
/usr/bin/git config --local --name-only --get-regexp http\.https\:\/\/github\.com\/\.extraheader
http.https://github.com/.extraheader
/usr/bin/git config --local --unset-all http.https://github.com/.extraheader
/usr/bin/git submodule foreach --recursive sh -c "git config --local --name-only --get-regexp 'http\.https\:\/\/github\.com\/\.extraheader' && git config --local --unset-all 'http.https://github.com/.extraheader' || :"
