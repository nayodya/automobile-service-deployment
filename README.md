# Automobile Service - Kubernetes Deployment Guide

Kubernetes deployment guide for the Automobile Service application using external Azure PostgreSQL database.

## 📦 What's Included

- **Backend**: Spring Boot API (Port 8080)
- **Frontend**: React + Nginx (Port 80)
- **Database**: External Azure PostgreSQL (auto-service-db-server.postgres.database.azure.com)

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
2. ✅ Skip internal database (using external Azure PostgreSQL)
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
│   ├── configmap.yaml   # Configuration (Azure PostgreSQL settings)
│   ├── secret.yaml      # Secrets (DB password, JWT, Email)
│   ├── deployment.yaml  # Deployment spec
│   ├── service.yaml     # Service endpoint
│   └── hpa.yaml         # Auto-scaling
├── frontend/            # Frontend K8s manifests
│   ├── configmap.yaml   # Configuration
│   ├── deployment.yaml  # Deployment spec
│   ├── service.yaml     # LoadBalancer service
│   └── hpa.yaml         # Auto-scaling
├── common/              # Common resources
│   ├── namespace.yaml   # Namespace definition
│   ├── ingress.yaml     # Ingress rules
│   └── network-policy.yaml # Network policies
├── deploy.sh            # Automated deployment script
├── cleanup.sh           # Cleanup script
└── docker-compose.yml   # Docker Compose for local development

Note: Database folder removed - using external Azure PostgreSQL
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
```yaml
# Update in backend/secret.yaml:
stringData:
  SPRING_DATASOURCE_PASSWORD: "test@1234"  # Azure PostgreSQL password
  JWT_SECRET: "your-jwt-secret-key"
  SPRING_MAIL_USERNAME: "your-email@gmail.com"
  SPRING_MAIL_PASSWORD: "your-app-password"
```

**Backend ConfigMap** (`backend/configmap.yaml`):
```yaml
# Azure PostgreSQL connection details are already configured:
SPRING_DATASOURCE_URL: "jdbc:postgresql://auto-service-db-server.postgres.database.azure.com:5432/auto-service"
SPRING_DATASOURCE_USERNAME: "test"
```

**Azure PostgreSQL Setup:**
- Ensure Azure PostgreSQL firewall allows connections from your Kubernetes cluster
- Database: `auto-service`
- Host: `auto-service-db-server.postgres.database.azure.com`
- Port: `5432`

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

**Using External Azure PostgreSQL:**

```bash
# Check backend logs for database connection errors
kubectl logs -f deployment/backend-deployment -n autoservice

# Verify Azure PostgreSQL firewall rules allow your K8s cluster
# Check in Azure Portal: PostgreSQL Server > Connection security

# Test connection from a pod
kubectl run -it --rm debug --image=postgres:15-alpine -n autoservice -- \
  psql -h auto-service-db-server.postgres.database.azure.com \
       -U test -d auto-service

# Common issues:
# 1. Firewall rules not allowing K8s cluster IPs
# 2. SSL connection required (may need sslmode=require in URL)
# 3. Incorrect credentials in backend/secret.yaml
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
| Database  | External   | Azure PostgreSQL | N/A    | Azure-managed |

Auto-scaling triggers at 70% CPU utilization.

## 🔐 Database Credentials

**Azure PostgreSQL:**
- Host: `auto-service-db-server.postgres.database.azure.com`
- Port: `5432`
- Database: `auto-service`
- User: `test`
- Password: `test@1234` (configured in `backend/secret.yaml`)

**Important:** 
- Change default passwords in production!
- Ensure Azure PostgreSQL firewall rules are properly configured
- Consider using Azure Key Vault for production secrets

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
