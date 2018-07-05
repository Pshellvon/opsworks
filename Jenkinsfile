pipeline {
        agent { node { label 'docker' } }
        stages {
            stage('Build image') {
                agent { label 'docker' }

                steps {
                    script {
                        docker.build("nood/opsapp:latest")
                    }
                }
            }

            stage('Push to repo') {
                agent { label 'docker' }
                steps {
                    script {
                        docker.withRegistry('', 'docker-hub-credentials') {
                        sh 'docker push nood/opsapp:latest'
                        }
                    }
                }
            }

            stage('Deploy') {
                agent { label 'docker' }
                environment {
                   AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
                   AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
                }

                steps {
                    script {
                        sh 'chmod +x ./controls/deploy.sh'
                        sh './controls/deploy.sh ${AWS_ACCESS_KEY_ID} ${AWS_SECRET_ACCESS_KEY}'
                        }
                    }
                }
            }
        }
