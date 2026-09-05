pipeline {
    agent { label 'linux' }

    stages {
        stage('Environment') {
            steps {
                sh '''
                    echo "Hostname: $(hostname)"
                    echo "User: $(whoami)"
                    echo "Workspace: $(pwd)"
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
                    docker build \
                      -t devops-demo:${BUILD_NUMBER} \
                      .
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

    post {
        success {
            echo 'Pipeline completed successfully'
        }

        failure {
            echo 'Pipeline failed'
        }
    }
}