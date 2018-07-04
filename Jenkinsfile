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
        }
}