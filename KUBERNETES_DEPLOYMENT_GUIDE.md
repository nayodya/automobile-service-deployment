# 🚀 Kubernetes Deployment Guide - Auto Service Project

This guide will help you deploy the Auto Service application to Kubernetes.

## 📋 Prerequisites

- ✅ Kubernetes cluster (Docker Desktop, Minikube, or cloud provider)
- ✅ kubectl CLI installed
- ✅ Docker installed
- ✅ Docker registry access (Docker Hub, etc.)

## 🔧 Step 1: Build Docker Images

### Build Backend Image
```bash
cd /e/EAD/auto_service_backend
docker build -t auto-service-backend:latest .

# Tag for your registry (replace 'yourusername' with your Docker Hub username)
docker tag auto-service-backend:latest yourusername/auto-service-backend:latest

# Push to registry
docker push yourusername/auto-service-backend:latest
```

### Build Frontend Image
```bash
cd /e/EAD/auto_service_frontend
docker build -t auto-service-frontend:latest .

# Tag for your registry
docker tag auto-service-frontend:latest yourusername/auto-service-frontend:latest

# Push to registry
docker push yourusername/auto-service-frontend:latest
```

**For local Kubernetes (Docker Desktop/Minikube):**
You can skip pushing to registry and use local images directly.

## ⚙️ Step 2: Update Kubernetes Configurations

### Update Image References

Edit the following files to use your Docker images:

**Backend Deployment** (`kubernetes/backend/deployment.yaml`):
```yaml
spec:
  template:
    spec:
      containers:
      - name: backend
        image: yourusername/auto-service-backend:latest  # Update this line
        # OR for local: auto-service-backend:latest
        imagePullPolicy: IfNotPresent  # Use IfNotPresent for local images
```

**Frontend Deployment** (`kubernetes/frontend/deployment.yaml`):
```yaml
spec:
  template:
    spec:
      containers:
      - name: frontend
        image: yourusername/auto-service-frontend:latest  # Update this line
        # OR for local: auto-service-frontend:latest
        imagePullPolicy: IfNotPresent  # Use IfNotPresent for local images
```

### Update Secrets (IMPORTANT!)

**Database Secret** (`kubernetes/database/secret.yaml`):
```bash
# Generate base64 encoded values
echo -n "postgres" | base64          # POSTGRES_USER
echo -n "your-password" | base64     # POSTGRES_PASSWORD
echo -n "autoservice" | base64       # POSTGRES_DB
```

Update `kubernetes/database/secret.yaml` with your values.

**Backend Secret** (`kubernetes/backend/secret.yaml`):
```bash
# Generate JWT secret (32+ characters)
echo -n "your-jwt-secret-key-min-32-chars" | base64

# Generate DB password
echo -n "your-password" | base64
```

## 🚢 Step 3: Deploy to Kubernetes

### Navigate to deployment directory
```bash
cd /e/EAD/automobile-service-deployment
```

### Deploy in Order:

#### 1. Create Namespace
```bash
kubectl apply -f kubernetes/namespace.yaml
```

#### 2. Deploy Database
```bash
kubectl apply -f kubernetes/database/secret.yaml
kubectl apply -f kubernetes/database/pvc.yaml
kubectl apply -f kubernetes/database/deployment.yaml
kubectl apply -f kubernetes/database/service.yaml

# Wait for database to be ready
kubectl wait --for=condition=ready pod -l app=postgres -n auto-service --timeout=300s
```

#### 3. Deploy Backend
```bash
kubectl apply -f kubernetes/backend/secret.yaml
kubectl apply -f kubernetes/backend/configmap.yaml
kubectl apply -f kubernetes/backend/deployment.yaml
kubectl apply -f kubernetes/backend/service.yaml

# Wait for backend to be ready
kubectl wait --for=condition=ready pod -l app=backend -n auto-service --timeout=300s
```

#### 4. Deploy Frontend
```bash
kubectl apply -f kubernetes/frontend/configmap.yaml
kubectl apply -f kubernetes/frontend/deployment.yaml
kubectl apply -f kubernetes/frontend/service.yaml
```

#### 5. Setup Ingress (Optional)

**For Minikube:**
```bash
# Enable ingress addon
minikube addons enable ingress

# Apply ingress
kubectl apply -f kubernetes/ingress.yaml
```

**For Docker Desktop:**
```bash
# Install nginx ingress controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

# Wait for it to be ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# Apply ingress
kubectl apply -f kubernetes/ingress.yaml
```

### OR Deploy Everything at Once:
```bash
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/database/
kubectl apply -f kubernetes/backend/
kubectl apply -f kubernetes/frontend/
kubectl apply -f kubernetes/ingress.yaml
```

## 🔍 Step 4: Verify Deployment

### Check all resources
```bash
kubectl get all -n auto-service
```

### Check pods status
```bash
kubectl get pods -n auto-service
```

### Check services
```bash
kubectl get svc -n auto-service
```

### Check ingress
```bash
kubectl get ingress -n auto-service
```

### View logs
```bash
# Backend logs
kubectl logs -f deployment/backend -n auto-service

# Frontend logs
kubectl logs -f deployment/frontend -n auto-service

# Database logs
kubectl logs -f deployment/postgres -n auto-service
```

## 🌐 Step 5: Access Application

### Using Ingress (Recommended)

Add to your hosts file:
- **Windows**: `C:\Windows\System32\drivers\etc\hosts`
- **Linux/Mac**: `/etc/hosts`

```
127.0.0.1 auto-service.local
```

Access application:
- Frontend: `http://auto-service.local`
- Backend API: `http://auto-service.local/api`

### Using Port-Forward (Alternative)

```bash
# Forward frontend
kubectl port-forward -n auto-service svc/frontend-service 3000:80

# Forward backend (in another terminal)
kubectl port-forward -n auto-service svc/backend-service 8081:8080

# Forward database (in another terminal)
kubectl port-forward -n auto-service svc/postgres-service 5432:5432
```

Access:
- Frontend: `http://localhost:3000`
- Backend: `http://localhost:8081/api`
- Database: `localhost:5432`

### Using Minikube Service

```bash
minikube service frontend-service -n auto-service
minikube service backend-service -n auto-service
```

## 🛠️ Troubleshooting

### Pods not starting
```bash
# Describe pod to see events
kubectl describe pod <pod-name> -n auto-service

# Check logs
kubectl logs <pod-name> -n auto-service
```

### Database connection issues
```bash
# Check if database is running
kubectl get pods -l app=postgres -n auto-service

# Test connectivity from backend pod
kubectl exec -it deployment/backend -n auto-service -- sh
nc -zv postgres-service 5432
```

### ImagePullBackOff error
```bash
# For local images, update imagePullPolicy to IfNotPresent or Never
# OR push images to a registry

# Check pod events
kubectl describe pod <pod-name> -n auto-service
```

### Ingress not working
```bash
# Check ingress controller
kubectl get pods -n ingress-nginx

# Check ingress details
kubectl describe ingress auto-service-ingress -n auto-service
```

## 📊 Monitoring

### Real-time pod status
```bash
kubectl get pods -n auto-service -w
```

### Resource usage
```bash
kubectl top nodes
kubectl top pods -n auto-service
```

### Events
```bash
kubectl get events -n auto-service --sort-by='.lastTimestamp'
```

## 🔄 Update Deployment

### Update backend
```bash
# Build new image
docker build -t auto-service-backend:v2 .
docker push yourusername/auto-service-backend:v2

# Update deployment
kubectl set image deployment/backend backend=yourusername/auto-service-backend:v2 -n auto-service

# OR edit and apply
kubectl apply -f kubernetes/backend/deployment.yaml
```

### Rollback
```bash
kubectl rollout undo deployment/backend -n auto-service
```

### Check rollout status
```bash
kubectl rollout status deployment/backend -n auto-service
```

## 📏 Scaling

### Manual scaling
```bash
kubectl scale deployment backend --replicas=3 -n auto-service
kubectl scale deployment frontend --replicas=3 -n auto-service
```

### Auto-scaling (HPA)
```bash
kubectl autoscale deployment backend --cpu-percent=70 --min=2 --max=10 -n auto-service
```

## 🧹 Cleanup

### Delete all resources
```bash
kubectl delete namespace auto-service
```

### Delete specific resources
```bash
kubectl delete -f kubernetes/ingress.yaml
kubectl delete -f kubernetes/frontend/
kubectl delete -f kubernetes/backend/
kubectl delete -f kubernetes/database/
kubectl delete -f kubernetes/namespace.yaml
```

## 📝 Quick Reference Commands

```bash
# Get everything
kubectl get all -n auto-service

# Restart deployment
kubectl rollout restart deployment/backend -n auto-service

# Get pod shell
kubectl exec -it <pod-name> -n auto-service -- sh

# Copy files to/from pod
kubectl cp <local-file> <pod-name>:/path -n auto-service
kubectl cp <pod-name>:/path <local-file> -n auto-service

# View pod logs (last 100 lines)
kubectl logs --tail=100 <pod-name> -n auto-service

# Follow logs
kubectl logs -f <pod-name> -n auto-service

# Delete pod (will be recreated)
kubectl delete pod <pod-name> -n auto-service
```

## 🎯 Production Checklist

- [ ] Use proper secrets management (Sealed Secrets, Vault)
- [ ] Configure resource limits and requests
- [ ] Set up persistent storage for database
- [ ] Configure ingress with TLS/SSL
- [ ] Set up monitoring (Prometheus, Grafana)
- [ ] Configure logging (ELK, Loki)
- [ ] Implement network policies
- [ ] Set up backup strategy
- [ ] Configure auto-scaling
- [ ] Use specific image tags (not `latest`)
- [ ] Set up CI/CD pipeline

## 🔗 Useful Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Docker Documentation](https://docs.docker.com/)
- [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
