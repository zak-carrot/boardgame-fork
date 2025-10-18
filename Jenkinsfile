pipeline {
    agent any
    tools { maven 'mvn' }
    environment {
        DOCKERHUB_CREDENTIALS = "docker_hub_cred" // Jenkins credentials ID
        DOCKERHUB_REPO = "jayu3110/boardgame-listing"
        IMAGE_NAME = "boardgame-listing"
        AWS_CREDS = credentials('aws_access_key')
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/JK00119500/boardgame.git'
            }
        }

        stage('Build & Test') {
            steps {
                sh 'mvn --version && java --version && chmod +x ./mvnw && mvn -N wrapper:wrapper && ./mvnw clean package'
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

         stage('Deploy to AWS eks') {
             steps {
                 withEnv([
                     "AWS_ACCESS_KEY_ID=${AWS_CREDS_USR}",
                     "AWS_SECRET_ACCESS_KEY=${AWS_CREDS_PSW}",
                     "AWS_DEFAULT_REGION=ap-south-1"
                 ]) {
                 dir('terraform') {
                     sh '''
                     terraform init -input=false
                     terraform apply -auto-approve -input=false
                     '''
                     }
                 }
             }
         }
         stage('Update Kubeconfig') {
             steps {
                 withEnv([
                     "AWS_ACCESS_KEY_ID=${AWS_CREDS_USR}",
                     "AWS_SECRET_ACCESS_KEY=${AWS_CREDS_PSW}",
                     "AWS_DEFAULT_REGION=ap-south-1"
                 ]) {
                 sh '''
                 echo "Updating kubeconfig for EKS cluster..."
                 aws eks update-kubeconfig \
                     --region ap-south-1 \
                     --name boardgame
                 '''
                 }
            }
        } 
        stage('Deploy App to K8s') {
            steps {
                sh '''
                kubectl apply -f terraform/deployment.yaml --validate=false
                kubectl apply -f terraform/service.yaml --validate=false
                '''
            }
        }

    }

    post {
        //always {
            //echo "Cleaning up workspace..."
            //cleanWs()
        //}
        success {
            echo "✅ Deployment successful!"
        }
        failure {
            echo "❌ Deployment failed. Check Jenkins logs."
        }
    }
}
