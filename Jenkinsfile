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