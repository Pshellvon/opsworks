pipeline {
	agent { jenkins-agent }
		stage('Build') {
		    agent { dockerfile true }
			steps {
                node {
                   checkout scm
                   def customImage = docker.build("nginx-lua:${env.BUILD_ID}", "./nginx-lua/Dockerfile")
                	}
				}
			}

		stage('Dockerize') {
			steps {
				echo 'Do something else with docker container'
			}
		}
		stage('Deploy') {
			steps {
				echo 'Now just deploy container and run it.'
			}
		}
	}