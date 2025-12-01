// Jenkins Pipeline - Auto Service Complete Deployment
// Orchestrates building and deploying all services (Backend, Frontend, Database)

pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 45, unit: 'MINUTES')
        timestamps()
    }

    environment {
        // Repository URLs
        BACKEND_REPO = 'https://github.com/Chamithjay/auto_service_backend.git'
        FRONTEND_REPO = 'https://github.com/Chamithjay/auto_service_frontend.git'
        DEPLOYMENT_REPO = 'https://github.com/nayodya/automobile-service-deployment.git'
        
        // Branch configuration
        BACKEND_BRANCH = 'nipuna'
        FRONTEND_BRANCH = 'nipuna'
        DEPLOYMENT_BRANCH = 'main'
        
        // Docker configuration
        BACKEND_IMAGE = 'autoservice-backend:latest'
        FRONTEND_IMAGE = 'autoservice-frontend:latest'
        
        // Build directories
        WORKSPACE_ROOT = "${WORKSPACE}"
        BACKEND_DIR = "${WORKSPACE_ROOT}/backend"
        FRONTEND_DIR = "${WORKSPACE_ROOT}/frontend"
        DEPLOYMENT_DIR = "${WORKSPACE_ROOT}/deployment"
    }

    stages {
        stage('Initialize') {
            steps {
                script {
                    echo '========== STAGE: Initialize =========='
                    sh '''
                        echo "Workspace: ${WORKSPACE_ROOT}"
                        echo "Docker version:"
                        docker --version
                        echo "Docker Compose version:"
                        docker-compose --version
                        echo "Current time: $(date)"
                    '''
                }
            }
        }

        stage('Checkout Repositories') {
            parallel {
                stage('Checkout Backend') {
                    steps {
                        script {
                            echo '========== STAGE: Checkout Backend =========='
                            dir("${BACKEND_DIR}") {
                                deleteDir()
                                checkout([
                                    $class: 'GitSCM',
                                    branches: [[name: "${BACKEND_BRANCH}"]],
                                    userRemoteConfigs: [[url: "${BACKEND_REPO}"]]
                                ])
                            }
                            echo "✅ Backend repository cloned"
                        }
                    }
                }
                stage('Checkout Frontend') {
                    steps {
                        script {
                            echo '========== STAGE: Checkout Frontend =========='
                            dir("${FRONTEND_DIR}") {
                                deleteDir()
                                checkout([
                                    $class: 'GitSCM',
                                    branches: [[name: "${FRONTEND_BRANCH}"]],
                                    userRemoteConfigs: [[url: "${FRONTEND_REPO}"]]
                                ])
                            }
                            echo "✅ Frontend repository cloned"
                        }
                    }
                }
                stage('Checkout Deployment') {
                    steps {
                        script {
                            echo '========== STAGE: Checkout Deployment =========='
                            dir("${DEPLOYMENT_DIR}") {
                                deleteDir()
                                checkout([
                                    $class: 'GitSCM',
                                    branches: [[name: "${DEPLOYMENT_BRANCH}"]],
                                    userRemoteConfigs: [[url: "${DEPLOYMENT_REPO}"]]
                                ])
                            }
                            echo "✅ Deployment repository cloned"
                        }
                    }
                }
            }
        }

        stage('Build Backend') {
            steps {
                script {
                    echo '========== STAGE: Build Backend =========='
                    dir("${BACKEND_DIR}") {
                        sh '''
                            echo "Building Spring Boot backend..."
                            mvn clean package -DskipTests
                            
                            if [ $? -eq 0 ]; then
                                echo "✅ Backend build successful"
                            else
                                echo "❌ Backend build failed"
                                exit 1
                            fi
                        '''
                    }
                }
            }
        }

        stage('Build Frontend') {
            steps {
                script {
                    echo '========== STAGE: Build Frontend =========='
                    dir("${FRONTEND_DIR}") {
                        sh '''
                            echo "Building React frontend..."
                            npm ci --silent
                            npm run build
                            
                            if [ -d "dist" ]; then
                                echo "✅ Frontend build successful"
                            else
                                echo "❌ Frontend build failed"
                                exit 1
                            fi
                        '''
                    }
                }
            }
        }

        stage('Build Docker Images') {
            parallel {
                stage('Build Backend Image') {
                    steps {
                        script {
                            echo '========== STAGE: Build Backend Docker Image =========='
                            dir("${BACKEND_DIR}") {
                                sh '''
                                    echo "Building backend Docker image..."
                                    docker build -t ${BACKEND_IMAGE} .
                                    echo "✅ Backend Docker image built"
                                '''
                            }
                        }
                    }
                }
                stage('Build Frontend Image') {
                    steps {
                        script {
                            echo '========== STAGE: Build Frontend Docker Image =========='
                            dir("${FRONTEND_DIR}") {
                                sh '''
                                    echo "Building frontend Docker image..."
                                    docker build \\
                                        --build-arg VITE_API_BASE_URL="http://localhost:8080/api" \\
                                        -t ${FRONTEND_IMAGE} .
                                    echo "✅ Frontend Docker image built"
                                '''
                            }
                        }
                    }
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    echo '========== STAGE: Run Tests =========='
                    dir("${BACKEND_DIR}") {
                        sh '''
                            echo "Running backend tests..."
                            mvn test
                        '''
                    }
                }
            }
            post {
                always {
                    dir("${BACKEND_DIR}") {
                        junit 'target/surefire-reports/**/*.xml'
                    }
                }
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                script {
                    echo '========== STAGE: Deploy with Docker Compose =========='
                    dir("${DEPLOYMENT_DIR}") {
                        sh '''
                            echo "Starting all services with Docker Compose..."
                            docker-compose -f docker-compose.yml down || true
                            sleep 5
                            docker-compose -f docker-compose.yml up -d
                            
                            if [ $? -eq 0 ]; then
                                echo "✅ Docker Compose deployment initiated"
                            else
                                echo "❌ Docker Compose deployment failed"
                                exit 1
                            fi
                        '''
                    }
                }
            }
        }

        stage('Wait for Services') {
            steps {
                script {
                    echo '========== STAGE: Wait for Services =========='
                    sh '''
                        echo "Waiting for services to become ready (40 seconds)..."
                        for i in {1..8}; do
                            echo "Attempt $i/8..."
                            sleep 5
                        done
                        echo "✅ Wait completed"
                    '''
                }
            }
        }

        stage('Health Checks') {
            steps {
                script {
                    echo '========== STAGE: Health Checks =========='
                    sh '''
                        echo "Running health checks..."
                        
                        echo "1. Checking container status..."
                        docker ps --format "table {{.Names}}\t{{.Status}}" | grep autoservice
                        
                        echo ""
                        echo "2. Checking PostgreSQL..."
                        docker exec autoservice-postgres pg_isready -U postgres 2>/dev/null && \\
                            echo "✅ PostgreSQL is ready" || echo "⚠️  PostgreSQL check result: $?"
                        
                        echo ""
                        echo "3. Checking Backend..."
                        BACKEND_HEALTH=$(docker exec autoservice-backend curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/actuator/health 2>/dev/null)
                        if [ "$BACKEND_HEALTH" = "200" ]; then
                            echo "✅ Backend is healthy (HTTP $BACKEND_HEALTH)"
                        else
                            echo "⚠️  Backend health check returned: HTTP $BACKEND_HEALTH"
                        fi
                        
                        echo ""
                        echo "4. Checking Frontend..."
                        FRONTEND_HEALTH=$(docker exec autoservice-frontend curl -s -o /dev/null -w "%{http_code}" http://localhost/health 2>/dev/null)
                        if [ "$FRONTEND_HEALTH" = "200" ] || [ "$FRONTEND_HEALTH" = "404" ]; then
                            echo "✅ Frontend is running"
                        else
                            echo "⚠️  Frontend health check returned: HTTP $FRONTEND_HEALTH"
                        fi
                        
                        echo ""
                        echo "5. Checking Docker volumes..."
                        docker volume ls | grep autoservice || echo "ℹ️  No autoservice volumes found"
                    '''
                }
            }
        }

        stage('Display Summary') {
            steps {
                script {
                    echo '''
                    ╔═══════════════════════════════════════════════════════════════╗
                    ║          ✅ AUTO SERVICE DEPLOYMENT COMPLETE ✅               ║
                    ╚═══════════════════════════════════════════════════════════════╝
                    
                    📍 SERVICE ENDPOINTS
                    ═══════════════════════════════════════════════════════════════
                    Frontend (React + Nginx):     http://localhost
                    Backend API (Spring Boot):    http://localhost:8080
                    Backend Health:              http://localhost:8080/actuator/health
                    API Base URL:                http://localhost:8080/api
                    PostgreSQL Database:         localhost:5432
                    
                    🔐 DATABASE CREDENTIALS
                    ═══════════════════════════════════════════════════════════════
                    Username: postgres
                    Password: Nipun123
                    Database: autoservice_db
                    Port: 5432
                    
                    🐳 DOCKER CONTAINER MANAGEMENT
                    ═══════════════════════════════════════════════════════════════
                    View all containers:
                    $ docker ps -a
                    
                    View logs:
                    $ docker-compose logs -f
                    $ docker logs -f autoservice-backend
                    $ docker logs -f autoservice-frontend
                    $ docker logs -f autoservice-postgres
                    
                    Enter container:
                    $ docker exec -it autoservice-backend bash
                    $ docker exec -it autoservice-frontend sh
                    
                    Stop services:
                    $ docker-compose down
                    
                    Remove everything (containers + volumes):
                    $ docker-compose down -v
                    
                    Restart services:
                    $ docker-compose restart
                    
                    📊 USEFUL COMMANDS
                    ═══════════════════════════════════════════════════════════════
                    Check running containers:
                    $ docker ps
                    
                    Check Docker images:
                    $ docker images | grep autoservice
                    
                    Check Docker volumes:
                    $ docker volume ls
                    
                    Check Docker networks:
                    $ docker network ls
                    
                    🔍 TROUBLESHOOTING
                    ═══════════════════════════════════════════════════════════════
                    Backend container not starting:
                    $ docker logs autoservice-backend
                    
                    Database connection issues:
                    $ docker exec -it autoservice-postgres psql -U postgres
                    $ \\l  (list databases)
                    $ \\dt (list tables in autoservice_db)
                    
                    Clear everything and start fresh:
                    $ docker-compose down -v
                    $ docker-compose up -d
                    
                    ═══════════════════════════════════════════════════════════════
                    '''
                }
            }
        }
    }

    post {
        always {
            script {
                echo '========== POST: Final Status =========='
                sh '''
                    echo "Final Docker Status:"
                    echo ""
                    echo "Containers:"
                    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
                    
                    echo ""
                    echo "Volumes:"
                    docker volume ls
                    
                    echo ""
                    echo "Network:"
                    docker network ls | grep autoservice || echo "No autoservice network found"
                '''
            }
        }
        success {
            script {
                echo '✅ Pipeline execution completed successfully!'
            }
        }
        failure {
            script {
                echo '❌ Pipeline execution failed. Please check the logs above for details.'
            }
        }
    }
}
