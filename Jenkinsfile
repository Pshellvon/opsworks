pipeline {
        agent { dockerfile true }
        stages {
            stage('Push to repo') {
                agent { label 'docker' }
                steps {
                    script {
                        docker.withRegistry('https://hub.docker.com', 'credentials-id') {
                        push()
                        }
                    }
                }
            }
        }
}