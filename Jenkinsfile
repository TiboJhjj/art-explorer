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
        stage('Checkout') { steps { checkout scm } }

        stage('Build Docker image') {
            steps { sh "docker build -t ${IMAGE_NAME}:latest ." }
        }

        stage('Unit tests + coverage') {
            steps {
                sh '''
                  docker run --rm --entrypoint=sh ${IMAGE_NAME}:latest \
                    -c "python -m coverage run -m pytest && \
                        python -m coverage report -m"
                '''
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
            // e-mail via Gmail
            emailext(
                subject: "❌ Build ${env.JOB_NAME} #${env.BUILD_NUMBER} FAILED",
                body: """\
Le build ${env.BUILD_NUMBER} du job *${env.JOB_NAME}* a échoué.

Console : ${env.BUILD_URL}console
Logs complets en pièce jointe.
""",
                to: "${RECIPIENTS}",
                attachLog: true,
                mimeType: 'text/plain',
                replyTo: "${RECIPIENTS}",
                recipientProviders: [],
                charset: 'UTF-8',
                compressLog: true,
                credentialsId: "${GMAIL_CREDS_ID}"
            )
        }
    }
}