#!/bin/bash
# Kubernetes Cleanup Script for AutoService Application
# This script removes all deployed components

set -e  # Exit on error

echo "========================================"
echo "AutoService Kubernetes Cleanup"
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Confirmation prompt
print_warning "This will delete all AutoService resources from the cluster!"
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""

# Delete ingress
echo "Deleting ingress..."
kubectl delete -f common/ingress.yaml --ignore-not-found=true
print_success "Ingress deleted"

# Delete network policies
echo "Deleting network policies..."
kubectl delete -f common/network-policy.yaml --ignore-not-found=true
print_success "Network policies deleted"

# Delete frontend
echo "Deleting frontend components..."
kubectl delete -f frontend/hpa.yaml --ignore-not-found=true
kubectl delete -f frontend/service.yaml --ignore-not-found=true
kubectl delete -f frontend/deployment.yaml --ignore-not-found=true
kubectl delete -f frontend/configmap.yaml --ignore-not-found=true
print_success "Frontend components deleted"

# Delete backend
echo "Deleting backend components..."
kubectl delete -f backend/hpa.yaml --ignore-not-found=true
kubectl delete -f backend/service.yaml --ignore-not-found=true
kubectl delete -f backend/deployment.yaml --ignore-not-found=true
kubectl delete -f backend/secret.yaml --ignore-not-found=true
kubectl delete -f backend/configmap.yaml --ignore-not-found=true
print_success "Backend components deleted"

# Delete database
# NOTE: Database cleanup skipped - using external Azure PostgreSQL database
echo "Skipping database cleanup (using external Azure PostgreSQL)..."
print_success "Database cleanup skipped (external database)"

# Ask about namespace deletion
echo ""
read -p "Do you want to delete the namespace? (yes/no): " delete_ns

if [ "$delete_ns" == "yes" ]; then
    kubectl delete namespace autoservice --ignore-not-found=true
    print_success "Namespace deleted"
else
    print_warning "Namespace retained"
fi

echo ""
print_success "Cleanup completed!"
echo ""