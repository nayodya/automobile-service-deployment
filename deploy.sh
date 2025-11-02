#!/bin/bash
# Kubernetes Deployment Script for AutoService Application
# This script deploys all components in the correct order

set -e  # Exit on error

echo "========================================"
echo "AutoService Kubernetes Deployment"
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed. Please install kubectl first."
    exit 1
fi

print_success "kubectl is installed"

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    print_error "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
    exit 1
fi

print_success "Connected to Kubernetes cluster"
echo ""

# Step 1: Create namespace
echo "Step 1: Creating namespace..."
kubectl apply -f common/namespace.yaml
print_success "Namespace created"
echo ""

# Step 2: Deploy database components
echo "Step 2: Deploying database..."
kubectl apply -f database/configmap.yaml
kubectl apply -f database/secret.yaml
kubectl apply -f database/pvc.yaml
kubectl apply -f database/statefulset.yaml
kubectl apply -f database/service.yaml
print_success "Database components deployed"
echo ""

# Wait for database to be ready
echo "Waiting for database to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n autoservice --timeout=300s
print_success "Database is ready"
echo ""

# Step 3: Deploy backend components
echo "Step 3: Deploying backend..."
kubectl apply -f backend/configmap.yaml
kubectl apply -f backend/secret.yaml
kubectl apply -f backend/deployment.yaml
kubectl apply -f backend/service.yaml
kubectl apply -f backend/hpa.yaml
print_success "Backend components deployed"
echo ""

# Wait for backend to be ready
echo "Waiting for backend to be ready..."
kubectl wait --for=condition=ready pod -l app=backend -n autoservice --timeout=300s
print_success "Backend is ready"
echo ""

# Step 4: Deploy frontend components
echo "Step 4: Deploying frontend..."
kubectl apply -f frontend/configmap.yaml
kubectl apply -f frontend/deployment.yaml
kubectl apply -f frontend/service.yaml
kubectl apply -f frontend/hpa.yaml
print_success "Frontend components deployed"
echo ""

# Wait for frontend to be ready
echo "Waiting for frontend to be ready..."
kubectl wait --for=condition=ready pod -l app=frontend -n autoservice --timeout=300s
print_success "Frontend is ready"
echo ""

# Step 5: Apply network policies
echo "Step 5: Applying network policies..."
kubectl apply -f common/network-policy.yaml
print_success "Network policies applied"
echo ""

# Step 6: Apply ingress (optional)
echo "Step 6: Applying ingress..."
if kubectl apply -f common/ingress.yaml 2>/dev/null; then
    print_success "Ingress applied"
else
    print_info "Ingress not applied (ingress controller might not be installed)"
fi
echo ""

# Display deployment status
echo "========================================"
echo "Deployment Status"
echo "========================================"
echo ""

echo "Pods:"
kubectl get pods -n autoservice
echo ""

echo "Services:"
kubectl get services -n autoservice
echo ""

echo "Deployments:"
kubectl get deployments -n autoservice
echo ""

echo "StatefulSets:"
kubectl get statefulsets -n autoservice
echo ""

echo "HPAs:"
kubectl get hpa -n autoservice
echo ""

# Get the external IP/URL
echo "========================================"
echo "Access Information"
echo "========================================"
echo ""

FRONTEND_SERVICE=$(kubectl get service frontend-service -n autoservice -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")

if [ "$FRONTEND_SERVICE" != "pending" ]; then
    print_success "Application is accessible at: http://$FRONTEND_SERVICE"
else
    print_info "Waiting for LoadBalancer IP assignment..."
    print_info "Run 'kubectl get service frontend-service -n autoservice' to check status"
fi

echo ""
print_success "Deployment completed successfully!"
echo ""
echo "Useful commands:"
echo "  - View logs: kubectl logs -f <pod-name> -n autoservice"
echo "  - View pods: kubectl get pods -n autoservice"
echo "  - View services: kubectl get services -n autoservice"
echo "  - Delete deployment: ./cleanup.sh"
echo ""