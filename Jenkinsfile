pipeline {
    agent any

    environment {
        REGISTRY = "docker.io/sungeun7767"
        IMAGE = "myapp"
        GIT_REPO_URL = "https://github.com/JinSGE/my-application.git" 
    }
	
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/JinSGE/my-application.git'
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

        stage('Update K8s Manifest (GitOps Push)') {
            steps {
                withCredentials([string(credentialsId: 'github-token', variable: 'GIT_TOKEN')]) {
                    sh ''' 
                    TAG=$(cat image_tag.txt | cut -d':' -f2)
                    
                    # 1. deployment.yaml 파일 수정
                    sed -i "s|image: .*|image: ${REGISTRY}/${IMAGE}:${TAG}|" k8s/deployment.yaml
                    
                    # 2. Git 사용자 설정
                    git config user.name "jenkins-bot"
                    git config user.email "jenkins-bot@example.com"
                    
                    # 3. Git Add, Commit
                    git add k8s/deployment.yaml
                    git commit -m "Update image tag to ${TAG} [CI]"
                    
                    # 4. GitHub에 인증하여 Push (가장 중요)
                    # (git push origin main 대신 아래 명령어를 사용)
                    git push https://${GIT_TOKEN}@github.com/JinSGE/my-application.git HEAD:main
                    '''
                }
        }
    }
}

