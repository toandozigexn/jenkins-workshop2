pipeline {
    agent any
    
    tools {
        nodejs 'NodeJS-20'
    }
    
    environment {
        FIREBASE_TOKEN = credentials('FIREBASE_TOKEN')
        FIREBASE_PROJECT = 'toandk-workshop2'
        REMOTE_USER = 'newbie'
        REMOTE_HOST = '118.69.34.46'
        REMOTE_PORT = '3334'
        DEPLOY_PATH = '/usr/share/nginx/html/jenkins/toandk2'
        
        // Dynamic variables
        DEPLOY_TIME = sh(script: 'date "+%Y-%m-%d %H:%M:%S"', returnStdout: true).trim()
        DEPLOY_DATE = sh(script: 'date "+%Y%m%d_%H%M%S"', returnStdout: true).trim()
        GIT_AUTHOR = sh(script: 'git log -1 --pretty=format:"%an"', returnStdout: true).trim()
        GIT_COMMIT_MSG = sh(script: 'git log -1 --pretty=format:"%s"', returnStdout: true).trim()
        FIREBASE_URL = "https://${FIREBASE_PROJECT}.web.app"
        REMOTE_URL = "http://${REMOTE_HOST}/jenkins/toandk2/current/"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                echo 'Building application...'
                dir('web-performance-project1-initial') {
                    sh 'npm install'
                }
            }
        }
        
        stage('Lint/Test') {
            steps {
                echo 'Running lint and tests...'
                dir('web-performance-project1-initial') {
                    sh 'npm run test:ci'
                }
            }
        }
        
        stage('Deploy') {
            parallel {
                stage('Deploy to Firebase') {
                    steps {
                        echo 'Deploying to Firebase...'
                        dir('web-performance-project1-initial') {
                            sh '''
                                echo "Deploying to Firebase Hosting..."
                                firebase deploy --token "$FIREBASE_TOKEN" --only hosting --project="$FIREBASE_PROJECT" --non-interactive
                            '''
                        }
                    }
                }
                
                stage('Deploy to Remote Server') {
                    steps {
                        echo 'Deploying to Remote Server...'
                        dir('web-performance-project1-initial') {
                            sshagent(['SSH_PRIVATE_KEY']) {
                                sh '''
                                    DEPLOY_FOLDER="$DEPLOY_PATH/deploy/$DEPLOY_DATE"
                                    
                                    echo "Creating deployment folder: $DEPLOY_FOLDER"
                                    ssh -o StrictHostKeyChecking=no -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "mkdir -p $DEPLOY_FOLDER"
                                    
                                    echo "Copying essential files to remote server..."
                                    # Sử dụng rsync để copy chỉ files cần thiết
                                    rsync -avz --delete \
                                        --include="index.html" \
                                        --include="404.html" \
                                        --include="css/" \
                                        --include="css/**" \
                                        --include="js/" \
                                        --include="js/**" \
                                        --include="images/" \
                                        --include="images/**" \
                                        --exclude="*" \
                                        -e "ssh -o StrictHostKeyChecking=no -p $REMOTE_PORT" \
                                        ./ $REMOTE_USER@$REMOTE_HOST:$DEPLOY_FOLDER/
                                    
                                    echo "Creating symlink and cleanup..."
                                    ssh -o StrictHostKeyChecking=no -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST """
                                        cd $DEPLOY_PATH
                                        
                                        # Tạo symlink current
                                        ln -sfn deploy/$DEPLOY_DATE current
                                        
                                        # Giữ lại 5 folder gần nhất, xóa các folder cũ
                                        cd deploy
                                        ls -t | tail -n +6 | xargs -r rm -rf
                                        
                                        echo 'Deploy completed successfully at: $DEPLOY_TIME'
                                        echo 'Files deployed:'
                                        ls -la $DEPLOY_PATH/current/
                                    """
                                '''
                            }
                        }
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline succeeded!'
            slackSend(
                channel: '#lnd-2025-workshop',
                color: 'good',
                tokenCredentialId: 'SLACK_TOKEN',
                message: """*✅ Deployment Successful!*
*Developer:* ${GIT_AUTHOR}
*Commit:* ${GIT_COMMIT_MSG}
*Job:* ${env.JOB_NAME} #${env.BUILD_NUMBER}
*Time:* ${DEPLOY_TIME}

*Links:*
• Firebase: ${FIREBASE_URL}
• Remote Server: ${REMOTE_URL}
• Build Logs: ${env.BUILD_URL}"""
            )
        }
        failure {
            echo 'Pipeline failed!'
            slackSend(
                channel: '#lnd-2025-workshop',
                color: 'danger',
                tokenCredentialId: 'SLACK_TOKEN',
                message: """*❌ Deployment Failed!*
*Developer:* ${GIT_AUTHOR}
*Commit:* ${GIT_COMMIT_MSG}
*Job:* ${env.JOB_NAME} #${env.BUILD_NUMBER}
*Time:* ${DEPLOY_TIME}
*Check Logs:* ${env.BUILD_URL}"""
            )
        }
        always {
            echo 'Pipeline completed!'
        }
    }
}