pipeline {
    agent { label 'linux' }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

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