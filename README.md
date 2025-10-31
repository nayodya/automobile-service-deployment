# Automobile Service - Kubernetes Deployment

This repository contains Kubernetes deployment configurations for the Automobile Service application, consisting of a React frontend, Spring Boot backend, and PostgreSQL database.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Ingress Controller                 │
│              (auto-service.local)                    │
└────────────┬────────────────────────┬───────────────┘
             │                        │
             │ /                      │ /api
             │                        │
    ┌────────▼────────┐      ┌───────▼────────┐
    │    Frontend     │      │    Backend     │
    │   Service       │      │   Service      │
    │   (Port 80)     │      │   (Port 8080)  │
    └────────┬────────┘      └───────┬────────┘
             │                        │
    ┌────────▼────────┐      ┌───────▼────────┐
    │   Frontend      │      │    Backend     │
    │   Deployment    │      │   Deployment   │
    │   (2 replicas)  │      │   (2 replicas) │
    │   React/Nginx   │      │   Spring Boot  │
    └─────────────────┘      └───────┬────────┘
                                     │
                             ┌───────▼────────┐
                             │   PostgreSQL   │
                             │    Service     │
                             │   (Port 5432)  │
                             └───────┬────────┘
                                     │
                             ┌───────▼────────┐
                             │   PostgreSQL   │
                             │   Deployment   │
                             │   + PVC (5Gi)  │
                             └────────────────┘
```

## 📁 Project Structure

```
automobile-service-deployment/
├── kubernetes/
│   ├── namespace.yaml                 # Namespace definition
│   ├── database/
│   │   ├── deployment.yaml           # PostgreSQL deployment
│   │   ├── service.yaml              # PostgreSQL service
│   │   ├── pvc.yaml                  # Persistent volume claim
│   │   └── secret.yaml               # Database credentials
│   ├── backend/
│   │   ├── deployment.yaml           # Spring Boot deployment
│   │   ├── service.yaml              # Backend service
│   │   ├── configmap.yaml            # Application configuration
│   │   ├── secret.yaml               # Sensitive data (JWT, DB password)
│   │   └── ingress.yaml              # Backend ingress (optional)
│   ├── frontend/
│   │   ├── deployment.yaml           # React/Nginx deployment
│   │   ├── service.yaml              # Frontend service
│   │   ├── configmap.yaml            # Frontend environment variables
│   │   └── ingress.yaml              # Frontend ingress
│   └── ingress.yaml                  # Global ingress controller
└── README.md
```

## 🚀 Prerequisites

Before deploying, ensure you have:

1. **Kubernetes Cluster** (one of the following):
   - Minikube (local development)
   - Docker Desktop with Kubernetes
   - Cloud provider (GKE, EKS, AKS)
   - On-premise cluster

2. **Tools**:
   - `kubectl` CLI installed and configured
   - Docker installed (for building images)
   - Access to a Docker registry (Docker Hub, GCR, ECR, etc.)

3. **Ingress Controller**:
   ```bash
   # For Minikube
   minikube addons enable ingress
   
   # For other Kubernetes clusters
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
   ```

## 🔨 Building Docker Images

### 1. Build Backend Image

```bash
cd auto_service_backend

# Build the image
docker build -t your-registry/auto-service-backend:latest .

# Push to registry
docker push your-registry/auto-service-backend:latest
```

### 2. Build Frontend Image

```bash
cd auto_service_frontend

# Build the image
docker build -t your-registry/auto-service-frontend:latest .

# Push to registry
docker push your-registry/auto-service-frontend:latest
```

**Note**: Replace `your-registry` with your actual Docker registry (e.g., `docker.io/yourusername`, `gcr.io/project-id`, etc.)

## ⚙️ Configuration

### 1. Update Image References

Edit the deployment files to use your Docker images:

**Backend** (`kubernetes/backend/deployment.yaml`):
```yaml
spec:
  template:
    spec:
      containers:
      - name: backend
        image: your-registry/auto-service-backend:latest  # Update this
```

**Frontend** (`kubernetes/frontend/deployment.yaml`):
```yaml
spec:
  template:
    spec:
      containers:
      - name: frontend
        image: your-registry/auto-service-frontend:latest  # Update this
```

### 2. Update Domain Names

Replace `auto-service.local` with your actual domain in:
- `kubernetes/ingress.yaml`
- `kubernetes/backend/ingress.yaml`
- `kubernetes/frontend/ingress.yaml`
- `kubernetes/frontend/configmap.yaml` (VITE_API_BASE_URL)

For local testing, add to `/etc/hosts` (Linux/Mac) or `C:\Windows\System32\drivers\etc\hosts` (Windows):
```
127.0.0.1 auto-service.local
```

### 3. Update Secrets (Important!)

**Generate secure base64 encoded values**:

```bash
# For database password
echo -n "your-secure-password" | base64

# For JWT secret (should be long and random)
echo -n "your-jwt-secret-key-min-32-chars" | base64
```

Update the following files with your base64 encoded values:
- `kubernetes/database/secret.yaml` - Database credentials
- `kubernetes/backend/secret.yaml` - JWT secret and database password

### 4. Storage Class

Update `kubernetes/database/pvc.yaml` based on your environment:
- **Minikube/Docker Desktop**: `standard`
- **GKE**: `standard` or `standard-rwo`
- **EKS**: `gp2` or `gp3`
- **AKS**: `default` or `managed-premium`

## 🚢 Deployment Steps

### Step 1: Create Namespace

```bash
kubectl apply -f kubernetes/namespace.yaml
```

### Step 2: Deploy Database

```bash
# Apply database configurations
kubectl apply -f kubernetes/database/secret.yaml
kubectl apply -f kubernetes/database/pvc.yaml
kubectl apply -f kubernetes/database/deployment.yaml
kubectl apply -f kubernetes/database/service.yaml

# Wait for database to be ready
kubectl wait --for=condition=ready pod -l app=postgres -n auto-service --timeout=300s
```

### Step 3: Deploy Backend

```bash
# Apply backend configurations
kubectl apply -f kubernetes/backend/secret.yaml
kubectl apply -f kubernetes/backend/configmap.yaml
kubectl apply -f kubernetes/backend/deployment.yaml
kubectl apply -f kubernetes/backend/service.yaml

# Wait for backend to be ready
kubectl wait --for=condition=ready pod -l app=backend -n auto-service --timeout=300s
```

### Step 4: Deploy Frontend

```bash
# Apply frontend configurations
kubectl apply -f kubernetes/frontend/configmap.yaml
kubectl apply -f kubernetes/frontend/deployment.yaml
kubectl apply -f kubernetes/frontend/service.yaml
```

### Step 5: Configure Ingress

```bash
# Apply global ingress
kubectl apply -f kubernetes/ingress.yaml

# Get ingress IP/hostname
kubectl get ingress -n auto-service
```

### Deploy Everything at Once (Alternative)

```bash
# Deploy all resources
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/database/
kubectl apply -f kubernetes/backend/
kubectl apply -f kubernetes/frontend/
kubectl apply -f kubernetes/ingress.yaml
```

## 🔍 Verification

### Check Deployment Status

```bash
# Get all resources in namespace
kubectl get all -n auto-service

# Check pod status
kubectl get pods -n auto-service

# Check services
kubectl get svc -n auto-service

# Check ingress
kubectl get ingress -n auto-service
```

### View Logs

```bash
# Backend logs
kubectl logs -f deployment/backend -n auto-service

# Frontend logs
kubectl logs -f deployment/frontend -n auto-service

# Database logs
kubectl logs -f deployment/postgres -n auto-service
```

### Test Application

```bash
# Get ingress address
kubectl get ingress auto-service-ingress -n auto-service

# For Minikube
minikube service list -n auto-service
```

Access the application:
- Frontend: `http://auto-service.local`
- Backend API: `http://auto-service.local/api`

## 🐛 Troubleshooting

### Pods Not Starting

```bash
# Describe pod to see events
kubectl describe pod <pod-name> -n auto-service

# Check pod logs
kubectl logs <pod-name> -n auto-service
```

### Database Connection Issues

```bash
# Check if database is running
kubectl get pods -l app=postgres -n auto-service

# Test database connectivity from backend pod
kubectl exec -it deployment/backend -n auto-service -- sh
nc -zv postgres-service 5432
```

### Ingress Not Working

```bash
# Check ingress controller is running
kubectl get pods -n ingress-nginx

# Check ingress events
kubectl describe ingress auto-service-ingress -n auto-service

# For Minikube, ensure ingress addon is enabled
minikube addons list | grep ingress
```

### ImagePullBackOff Error

- Verify image names in deployment files
- Ensure images are pushed to the registry
- Check if registry authentication is required (create image pull secrets)

## 🔄 Update Deployment

### Update Backend

```bash
# Build and push new image
docker build -t your-registry/auto-service-backend:v2 auto_service_backend/
docker push your-registry/auto-service-backend:v2

# Update deployment
kubectl set image deployment/backend backend=your-registry/auto-service-backend:v2 -n auto-service

# Or edit deployment file and apply
kubectl apply -f kubernetes/backend/deployment.yaml
```

### Update Frontend

```bash
# Build and push new image
docker build -t your-registry/auto-service-frontend:v2 auto_service_frontend/
docker push your-registry/auto-service-frontend:v2

# Update deployment
kubectl set image deployment/frontend frontend=your-registry/auto-service-frontend:v2 -n auto-service
```

## 📊 Scaling

### Manual Scaling

```bash
# Scale backend
kubectl scale deployment backend --replicas=3 -n auto-service

# Scale frontend
kubectl scale deployment frontend --replicas=3 -n auto-service
```

### Auto-scaling (HPA)

```bash
# Create Horizontal Pod Autoscaler
kubectl autoscale deployment backend --cpu-percent=70 --min=2 --max=10 -n auto-service
kubectl autoscale deployment frontend --cpu-percent=70 --min=2 --max=5 -n auto-service
```

## 🧹 Cleanup

### Delete All Resources

```bash
# Delete namespace (removes everything)
kubectl delete namespace auto-service
```

### Delete Specific Components

```bash
kubectl delete -f kubernetes/ingress.yaml
kubectl delete -f kubernetes/frontend/
kubectl delete -f kubernetes/backend/
kubectl delete -f kubernetes/database/
```

## 🔐 Security Best Practices

1. **Secrets Management**:
   - Never commit actual secrets to Git
   - Use external secret management (Sealed Secrets, Vault, etc.)
   - Rotate secrets regularly

2. **Network Policies**:
   - Implement network policies to restrict pod-to-pod communication
   - Only allow necessary traffic

3. **RBAC**:
   - Create service accounts with minimal required permissions
   - Use Pod Security Policies/Standards

4. **Image Security**:
   - Use official base images
   - Scan images for vulnerabilities
   - Use specific image tags, not `latest`

## 📝 Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Spring Boot on Kubernetes](https://spring.io/guides/gs/spring-boot-kubernetes/)
- [React Deployment Best Practices](https://create-react-app.dev/docs/deployment/)
- [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/)

## 🆘 Support

For issues and questions:
1. Check pod logs: `kubectl logs -f <pod-name> -n auto-service`
2. Check events: `kubectl get events -n auto-service --sort-by='.lastTimestamp'`
3. Review deployment status: `kubectl describe deployment <name> -n auto-service`

## 📄 License

[Your License Here]
