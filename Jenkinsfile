pipeline {
    agent any

    tools {   
        maven 'Maven3'
        jdk 'JDK11'
    }

    environment {
        DOCKERHUB_CREDENTIALS = "docker_hub_cred" // Jenkins credentials ID
        DOCKERHUB_REPO = "jayu3110/boardgame-listing"
        IMAGE_NAME = "boardgame-listing"
        SONARQUBE_ENV = 'MySonarQubeServer' 
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/JK00119500/boardgame.git'
            }
        }

        stage('Build') {
            steps {
                sh '''
                mvn clean install -DSkipTests
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "pwd"
                sh "ls -lrt"
                sh "docker build -t ${IMAGE_NAME}:latest ."
                sh "ls -lrt target"
                sh "docker tag ${IMAGE_NAME}:latest ${DOCKERHUB_REPO}:latest"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIALS}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker push ${DOCKERHUB_REPO}:latest
                    '''
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE_ENV}") {
                    // sh 'mvn sonar:sonar'
                    sh "mvn clean verify sonar:sonar -Dsonar.projectKey=Boardgame -Dsonar.projectName='Boardgame'"
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    timeout(time: 1, unit: 'HOURS') {
                        waitForQualityGate abortPipeline: true
                    }
                }
            }
        }
        stage('OWASP Dependency-Check Vulnerabilities') {
            steps {
            dependencyCheck additionalArguments: ''' 
                    -o './'
                    -s './'
                    -f 'ALL' 
                    --prettyPrint''', odcInstallation: 'owasp-DC'
            dependencyCheckPublisher pattern: 'dependency-check-report.xml'
                
            }
            
        }
    }
}
