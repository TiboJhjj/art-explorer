pipeline {
    agent { label 'agent-ssh' }

    parameters {
        string(name: 'PORT', defaultValue: '8000', description: 'Port exposé vers l’hôte')
    }

    environment {
        IMAGE_NAME      = 'art_explorer'
        CONTAINER_NAME  = 'art_explorer'
        REMOTE_HOST     = 'tibo@192.168.45.130'
        SSH_CRED_ID     = 'ssh-agent-key'
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Build Docker image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:latest ."
                }
            }
        }

        stage('Unit tests + coverage') {
            steps {
                script {
                    sh '''
                        docker run --rm --entrypoint=sh ${IMAGE_NAME}:latest \
                          -c "python -m coverage run -m pytest && \
                              python -m coverage report -m"
                    '''
                }
            }
        }

        stage('Deploy to VM') {
            steps {
                sshagent(credentials: [SSH_CRED_ID]) {
                    sh """
                      ssh -o StrictHostKeyChecking=no ${REMOTE_HOST} '
                        docker pull ${IMAGE_NAME}:latest || true ;
                        docker stop ${CONTAINER_NAME} || true ;
                        docker rm   ${CONTAINER_NAME} || true ;
                        docker run -d --name ${CONTAINER_NAME} \\
                                    -p 80:${params.PORT} \\
                                    --restart=always ${IMAGE_NAME}:latest
                      '
                    """
                }
            }
        }
    }

    post {
        failure {
            // webhook Discord (ou Slack/Mail)
            sh '''
              curl -H "Content-Type: application/json" \
                   -X POST \
                   -d "{\"content\":\"❌ Build ${BUILD_NUMBER} failed for ${IMAGE_NAME}\"}" \
                   https://discord.com/api/webhooks/XXXXXXXX/YYYYYYYY
            '''
        }
    }
}