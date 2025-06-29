pipeline {
    /* ← Mets ici le label du nœud où Docker fonctionne
       (si tu n’en as qu’un seul, mets simplement:  agent any) */
    agent { label 'agent-ssh' }

    parameters {
        string(name: 'PORT', defaultValue: '5000', description: 'Port HTTP exposé')
    }

    stages {

        /* --- 1) On récupère le code --- */
        stage('Checkout') {
            steps {
                checkout scm              // Jenkins clone ton dépôt
            }
        }

        /* --- 2) Petit coup d’œil pour vérifier le contenu --- */
        stage('Diagnostics') {
            steps {
                sh 'ls -al'
                sh 'pwd'
            }
        }

        /* --- 3) Build de l’image Docker --- */
        stage('Build image') {
            steps {
                sh 'docker build -t art_explorer .'   // utilise le Dockerfile présent
            }
            post {
                failure {
                    sh '''
                    curl -H 'Content-Type: application/json' -X POST \
                         -d '{"content":"❌ Build FAILED"}' \
                         https://discord.com/api/webhooks/1387160798354477056/VEaT1V1rhCAtU1fuqxNq3Q8ms2qi2R8auYdEKIkWdBRfVl2y3oNOn6PlFsLVAUklGtJH
                    '''
                }
            }
        }

        /* --- 4) Tests unitaires (optionnels pour commencer) --- */
        stage('Unit tests') {
            steps {
                sh 'docker run --entrypoint=ash art_explorer -c "python -m pytest"'
            }
        }

        /* --- 5) Couverture (optionnel) --- */
        stage('Coverage') {
            steps {
                sh 'docker run --entrypoint=ash art_explorer -c "coverage run -m pytest && coverage report"'
            }
        }

        /* --- 6) Lancement local pour vérif rapide --- */
        stage('Run app') {
            steps {
                sh '''
                   docker rm -f art_explorer || true
                   docker run -d --name art_explorer \
                              -p ${PORT}:8000 \
                              art_explorer
                '''
            }
        }
    }
}