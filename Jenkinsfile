pipeline {
        agent any
        stages {
            stage('Build') {
                agent { label 'docker' }
                steps {
                    def customImage = docker.build("nginx-lua-app:${env.BUILD_ID}", "./")
                    customImage.push('latest')
                }
            }
            stage('Another test') {
                steps {
                    echo 'Seems work fine. Iam fuckd up'
                }
            }
    }
}