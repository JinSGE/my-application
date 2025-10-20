pipeline {
    agent any

    environment {
        REGISTRY = "docker.io/sungeun7767"
        IMAGE = "myapp"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/sungeun7767/my-application.git'
            }
        }

        stage('Build & Test') {
            steps {
                sh 'mvn clean test package'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def imageTag = "${REGISTRY}/${IMAGE}:${BUILD_NUMBER}"
                    sh "docker build -t ${imageTag} ."
                    sh "echo ${imageTag} > image_tag.txt"
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([string(credentialsId: 'dockerhub-token', variable: 'DOCKER_HUB_TOKEN')]) {
                    sh 'echo $DOCKER_HUB_TOKEN | docker login -u sungeun7767 --password-stdin'
                    sh 'docker push $(cat image_tag.txt)'
                }
            }
        }

        // master 클러스터에 연결은 kubeconfig를 원격에서 수행
        stage('Update K8s Deployment') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig-master', variable: 'KUBECONFIG')]) {
                    sh '''
                    TAG=$(cat image_tag.txt | cut -d':' -f2)
                    sed -i "s|image: .*|image: ${REGISTRY}/${IMAGE}:${TAG}|" k8s/deployment.yaml
                    git config user.name "jenkins"
                    git config user.email "jenkins@ci"
                    git add k8s/deployment.yaml
                    git commit -m "Update image tag to ${TAG}"
                    git push origin main
                    '''
                }
            }
        }
    }
}

