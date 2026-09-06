pipeline {
    agent { label 'linux' }

    stages {
        stage('Environment') {
            steps {
                sh '''
                    echo "=== BUILD ENVIRONMENT ==="
                    echo "Hostname: $(hostname)"
                    echo "User: $(whoami)"
                    echo "Workspace: $(pwd)"
                    echo "Build number: $BUILD_NUMBER"
                    echo "Job name: $JOB_NAME"
                '''
            }
        }

        stage('Tool Check') {
            steps {
                sh '''
                    java -version
                    git --version
                    docker --version
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    IMAGE_NAME=devops-demo
                    GIT_SHORT=$(git rev-parse --short HEAD)

                    docker build \
                      -t ${IMAGE_NAME}:${BUILD_NUMBER} \
                      -t ${IMAGE_NAME}:${GIT_SHORT} \
                      .
                '''
            }
        }

        stage('Unit Test') {
            steps {
                sh '''
                    docker run --rm \
                      devops-demo:${BUILD_NUMBER} \
                      pytest tests -v
                '''
            }
        }

        stage('Verify Image') {
            steps {
                sh '''
                    docker images devops-demo
                '''
            }
        }

        stage('Smoke Test') {
            steps {
                sh '''
                    set -e

                    docker rm -f devops-demo-test 2>/dev/null || true

                    cleanup() {
                        docker logs devops-demo-test || true
                        docker rm -f devops-demo-test || true
                    }

                    trap cleanup EXIT

                    docker run -d \
                      --name devops-demo-test \
                      -p 18080:8080 \
                      devops-demo:${BUILD_NUMBER}

                    sleep 3

                    curl -f http://127.0.0.1:18080/health
                '''
            }
        }

        stage('Push Image') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKERHUB_USER',
                        passwordVariable: 'DOCKERHUB_TOKEN'
                    )
                ]) {
                    sh '''
                        GIT_SHORT=$(git rev-parse --short HEAD)

                        echo "$DOCKERHUB_TOKEN" | \
                            docker login -u "$DOCKERHUB_USER" \
                            --password-stdin

                        docker tag \
                            devops-demo:${BUILD_NUMBER} \
                            ${DOCKERHUB_USER}/devops-demo:${BUILD_NUMBER}

                        docker tag \
                            devops-demo:${BUILD_NUMBER} \
                            ${DOCKERHUB_USER}/devops-demo:${GIT_SHORT}

                        docker push \
                            ${DOCKERHUB_USER}/devops-demo:${BUILD_NUMBER}

                        docker push \
                            ${DOCKERHUB_USER}/devops-demo:${GIT_SHORT}

                        docker logout
                    '''
                }
            }
        }

        stage('Deploy to app01') {
            steps {
                sshagent(credentials: ['app01-deploy']) {
                    sh '''
                        GIT_SHORT=$(git rev-parse --short HEAD)

                        ssh -o StrictHostKeyChecking=no deploy@192.168.57.20 \
                        "/opt/devops-demo/deploy.sh tambovman/devops-demo:${GIT_SHORT}"
                    '''
                }
            }
        }

        stage('Deployment Health Check') {
            steps {
                sh '''
                    sleep 3
                    curl -f http://192.168.57.20:8080/health
                '''
            }
        }

    }

    post {
        success {
            echo 'Pipeline completed successfully'
        }

        failure {
            echo 'Pipeline failed'
        }
    }
}