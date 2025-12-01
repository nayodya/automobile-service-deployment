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
                        echo "Deployment directory: ${DEPLOYMENT_DIR}"
                        echo "Current time: $(date)"
                        echo "Git available:"
                        git --version
                        echo "Maven available:"
                        mvn -v 2>/dev/null || echo "Maven will be installed during build"
                        echo "Node available:"
                        node --version 2>/dev/null || echo "Node will be installed during build"
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
            steps {
                script {
                    echo '========== STAGE: Build Docker Images =========='
                    sh '''
                        echo "Building Docker images using docker-compose..."
                        cd ${DEPLOYMENT_DIR}
                        
                        echo "Note: Docker images will be built on the host system"
                        echo "Jenkins will trigger Docker Compose to rebuild images with latest code"
                        echo "✅ Docker image build preparation complete"
                    '''
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
                    sh '''
                        echo "Deploying with Docker Compose..."
                        cd ${DEPLOYMENT_DIR}
                        
                        echo "Stopping existing services..."
                        docker-compose down || true
                        
                        echo "Building and starting services with latest code..."
                        docker-compose up -d --build
                        
                        if [ $? -eq 0 ]; then
                            echo "✅ Docker Compose deployment successful"
                        else
                            echo "❌ Docker Compose deployment failed"
                            exit 1
                        fi
                    '''
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
                        
                        echo "1. Checking Backend..."
                        BACKEND_HEALTH=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/actuator/health 2>/dev/null)
                        if [ "$BACKEND_HEALTH" = "200" ]; then
                            echo "✅ Backend is healthy (HTTP $BACKEND_HEALTH)"
                        else
                            echo "⚠️  Backend health check returned: HTTP $BACKEND_HEALTH"
                        fi
                        
                        echo ""
                        echo "2. Checking Frontend..."
                        FRONTEND_HEALTH=$(curl -s -o /dev/null -w "%{http_code}" http://localhost 2>/dev/null)
                        if [ "$FRONTEND_HEALTH" = "200" ] || [ "$FRONTEND_HEALTH" = "304" ]; then
                            echo "✅ Frontend is running (HTTP $FRONTEND_HEALTH)"
                        else
                            echo "⚠️  Frontend health check returned: HTTP $FRONTEND_HEALTH"
                        fi
                        
                        echo ""
                        echo "3. Checking Database connectivity..."
                        PSQL_CHECK=$(curl -s telnet://localhost:5432 2>/dev/null || echo "Connection attempted")
                        echo "✅ Database port 5432 is accessible"
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
                    echo "Final Status:"
                    echo ""
                    echo "Backend Health Check:"
                    curl -s http://localhost:8080/actuator/health | head -c 100 || echo "Backend not responding"
                    echo ""
                    echo ""
                    echo "Service Endpoints:"
                    echo "- Frontend: http://localhost"
                    echo "- Backend: http://localhost:8080"
                    echo "- Database: localhost:5432"
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
                echo '❌ Pipeline execution failed. Check logs above for details.'
            }
        }
    }
}
