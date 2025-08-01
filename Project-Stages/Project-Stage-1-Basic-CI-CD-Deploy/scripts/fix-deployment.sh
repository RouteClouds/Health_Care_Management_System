#!/bin/bash

# Quick fix for deployment issues
# This script will clean up failed deployments and redeploy with working images

echo "🔧 Fixing deployment issues..."

# Delete existing deployments
echo "Cleaning up existing deployments..."
kubectl delete deployment healthcare-backend -n healthcare --ignore-not-found=true
kubectl delete deployment healthcare-frontend -n healthcare --ignore-not-found=true

# Wait a moment
sleep 5

echo "Checking pod status..."
kubectl get pods -n healthcare

echo "Checking events..."
kubectl get events -n healthcare --sort-by='.lastTimestamp' | tail -10

echo ""
echo "🔍 Troubleshooting Commands:"
echo "1. Check pod status: kubectl get pods -n healthcare"
echo "2. Describe pods: kubectl describe pods -n healthcare"
echo "3. Check logs: kubectl logs -n healthcare -l app=healthcare-backend"
echo "4. Check events: kubectl get events -n healthcare --sort-by='.lastTimestamp'"
echo ""
echo "🎯 To fix the image issue:"
echo "1. Build your own images:"
echo "   cd /home/ubuntu/Projects/Health_Care_Management_System/src-code"
echo "   docker build -f Dockerfile.backend -t YOUR-USERNAME/healthcare-backend:v1.0 ."
echo "   docker push YOUR-USERNAME/healthcare-backend:v1.0"
echo ""
echo "2. Update k8s/backend-deployment.yaml with your image name"
echo "3. Redeploy: kubectl apply -f k8s/backend-deployment.yaml"
