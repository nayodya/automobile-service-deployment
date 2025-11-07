# Automobile Service - Minikube Deployment Guide

Quick deployment guide for running the Automobile Service application on Minikube.

## 📦 What's Included

- **Backend**: Spring Boot API (Port 8080)
- **Frontend**: React + Nginx (Port 80)
- **Database**: PostgreSQL with persistent storage

## 🚀 Quick Start

### Prerequisites

```bash
# Install Minikube
# Windows: choco install minikube
# Mac: brew install minikube
# Linux: https://minikube.sigs.k8s.io/docs/start/

# Install kubectl
# Minikube includes kubectl, or install separately
```

### Step 1: Start Minikube

```bash
# Start Minikube cluster
minikube start

# Verify cluster is running
kubectl cluster-info
```

### Step 2: Load Docker Images

```bash
# Load backend image
minikube image load nayodya/automobile-backend:v1

# Load frontend image
minikube image load nayodya/automobile-frontend:v1

# Verify images are loaded
minikube image ls | grep automobile
```

### Step 3: Deploy Application

```bash
# Make deploy script executable
chmod +x deploy.sh

# Run deployment
./deploy.sh
```

The script will:
1. ✅ Create namespace
2. ✅ Deploy PostgreSQL database
3. ✅ Deploy backend (Spring Boot)
4. ✅ Deploy frontend (React)
5. ✅ Configure auto-scaling
6. ✅ Apply network policies

### Step 4: Access Application

```bash
# Get frontend service URL
minikube service frontend-service -n autoservice

# Or use port forwarding
kubectl port-forward service/frontend-service 8080:80 -n autoservice
# Then open: http://localhost:8080
```

## 📁 Project Structure

```
automobile-service-deployment/
├── backend/              # Backend K8s manifests
│   ├── configmap.yaml   # Configuration
│   ├── secret.yaml      # Secrets (DB, JWT, Email)
│   ├── deployment.yaml  # Deployment spec
│   ├── service.yaml     # Service endpoint
│   └── hpa.yaml         # Auto-scaling
├── frontend/            # Frontend K8s manifests
│   ├── configmap.yaml   # Configuration
│   ├── deployment.yaml  # Deployment spec
│   ├── service.yaml     # LoadBalancer service
│   └── hpa.yaml         # Auto-scaling
├── database/            # Database K8s manifests
│   ├── configmap.yaml   # PostgreSQL config
│   ├── secret.yaml      # Database password
│   ├── pvc.yaml         # Persistent volume
│   ├── statefulset.yaml # StatefulSet
│   └── service.yaml     # Service endpoint
├── common/              # Common resources
│   ├── namespace.yaml   # Namespace definition
│   ├── ingress.yaml     # Ingress rules
│   └── network-policy.yaml # Network policies
├── deploy.sh           # Automated deployment
└── cleanup.sh          # Cleanup script
```

## 🛠️ Management Commands

### View Resources

```bash
# All resources
kubectl get all -n autoservice

# Pods
kubectl get pods -n autoservice

# Services
kubectl get services -n autoservice
```

### View Logs

```bash
# Frontend logs
kubectl logs -f deployment/frontend-deployment -n autoservice

# Backend logs
kubectl logs -f deployment/backend-deployment -n autoservice

# Database logs
kubectl logs -f statefulset/postgres-statefulset -n autoservice
```

### Scale Deployments

```bash
# Scale backend
kubectl scale deployment backend-deployment --replicas=3 -n autoservice

# Scale frontend
kubectl scale deployment frontend-deployment --replicas=3 -n autoservice
```

## 🔧 Configuration

### Update Secrets (Before First Deploy)

**Backend Secret** (`backend/secret.yaml`):
```bash
# Encode your values
echo -n 'your-password' | base64

# Update in backend/secret.yaml:
# - DB_PASSWORD
# - JWT_SECRET
# - EMAIL_PASSWORD
```

**Database Secret** (`database/secret.yaml`):
```bash
# Update POSTGRES_PASSWORD with base64 encoded value
```

### Docker Images

The deployment uses:
- `nayodya/automobile-backend:v1`
- `nayodya/automobile-frontend:v1`

To use different images, update in:
- `backend/deployment.yaml` (line 29)
- `frontend/deployment.yaml` (line 29)

## 🐛 Troubleshooting

### Pods Not Starting

```bash
# Describe pod
kubectl describe pod <pod-name> -n autoservice

# Check logs
kubectl logs <pod-name> -n autoservice

# Check events
kubectl get events -n autoservice --sort-by='.lastTimestamp'
```

### Service Not Accessible

```bash
# Check service
kubectl get service frontend-service -n autoservice

# Check endpoints
kubectl get endpoints -n autoservice

# Port forward directly to pod
kubectl port-forward <pod-name> 8080:80 -n autoservice
```

### Database Connection Issues

```bash
# Check database pod
kubectl get pods -n autoservice -l app=postgres

# Connect to database
kubectl exec -it postgres-statefulset-0 -n autoservice -- psql -U postgres

# Check database logs
kubectl logs postgres-statefulset-0 -n autoservice
```

### Image Pull Issues

```bash
# Verify images are loaded in Minikube
minikube image ls | grep automobile

# Re-load images if needed
minikube image load nayodya/automobile-backend:v1
minikube image load nayodya/automobile-frontend:v1
```

## 🧹 Cleanup

```bash
# Run cleanup script
./cleanup.sh

# Or manually delete
kubectl delete namespace autoservice

# Stop Minikube
minikube stop

# Delete Minikube cluster
minikube delete
```

## 📊 Resource Allocation

| Component | CPU Request | Memory Request | Replicas | Auto-scale |
|-----------|------------|----------------|----------|------------|
| Frontend  | 100m       | 128Mi          | 2        | 2-10       |
| Backend   | 250m       | 512Mi          | 2        | 2-10       |
| Database  | 250m       | 256Mi          | 1        | N/A        |

Auto-scaling triggers at 70% CPU utilization.

## 🔐 Default Credentials

**Database:**
- User: `postgres`
- Password: Check `database/secret.yaml` (base64 encoded)
- Database: `automobile_service`

**Important:** Change default passwords in production!

## 📝 Quick Reference

```bash
# Start everything
minikube start
minikube image load nayodya/automobile-backend:v1
minikube image load nayodya/automobile-frontend:v1
./deploy.sh

# Access frontend
minikube service frontend-service -n autoservice

# View status
kubectl get all -n autoservice

# View logs
kubectl logs -f deployment/backend-deployment -n autoservice

# Cleanup
./cleanup.sh
minikube stop
```

## 🎯 Useful Minikube Commands

```bash
# Dashboard
minikube dashboard

# SSH into Minikube VM
minikube ssh

# Check Minikube status
minikube status

# View Minikube IP
minikube ip

# List services
minikube service list

# Enable addons
minikube addons enable ingress
minikube addons enable metrics-server
```

## 📚 Related Resources

- **Frontend Repo**: https://github.com/Chamithjay/auto_service_frontend
- **Backend Repo**: https://github.com/Chamithjay/auto_service_backend
- **Minikube Docs**: https://minikube.sigs.k8s.io/docs/
- **Kubernetes Docs**: https://kubernetes.io/docs/

---
