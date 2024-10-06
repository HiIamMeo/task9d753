pipeline {
    agent any

    tools { 
        nodejs "default-nodejs"
        "org.jenkinsci.plugins.docker.commons.tools.DockerTool" "default-docker"
    }
    
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerHub')
        registry = "879381259188.dkr.ecr.ap-southeast-2.amazonaws.com/daniel/task9d753"
    }

    stages {
        stage("Checkout") {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh "docker build --platform linux/amd64 -t task9d753:latest ."
                sh "docker tag task9d753:latest ${registry}:${env.BUILD_NUMBER}"
                // sh "docker build -t task9d753:${env.BUILD_NUMBER} ."
            }
        }

        stage("Test") {
            steps {
                sh "npm install"
                sh "npm test"
            }
        }

        stage('Deploy') {
            steps {
                script {
                    echo 'Deploying to Docker container...'
                    
                    // Remove old container if exists
                    sh "docker stop task9d753 || true"
                    sh "docker rm task9d753 || true"

                    // Run a new container with your app
                    sh "docker run -d --name task9d753 --platform linux/amd64 -p 7777:3000 ${registry}:${env.BUILD_NUMBER}"
                }
            }
        }

        stage('Analysis') {
            steps {
                script {
                    def scannerHome = tool 'default-sonar-scanner'
                    withSonarQubeEnv() {
                        sh "${scannerHome}/bin/sonar-scanner"
                    }
                    // withSonarQubeEnv(installationName: 'sq') {
                    //     sh "mvn sonar:sonar"
                    //     sh './mvnw clean org.sonarsource.scanner.maven:sonar-maven-plugin:3.9.0.2155:sonar'
                    // }
                }
            }
        }

        stage("Pre-Release") {
            steps {
                script {
                    // sh "docker login -u AWS -p $(aws ecr get-login-password --region ap-southeast-2) 879381259188.dkr.ecr.ap-southeast-2.amazonaws.com"
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws1']]) {
                        sh "aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin 879381259188.dkr.ecr.ap-southeast-2.amazonaws.com"
                    }
                    sh "docker push ${registry}:${env.BUILD_NUMBER}"
                }
            }
        }
        
        stage('Release') {
            steps {
                script {
                    def docker_stop = "docker stop task9d753 || true"
                    def docker_clean = "docker rm task9d753 || true"
                    def kickoff = "docker run -d -p 7777:3000 --platform linux/amd64 --rm --name task9d753 ${registry}:${env.BUILD_NUMBER}"
                    def test1 = "pwd"
                    def test2 = "docker version"
                    sshagent(['3.24.232.174']) {
                        sh "ssh -o StrictHostKeyChecking=no ubuntu@3.24.232.174 ${docker_stop}"
                        sh "ssh -o StrictHostKeyChecking=no ubuntu@3.24.232.174 ${docker_clean}"
                        sh "ssh -o StrictHostKeyChecking=no ubuntu@3.24.232.174 ${kickoff}"
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline execution finished. Build Number: ${env.BUILD_NUMBER}"
        }
        success {
            echo "Pipeline succeeded."
        }
        failure {
            echo "Pipeline failed."
        }
    }
}