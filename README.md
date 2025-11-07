# Automobile Service - Kubernetes Deploymentcat > /mnt/user-data/outputs/deployment/DEPLOYMENT_SUMMARY.md << 'EOF'

# Docker & Kubernetes Deployment Files

Kubernetes deployment configuration for the Automobile Service Management System.## Complete Containerization and Orchestration



## 📋 Overview---



This repository contains Kubernetes manifests for deploying a full-stack application consisting of:## 📦 What's Included

- **Frontend**: React application (Vite + Nginx)

- **Backend**: Spring Boot REST API### Repositories

- **Database**: PostgreSQL with persistent storage

-Frontend Repo : https://github.com/Chamithjay/auto_service_frontend.git

## 🏗️ Architecture-Backend Repo  : https://github.com/Chamithjay/auto_service_backend.git



```

┌─────────────────┐### Docker Files (5 files)

│   Frontend      │ (React + Nginx)

│   Port: 80      │**Backend:**

└────────┬────────┘- `Dockerfile` - Multi-stage build for Spring Boot

         │- `.dockerignore` - Excludes unnecessary files

         ▼

┌─────────────────┐**Frontend:**

│   Backend       │ (Spring Boot)- `Dockerfile` - Multi-stage build with Nginx

│   Port: 8080    │- `.dockerignore` - Excludes node_modules, etc.

└────────┬────────┘- `nginx.conf` - Nginx configuration for React

         │

         ▼### Kubernetes Files (22 files)

┌─────────────────┐

│   PostgreSQL    │**Common (3 files):**

│   Port: 5432    │- `namespace.yaml` - Application namespace

└─────────────────┘- `ingress.yaml` - HTTP/HTTPS routing

```- `network-policy.yaml` - Network security



## 📁 Project Structure**Backend (5 files):**

- `configmap.yaml` - Configuration

```- `secret.yaml` - Sensitive data

automobile-service-deployment/- `deployment.yaml` - Pod specification

├── backend/- `service.yaml` - Service endpoint

│   ├── configmap.yaml      # Backend configuration- `hpa.yaml` - Auto-scaling

│   ├── secret.yaml         # Sensitive credentials

│   ├── deployment.yaml     # Backend pod specification**Frontend (4 files):**

│   ├── service.yaml        # Backend service endpoint- `configmap.yaml` - Configuration

│   └── hpa.yaml           # Horizontal Pod Autoscaler- `deployment.yaml` - Pod specification

├── frontend/- `service.yaml` - LoadBalancer

│   ├── configmap.yaml      # Frontend configuration- `hpa.yaml` - Auto-scaling

│   ├── deployment.yaml     # Frontend pod specification

│   ├── service.yaml        # Frontend LoadBalancer**Database (5 files):**

│   └── hpa.yaml           # Horizontal Pod Autoscaler- `configmap.yaml` - PostgreSQL config

├── database/- `secret.yaml` - Database password

│   ├── configmap.yaml      # PostgreSQL configuration- `pvc.yaml` - Persistent storage

│   ├── secret.yaml         # Database credentials- `statefulset.yaml` - PostgreSQL deployment

│   ├── pvc.yaml           # Persistent volume claim- `service.yaml` - Service endpoint

│   ├── statefulset.yaml   # PostgreSQL stateful deployment

│   └── service.yaml       # Database service**Scripts (2 files):**

├── common/- `deploy.sh` - Automated deployment

│   ├── namespace.yaml      # Application namespace- `cleanup.sh` - Cleanup script

│   ├── ingress.yaml       # HTTP routing (optional)

│   └── network-policy.yaml # Network security (optional)**Documentation (1 file):**

├── deploy.sh              # Automated deployment script- `KUBERNETES_GUIDE.md` - Comprehensive guide

├── cleanup.sh             # Cleanup script

└── docker-compose.yml     # Docker Compose alternative---

```

## 🚀 Quick Start

## 🚀 Quick Start

### Step 1: Build Docker Images

### Prerequisites

```bash

- Kubernetes cluster (Minikube, Docker Desktop, or cloud provider)# Backend

- `kubectl` CLI installedcd your-backend-project

- Docker images built and availabledocker build -t autoservice-backend:latest -f path/to/docker/backend/Dockerfile .



### Option 1: Automated Deployment (Recommended)# Frontend

cd your-frontend-project

```bashdocker build -t autoservice-frontend:latest -f path/to/docker/frontend/Dockerfile .

# Make scripts executable```

chmod +x deploy.sh cleanup.sh

### Step 2: Deploy to Kubernetes

# Deploy all components

./deploy.sh```bash

```cd kubernetes

chmod +x deploy.sh cleanup.sh

### Option 2: Manual Deployment./deploy.sh

```

```bash

# 1. Create namespace### Step 3: Access Application

kubectl apply -f common/namespace.yaml

```bash

# 2. Deploy database# Get the external IP

kubectl apply -f database/kubectl get service frontend-service -n autoservice



# 3. Wait for database to be ready# Access at http://<EXTERNAL-IP>

kubectl wait --for=condition=ready pod -l app=postgres -n autoservice --timeout=300s```



# 4. Deploy backend---

kubectl apply -f backend/

## 📁 File Structure

# 5. Wait for backend to be ready

kubectl wait --for=condition=ready pod -l app=backend -n autoservice --timeout=300s```

deployment/

# 6. Deploy frontend├── docker/

kubectl apply -f frontend/│   ├── backend/

```│   │   ├── Dockerfile

│   │   └── .dockerignore

## 🔧 Configuration│   └── frontend/

│       ├── Dockerfile

### Before Deployment│       ├── .dockerignore

│       └── nginx.conf

1. **Update Docker Image References** (if using custom registry):│

   ```bash├── kubernetes/

   # In backend/deployment.yaml and frontend/deployment.yaml│   ├── backend/

   image: your-registry/autoservice-backend:latest│   │   ├── configmap.yaml

   image: your-registry/autoservice-frontend:latest│   │   ├── secret.yaml

   ```│   │   ├── deployment.yaml

│   │   ├── service.yaml

2. **Configure Secrets** (Base64 encoded):│   │   └── hpa.yaml

   ```bash│   ├── frontend/

   # Encode your values│   │   ├── configmap.yaml

   echo -n 'your-password' | base64│   │   ├── deployment.yaml

   │   │   ├── service.yaml

   # Update in backend/secret.yaml and database/secret.yaml│   │   └── hpa.yaml

   ```│   ├── database/

│   │   ├── configmap.yaml

### Environment Variables│   │   ├── secret.yaml

│   │   ├── pvc.yaml

**Backend** (`backend/configmap.yaml`):│   │   ├── statefulset.yaml

- `SPRING_DATASOURCE_URL`: Database connection URL│   │   └── service.yaml

- `SERVER_PORT`: Backend server port (8080)│   ├── common/

- `JWT_EXPIRATION`: JWT token expiration time│   │   ├── namespace.yaml

│   │   ├── ingress.yaml

**Frontend** (`frontend/configmap.yaml`):│   │   └── network-policy.yaml

- `VITE_API_BASE_URL`: Backend API URL│   ├── deploy.sh

│   └── cleanup.sh

## 📊 Resource Limits│

├── KUBERNETES_GUIDE.md

| Component | Requests (CPU/Memory) | Limits (CPU/Memory) | Replicas |└── DEPLOYMENT_SUMMARY.md (this file)

|-----------|----------------------|---------------------|----------|```

| Frontend  | 100m / 128Mi         | 200m / 256Mi        | 2-10     |

| Backend   | 250m / 512Mi         | 500m / 1Gi          | 2-10     |---

| Database  | 250m / 256Mi         | 500m / 512Mi        | 1        |

## 🎯 Key Features

Auto-scaling configured at 70% CPU utilization.

### Docker

## 🌐 Accessing the Application- ✅ Multi-stage builds for optimization

- ✅ Security: Non-root users

### Minikube- ✅ Health checks configured

- ✅ Minimal base images (Alpine)

```bash- ✅ Production-ready

# Get service URL

minikube service frontend-service -n autoservice### Kubernetes

- ✅ Auto-scaling (HPA)

# Or use port forwarding- ✅ High availability (2+ replicas)

kubectl port-forward service/frontend-service 8080:80 -n autoservice- ✅ Health checks (liveness, readiness, startup)

```- ✅ Resource limits and requests

- ✅ Persistent storage for database

### Cloud Provider (LoadBalancer)- ✅ Network security policies

- ✅ ConfigMaps and Secrets

```bash- ✅ LoadBalancer service

# Get external IP- ✅ Ingress for routing

kubectl get service frontend-service -n autoservice- ✅ Automated deployment scripts



# Access at http://<EXTERNAL-IP>---

```

## 🔧 Configuration

## 🛠️ Management Commands

### Update Before Deployment

### View Resources

**1. Backend Secret (`backend/secret.yaml`):**

```bash```yaml

# All resources# Update these base64 encoded values:

kubectl get all -n autoserviceDB_USERNAME: <your-db-username-base64>

DB_PASSWORD: <your-db-password-base64>

# PodsJWT_SECRET: <your-jwt-secret-base64>

kubectl get pods -n autoserviceEMAIL_USERNAME: <your-email-base64>

EMAIL_PASSWORD: <your-email-password-base64>

# Services```

kubectl get services -n autoservice

**Encode values:**

# Persistent volumes```bash

kubectl get pvc -n autoserviceecho -n 'your-value' | base64

``````



### View Logs**2. Database Secret (`database/secret.yaml`):**

```yaml

```bashPOSTGRES_PASSWORD: <your-db-password-base64>

# Frontend logs```

kubectl logs -f deployment/frontend-deployment -n autoservice

**3. Image Names:**

# Backend logsUpdate image names in deployment files if using a container registry:

kubectl logs -f deployment/backend-deployment -n autoservice```yaml

image: your-registry.com/autoservice-backend:latest

# Database logs```

kubectl logs -f statefulset/postgres-statefulset -n autoservice

```---



### Scale Deployments## 📊 Resource Allocation



```bash### Backend

# Manual scaling- **Requests:** 512Mi memory, 250m CPU

kubectl scale deployment backend-deployment --replicas=5 -n autoservice- **Limits:** 1Gi memory, 500m CPU

kubectl scale deployment frontend-deployment --replicas=3 -n autoservice- **Replicas:** 2-10 (auto-scaling at 70% CPU)

```

### Frontend

### Update Deployment- **Requests:** 128Mi memory, 100m CPU

- **Limits:** 256Mi memory, 200m CPU

```bash- **Replicas:** 2-10 (auto-scaling at 70% CPU)

# Update image

kubectl set image deployment/backend-deployment backend=autoservice-backend:v2 -n autoservice### Database

- **Requests:** 256Mi memory, 250m CPU

# Restart deployment- **Limits:** 512Mi memory, 500m CPU

kubectl rollout restart deployment/backend-deployment -n autoservice- **Storage:** 10Gi persistent volume



# Check rollout status---

kubectl rollout status deployment/backend-deployment -n autoservice

```## 🔐 Security Features



## 🧹 Cleanup### Network Policies

1. Frontend → Backend communication only

### Using Script2. Backend → Database communication only

3. Ingress → Frontend access only

```bash4. Default deny all other traffic

./cleanup.sh

```### Pod Security

- Non-root users

The script will prompt you to:- Read-only root filesystem

- Delete all resources- Dropped capabilities

- Keep or delete PVC (database data)- Security contexts configured

- Keep or delete namespace

### Secrets Management

### Manual Cleanup- Base64 encoded secrets

- Kubernetes secret objects

```bash- Environment variable injection

# Delete all resources except PVC- **Recommendation:** Use external secret managers in production

kubectl delete all -n autoservice --all

---

# Delete PVC (WARNING: deletes all data)

kubectl delete pvc -n autoservice --all## 📝 Deployment Steps



# Delete namespace (deletes everything)### Automatic (Recommended)

kubectl delete namespace autoservice

``````bash

cd kubernetes

## 🐛 Troubleshooting./deploy.sh

```

### Pods Not Starting

**The script will:**

```bash1. ✅ Create namespace

# Describe pod to see events2. ✅ Deploy database with persistent storage

kubectl describe pod <pod-name> -n autoservice3. ✅ Wait for database to be ready

4. ✅ Deploy backend application

# Check logs5. ✅ Wait for backend to be ready

kubectl logs <pod-name> -n autoservice6. ✅ Deploy frontend application

7. ✅ Wait for frontend to be ready

# Check previous logs (if pod restarted)8. ✅ Apply network policies

kubectl logs <pod-name> -n autoservice --previous9. ✅ Apply ingress configuration

```10. ✅ Display deployment status



### Database Connection Issues### Manual



```bash```bash

# Test database connectivity# 1. Namespace

kubectl exec -it postgres-statefulset-0 -n autoservice -- psql -U postgreskubectl apply -f common/namespace.yaml



# Check database logs# 2. Database

kubectl logs postgres-statefulset-0 -n autoservicekubectl apply -f database/



# Verify database service# 3. Backend (after database is ready)

kubectl get endpoints postgres-service -n autoservicekubectl apply -f backend/

```

# 4. Frontend (after backend is ready)

### Service Not Accessiblekubectl apply -f frontend/



```bash# 5. Common resources

# Check service endpointskubectl apply -f common/

kubectl get endpoints -n autoservice```



# Describe service---

kubectl describe service frontend-service -n autoservice

## 🎛️ Management Commands

# Test internal connectivity

kubectl run -it --rm debug --image=curlimages/curl --restart=Never -n autoservice -- sh### View Resources

``````bash

kubectl get all -n autoservice

## 📝 Noteskubectl get pods -n autoservice

kubectl get services -n autoservice

- **Persistent Storage**: Database data is stored in a Persistent Volume (10Gi)kubectl get hpa -n autoservice

- **Auto-scaling**: HPA configured for frontend and backend (2-10 replicas)```

- **Health Checks**: Liveness and readiness probes configured for all services

- **Security**: Secrets are base64 encoded (use external secret managers for production)### View Logs

```bash

## 🔗 Related Repositorieskubectl logs -f deployment/backend-deployment -n autoservice

kubectl logs -f deployment/frontend-deployment -n autoservice

- Frontend: https://github.com/Chamithjay/auto_service_frontendkubectl logs -f statefulset/postgres-statefulset -n autoservice

- Backend: https://github.com/Chamithjay/auto_service_backend```



## 📄 License### Port Forwarding

```bash

This project is part of the Automobile Service Management System.# Backend

kubectl port-forward service/backend-service 8080:8080 -n autoservice

---

# Frontend

**Version**: 1.0  kubectl port-forward service/frontend-service 8081:80 -n autoservice

**Last Updated**: November 2025

# Database
kubectl port-forward service/postgres-service 5432:5432 -n autoservice
```

### Scale Manually
```bash
kubectl scale deployment backend-deployment --replicas=5 -n autoservice
kubectl scale deployment frontend-deployment --replicas=5 -n autoservice
```

### Update Deployment
```bash
# Update image
kubectl set image deployment/backend-deployment backend=autoservice-backend:v2 -n autoservice

# Restart deployment
kubectl rollout restart deployment/backend-deployment -n autoservice
```

---

## 🧹 Cleanup

### Using Script
```bash
cd kubernetes
./cleanup.sh
```

**Options:**
- Keep or delete PVC (database data)
- Keep or delete namespace

### Manual
```bash
# Delete all except PVC
kubectl delete all -n autoservice --all

# Delete PVC (WARNING: deletes data)
kubectl delete pvc -n autoservice --all

# Delete namespace (deletes everything)
kubectl delete namespace autoservice
```

---

## 🐛 Troubleshooting

### Pods Not Starting
```bash
kubectl describe pod <pod-name> -n autoservice
kubectl logs <pod-name> -n autoservice
```

### Service Not Accessible
```bash
kubectl get endpoints -n autoservice
kubectl describe service <service-name> -n autoservice
```

### Database Issues
```bash
# Check database
kubectl exec -it postgres-statefulset-0 -n autoservice -- psql -U postgres

# View logs
kubectl logs postgres-statefulset-0 -n autoservice
```

### Resource Issues
```bash
# Check node resources
kubectl top nodes

# Check pod resources
kubectl top pods -n autoservice
```

---

## 📋 Production Checklist

### Pre-Deployment
- [ ] Update all secrets with actual values
- [ ] Change default passwords
- [ ] Configure email credentials
- [ ] Update JWT secret
- [ ] Set appropriate resource limits
- [ ] Configure storage class for PVC

### Security
- [ ] Use external secret manager
- [ ] Enable RBAC
- [ ] Configure network policies
- [ ] Use TLS/SSL certificates
- [ ] Scan images for vulnerabilities

### Monitoring
- [ ] Set up Prometheus
- [ ] Configure Grafana dashboards
- [ ] Enable application metrics
- [ ] Set up alerting

### Backup
- [ ] Implement database backup strategy
- [ ] Test restore procedures
- [ ] Store backups off-cluster

---

## 🎓 Key Concepts

### Docker
- **Multi-stage builds:** Reduces image size
- **Alpine Linux:** Minimal base image
- **Non-root user:** Security best practice
- **Health checks:** Container health monitoring

### Kubernetes
- **Namespace:** Resource isolation
- **ConfigMap:** Non-sensitive configuration
- **Secret:** Sensitive data storage
- **Deployment:** Manages pods
- **StatefulSet:** For stateful applications
- **Service:** Network endpoint
- **HPA:** Auto-scaling
- **PVC:** Persistent storage
- **Ingress:** HTTP routing
- **NetworkPolicy:** Network security

---

## 📚 Additional Resources

### Documentation
- [Kubernetes Guide](KUBERNETES_GUIDE.md) - Comprehensive documentation
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

### Tools
- [kubectl](https://kubernetes.io/docs/reference/kubectl/) - Kubernetes CLI
- [k9s](https://k9scli.io/) - Terminal UI
- [Lens](https://k8slens.dev/) - Kubernetes IDE
- [Helm](https://helm.sh/) - Package manager

---

## ✨ Summary

### Total Files: 27
- 5 Docker files
- 22 Kubernetes files (17 YAML + 2 scripts + 1 docs + 2 summaries)

### What You Can Do
- ✅ Build optimized Docker images
- ✅ Deploy to any Kubernetes cluster
- ✅ Auto-scale based on load
- ✅ Ensure high availability
- ✅ Secure network communication
- ✅ Persist database data
- ✅ Monitor application health
- ✅ Manage with simple scripts

### Ready For
- ✅ Development environments
- ✅ Testing environments
- ✅ Production deployment
- ✅ Cloud providers (AWS, GCP, Azure)
- ✅ On-premise clusters
- ✅ Local development (Minikube, Docker Desktop)

---

**Your application is ready for containerized deployment! 🚀**

*All files follow production best practices and are ready to use.*

---

*Part of: Automobile Service Time Logging & Appointment System*  
*Module: Docker & Kubernetes Deployment*  
*Created: November 2025*  
*Version: 1.0*
EOF

cat /mnt/user-data/outputs/deployment/DEPLOYMENT_SUMMARY.md
Output

# Docker & Kubernetes Deployment Files
## Complete Containerization and Orchestration

---

## 📦 What's Included

### Docker Files (5 files)

**Backend:**
- `Dockerfile` - Multi-stage build for Spring Boot
- `.dockerignore` - Excludes unnecessary files

**Frontend:**
- `Dockerfile` - Multi-stage build with Nginx
- `.dockerignore` - Excludes node_modules, etc.
- `nginx.conf` - Nginx configuration for React

### Kubernetes Files (22 files)

**Common (3 files):**
- `namespace.yaml` - Application namespace
- `ingress.yaml` - HTTP/HTTPS routing
- `network-policy.yaml` - Network security

**Backend (5 files):**
- `configmap.yaml` - Configuration
- `secret.yaml` - Sensitive data
- `deployment.yaml` - Pod specification
- `service.yaml` - Service endpoint
- `hpa.yaml` - Auto-scaling

**Frontend (4 files):**
- `configmap.yaml` - Configuration
- `deployment.yaml` - Pod specification
- `service.yaml` - LoadBalancer
- `hpa.yaml` - Auto-scaling

**Database (5 files):**
- `configmap.yaml` - PostgreSQL config
- `secret.yaml` - Database password
- `pvc.yaml` - Persistent storage
- `statefulset.yaml` - PostgreSQL deployment
- `service.yaml` - Service endpoint

**Scripts (2 files):**
- `deploy.sh` - Automated deployment
- `cleanup.sh` - Cleanup script

**Documentation (1 file):**
- `KUBERNETES_GUIDE.md` - Comprehensive guide

---

## 🚀 Quick Start

### Step 1: Build Docker Images

```bash
# Backend
cd your-backend-project
docker build -t autoservice-backend:latest -f path/to/docker/backend/Dockerfile .

# Frontend
cd your-frontend-project
docker build -t autoservice-frontend:latest -f path/to/docker/frontend/Dockerfile .
```

### Step 2: Deploy to Kubernetes

```bash
cd kubernetes
chmod +x deploy.sh cleanup.sh
./deploy.sh
```

### Step 3: Access Application

```bash
# Get the external IP
kubectl get service frontend-service -n autoservice

# Access at http://<EXTERNAL-IP>
```

---

## 📁 File Structure

```
deployment/
├── docker/
│   ├── backend/
│   │   ├── Dockerfile
│   │   └── .dockerignore
│   └── frontend/
│       ├── Dockerfile
│       ├── .dockerignore
│       └── nginx.conf
│
├── kubernetes/
│   ├── backend/
│   │   ├── configmap.yaml
│   │   ├── secret.yaml
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── hpa.yaml
│   ├── frontend/
│   │   ├── configmap.yaml
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── hpa.yaml
│   ├── database/
│   │   ├── configmap.yaml
│   │   ├── secret.yaml
│   │   ├── pvc.yaml
│   │   ├── statefulset.yaml
│   │   └── service.yaml
│   ├── common/
│   │   ├── namespace.yaml
│   │   ├── ingress.yaml
│   │   └── network-policy.yaml
│   ├── deploy.sh
│   └── cleanup.sh

```

---

## 🎯 Key Features

### Docker
- ✅ Multi-stage builds for optimization
- ✅ Security: Non-root users
- ✅ Health checks configured
- ✅ Minimal base images (Alpine)
- ✅ Production-ready

### Kubernetes
- ✅ Auto-scaling (HPA)
- ✅ High availability (2+ replicas)
- ✅ Health checks (liveness, readiness, startup)
- ✅ Resource limits and requests
- ✅ Persistent storage for database
- ✅ Network security policies
- ✅ ConfigMaps and Secrets
- ✅ LoadBalancer service
- ✅ Ingress for routing
- ✅ Automated deployment scripts

---

## 🔧 Configuration

### Update Before Deployment

**1. Backend Secret (`backend/secret.yaml`):**
```yaml
# Update these base64 encoded values:
DB_USERNAME: <your-db-username-base64>
DB_PASSWORD: <your-db-password-base64>
JWT_SECRET: <your-jwt-secret-base64>
EMAIL_USERNAME: <your-email-base64>
EMAIL_PASSWORD: <your-email-password-base64>
```

**Encode values:**
```bash
echo -n 'your-value' | base64
```

**2. Database Secret (`database/secret.yaml`):**
```yaml
POSTGRES_PASSWORD: <your-db-password-base64>
```

**3. Image Names:**
Update image names in deployment files if using a container registry:
```yaml
image: your-registry.com/autoservice-backend:latest
```

---

## 📊 Resource Allocation

### Backend
- **Requests:** 512Mi memory, 250m CPU
- **Limits:** 1Gi memory, 500m CPU
- **Replicas:** 2-10 (auto-scaling at 70% CPU)

### Frontend
- **Requests:** 128Mi memory, 100m CPU
- **Limits:** 256Mi memory, 200m CPU
- **Replicas:** 2-10 (auto-scaling at 70% CPU)

### Database
- **Requests:** 256Mi memory, 250m CPU
- **Limits:** 512Mi memory, 500m CPU
- **Storage:** 10Gi persistent volume

---

## 🔐 Security Features

### Network Policies
1. Frontend → Backend communication only
2. Backend → Database communication only
3. Ingress → Frontend access only
4. Default deny all other traffic

### Pod Security
- Non-root users
- Read-only root filesystem
- Dropped capabilities
- Security contexts configured

### Secrets Management
- Base64 encoded secrets
- Kubernetes secret objects
- Environment variable injection
- **Recommendation:** Use external secret managers in production

---

## 📝 Deployment Steps

### Automatic (Recommended)

```bash
cd kubernetes
./deploy.sh
```

**The script will:**
1. ✅ Create namespace
2. ✅ Deploy database with persistent storage
3. ✅ Wait for database to be ready
4. ✅ Deploy backend application
5. ✅ Wait for backend to be ready
6. ✅ Deploy frontend application
7. ✅ Wait for frontend to be ready
8. ✅ Apply network policies
9. ✅ Apply ingress configuration
10. ✅ Display deployment status

### Manual

```bash
# 1. Namespace
kubectl apply -f common/namespace.yaml

# 2. Database
kubectl apply -f database/

# 3. Backend (after database is ready)
kubectl apply -f backend/

# 4. Frontend (after backend is ready)
kubectl apply -f frontend/

# 5. Common resources
kubectl apply -f common/
```

---

## 🎛️ Management Commands

### View Resources
```bash
kubectl get all -n autoservice
kubectl get pods -n autoservice
kubectl get services -n autoservice
kubectl get hpa -n autoservice
```

### View Logs
```bash
kubectl logs -f deployment/backend-deployment -n autoservice
kubectl logs -f deployment/frontend-deployment -n autoservice
kubectl logs -f statefulset/postgres-statefulset -n autoservice
```

### Port Forwarding
```bash
# Backend
kubectl port-forward service/backend-service 8080:8080 -n autoservice

# Frontend
kubectl port-forward service/frontend-service 8081:80 -n autoservice

# Database
kubectl port-forward service/postgres-service 5432:5432 -n autoservice
```

### Scale Manually
```bash
kubectl scale deployment backend-deployment --replicas=5 -n autoservice
kubectl scale deployment frontend-deployment --replicas=5 -n autoservice
```

### Update Deployment
```bash
# Update image
kubectl set image deployment/backend-deployment backend=autoservice-backend:v2 -n autoservice

# Restart deployment
kubectl rollout restart deployment/backend-deployment -n autoservice
```

---

## 🧹 Cleanup

### Using Script
```bash
cd kubernetes
./cleanup.sh
```

**Options:**
- Keep or delete PVC (database data)
- Keep or delete namespace

### Manual
```bash
# Delete all except PVC
kubectl delete all -n autoservice --all

# Delete PVC (WARNING: deletes data)
kubectl delete pvc -n autoservice --all

# Delete namespace (deletes everything)
kubectl delete namespace autoservice
```

---

## 🐛 Troubleshooting

### Pods Not Starting
```bash
kubectl describe pod <pod-name> -n autoservice
kubectl logs <pod-name> -n autoservice
```

### Service Not Accessible
```bash
kubectl get endpoints -n autoservice
kubectl describe service <service-name> -n autoservice
```

### Database Issues
```bash
# Check database
kubectl exec -it postgres-statefulset-0 -n autoservice -- psql -U postgres

# View logs
kubectl logs postgres-statefulset-0 -n autoservice
```

### Resource Issues
```bash
# Check node resources
kubectl top nodes

# Check pod resources
kubectl top pods -n autoservice
```

---

## 📋 Production Checklist

### Pre-Deployment
- [ ] Update all secrets with actual values
- [ ] Change default passwords
- [ ] Configure email credentials
- [ ] Update JWT secret
- [ ] Set appropriate resource limits
- [ ] Configure storage class for PVC

### Security
- [ ] Use external secret manager
- [ ] Enable RBAC
- [ ] Configure network policies
- [ ] Use TLS/SSL certificates
- [ ] Scan images for vulnerabilities

### Monitoring
- [ ] Set up Prometheus
- [ ] Configure Grafana dashboards
- [ ] Enable application metrics
- [ ] Set up alerting

### Backup
- [ ] Implement database backup strategy
- [ ] Test restore procedures
- [ ] Store backups off-cluster

---

## 🎓 Key Concepts

### Docker
- **Multi-stage builds:** Reduces image size
- **Alpine Linux:** Minimal base image
- **Non-root user:** Security best practice
- **Health checks:** Container health monitoring

### Kubernetes
- **Namespace:** Resource isolation
- **ConfigMap:** Non-sensitive configuration
- **Secret:** Sensitive data storage
- **Deployment:** Manages pods
- **StatefulSet:** For stateful applications
- **Service:** Network endpoint
- **HPA:** Auto-scaling
- **PVC:** Persistent storage
- **Ingress:** HTTP routing
- **NetworkPolicy:** Network security

---

## 📚 Additional Resources

### Documentation
- [Kubernetes Guide](KUBERNETES_GUIDE.md) - Comprehensive documentation
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

### Tools
- [kubectl](https://kubernetes.io/docs/reference/kubectl/) - Kubernetes CLI
- [k9s](https://k9scli.io/) - Terminal UI
- [Lens](https://k8slens.dev/) - Kubernetes IDE
- [Helm](https://helm.sh/) - Package manager

---

## ✨ Summary

### Total Files: 27
- 5 Docker files
- 22 Kubernetes files (17 YAML + 2 scripts + 1 docs + 2 summaries)

### What You Can Do
- ✅ Build optimized Docker images
- ✅ Deploy to any Kubernetes cluster
- ✅ Auto-scale based on load
- ✅ Ensure high availability
- ✅ Secure network communication
- ✅ Persist database data
- ✅ Monitor application health
- ✅ Manage with simple scripts

---

**Your application is ready for containerized deployment! 🚀**

*All files follow production best practices and are ready to use.*

---

*Part of: Automobile Service Time Logging & Appointment System*  
*Module: Docker & Kubernetes Deployment*  
*Version: 1.0*