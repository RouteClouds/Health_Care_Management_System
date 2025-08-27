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
    TERRAFORM_CLI_PATH: /home/runner/work/_temp/d0276474-ef92-44c9-a400-04d6fa4c0f85
🔍 Validating automated database setup...
🔍 Getting Application Load Balancer URL from Ingress...
✅ Application Load Balancer URL found: http://k8s-healthcarestage3-2fd3bd59d0-849098463.us-east-1.elb.amazonaws.com
🔗 Using Application Load Balancer: http://k8s-healthcarestage3-2fd3bd59d0-849098463.us-east-1.elb.amazonaws.com
🔍 Checking pod status...
NAME                                         READY   STATUS    RESTARTS   AGE
healthcare-backend-stage3-77c7bf899d-95vfn   1/1     Running   0          40s
healthcare-backend-stage3-77c7bf899d-hd9l9   1/1     Running   0          40s
healthcare-frontend-stage3-8c88c848-26x9q    1/1     Running   0          39s
healthcare-frontend-stage3-8c88c848-vjp9p    1/1     Running   0          39s
Name:             healthcare-backend-stage3-77c7bf899d-95vfn
Namespace:        healthcare-stage3-dev
Priority:         0
Service Account:  default
Node:             ip-10-0-2-216.ec2.internal/10.0.2.216
Start Time:       Wed, 27 Aug 2025 16:28:36 +0000
Labels:           app=healthcare-backend-stage3
                  environment=dev
                  pod-template-hash=77c7bf899d
                  stage=stage-3
                  tier=backend
Annotations:      <none>
Status:           Running
IP:               10.0.2.58
IPs:
  IP:           10.0.2.58
Controlled By:  ReplicaSet/healthcare-backend-stage3-77c7bf899d
Containers:
  backend:
    Container ID:   containerd://52c14a05269b2ef8bffbde5a9e86e605f0452108b91b43332fbfad045d810215
    Image:          867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:a283b7099480378244d53cae3dd8f0a0d3541734
    Image ID:       867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3@sha256:7631fc270812418db612539a8ed980583297860c1dce337da7355f05b5869967
    Port:           3001/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 27 Aug 2025 16:28:46 +0000
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
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-c4rmb (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-c4rmb:
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
  Normal  Scheduled  40s   default-scheduler  Successfully assigned healthcare-stage3-dev/healthcare-backend-stage3-77c7bf899d-95vfn to ip-10-0-2-216.ec2.internal
  Normal  Pulling    40s   kubelet            Pulling image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:a283b7099480378244d53cae3dd8f0a0d3541734"
  Normal  Pulled     32s   kubelet            Successfully pulled image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:a283b7099480378244d53cae3dd8f0a0d3541734" in 8.657s (8.657s including waiting)
  Normal  Created    32s   kubelet            Created container backend
  Normal  Started    31s   kubelet            Started container backend
Name:             healthcare-backend-stage3-77c7bf899d-hd9l9
Namespace:        healthcare-stage3-dev
Priority:         0
Service Account:  default
Node:             ip-10-0-1-211.ec2.internal/10.0.1.211
Start Time:       Wed, 27 Aug 2025 16:28:36 +0000
Labels:           app=healthcare-backend-stage3
                  environment=dev
                  pod-template-hash=77c7bf899d
                  stage=stage-3
                  tier=backend
Annotations:      <none>
Status:           Running
IP:               10.0.1.171
IPs:
  IP:           10.0.1.171
Controlled By:  ReplicaSet/healthcare-backend-stage3-77c7bf899d
Containers:
  backend:
    Container ID:   containerd://f7c62b5155f7ddf2e5972bd2144257e6607623d2fd17dcadac8232e66e64630e
    Image:          867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:a283b7099480378244d53cae3dd8f0a0d3541734
    Image ID:       867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3@sha256:7631fc270812418db612539a8ed980583297860c1dce337da7355f05b5869967
    Port:           3001/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 27 Aug 2025 16:28:46 +0000
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
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-vv5zr (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-vv5zr:
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
  Normal  Scheduled  40s   default-scheduler  Successfully assigned healthcare-stage3-dev/healthcare-backend-stage3-77c7bf899d-hd9l9 to ip-10-0-1-211.ec2.internal
  Normal  Pulling    40s   kubelet            Pulling image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:a283b7099480378244d53cae3dd8f0a0d3541734"
  Normal  Pulled     31s   kubelet            Successfully pulled image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:a283b7099480378244d53cae3dd8f0a0d3541734" in 8.819s (8.819s including waiting)
  Normal  Created    31s   kubelet            Created container backend
  Normal  Started    31s   kubelet            Started container backend
Name:             healthcare-frontend-stage3-8c88c848-26x9q
Namespace:        healthcare-stage3-dev
Priority:         0
Service Account:  default
Node:             ip-10-0-2-216.ec2.internal/10.0.2.216
Start Time:       Wed, 27 Aug 2025 16:28:37 +0000
Labels:           app=healthcare-frontend-stage3
                  environment=dev
                  pod-template-hash=8c88c848
                  stage=stage-3
                  tier=frontend
Annotations:      <none>
Status:           Running
IP:               10.0.2.60
IPs:
  IP:           10.0.2.60
Controlled By:  ReplicaSet/healthcare-frontend-stage3-8c88c848
Containers:
  frontend:
    Container ID:   containerd://0873380fd0ead3f162c2ebf432bb7d64033e4f5392c1209fcdbecf8bd051feaa
    Image:          867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:a283b7099480378244d53cae3dd8f0a0d3541734
    Image ID:       867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3@sha256:f6f5a6f93ae75ac4b55c80098a02af33f526c3af468b0950d4cc8aec75406d47
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 27 Aug 2025 16:28:41 +0000
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
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-phhr7 (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-phhr7:
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
  Normal  Scheduled  39s   default-scheduler  Successfully assigned healthcare-stage3-dev/healthcare-frontend-stage3-8c88c848-26x9q to ip-10-0-2-216.ec2.internal
  Normal  Pulling    39s   kubelet            Pulling image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:a283b7099480378244d53cae3dd8f0a0d3541734"
  Normal  Pulled     37s   kubelet            Successfully pulled image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:a283b7099480378244d53cae3dd8f0a0d3541734" in 2.594s (2.594s including waiting)
  Normal  Created    37s   kubelet            Created container frontend
  Normal  Started    36s   kubelet            Started container frontend
Name:             healthcare-frontend-stage3-8c88c848-vjp9p
Namespace:        healthcare-stage3-dev
Priority:         0
Service Account:  default
Node:             ip-10-0-1-211.ec2.internal/10.0.1.211
Start Time:       Wed, 27 Aug 2025 16:28:37 +0000
Labels:           app=healthcare-frontend-stage3
                  environment=dev
                  pod-template-hash=8c88c848
                  stage=stage-3
                  tier=frontend
Annotations:      <none>
Status:           Running
IP:               10.0.1.64
IPs:
  IP:           10.0.1.64
Controlled By:  ReplicaSet/healthcare-frontend-stage3-8c88c848
Containers:
  frontend:
    Container ID:   containerd://e6fd21a684ec59897d2ef692464d2d457b32878cb1be41474ef6ea105c634776
    Image:          867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:a283b7099480378244d53cae3dd8f0a0d3541734
    Image ID:       867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3@sha256:f6f5a6f93ae75ac4b55c80098a02af33f526c3af468b0950d4cc8aec75406d47
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 27 Aug 2025 16:28:40 +0000
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
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-7k4ls (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-7k4ls:
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
  Normal  Scheduled  39s   default-scheduler  Successfully assigned healthcare-stage3-dev/healthcare-frontend-stage3-8c88c848-vjp9p to ip-10-0-1-211.ec2.internal
  Normal  Pulling    39s   kubelet            Pulling image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:a283b7099480378244d53cae3dd8f0a0d3541734"
  Normal  Pulled     37s   kubelet            Successfully pulled image "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:a283b7099480378244d53cae3dd8f0a0d3541734" in 2.54s (2.54s including waiting)
  Normal  Created    37s   kubelet            Created container frontend
  Normal  Started    37s   kubelet            Started container frontend
📋 Checking backend logs...
Found 2 pods, using pod/healthcare-backend-stage3-77c7bf899d-95vfn
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
::ffff:10.0.2.216 - - [27/Aug/2025:16:28:52 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.216 - - [27/Aug/2025:16:28:57 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.216 - - [27/Aug/2025:16:29:02 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.216 - - [27/Aug/2025:16:29:07 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.216 - - [27/Aug/2025:16:29:12 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.216 - - [27/Aug/2025:16:29:17 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
::ffff:10.0.2.216 - - [27/Aug/2025:16:29:17 +0000] "GET /health HTTP/1.1" 200 158 "-" "kube-probe/1.28+"
⏳ Waiting briefly before ALB checks...
