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
        USERNAME = 'toandk'
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
                                    # Tạo folder deploy với timestamp
                                    DEPLOY_DATE=$(date +%Y%m%d_%H%M%S)
                                    DEPLOY_FOLDER="$DEPLOY_PATH/deploy/$DEPLOY_DATE"
                                    
                                    echo "Creating deployment folder: $DEPLOY_FOLDER"
                                    ssh -o StrictHostKeyChecking=no -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "mkdir -p $DEPLOY_FOLDER"
                                    
                                    echo "Copying files to remote server..."
                                    # Copy chỉ những file cần thiết
                                    scp -o StrictHostKeyChecking=no -P $REMOTE_PORT index.html $REMOTE_USER@$REMOTE_HOST:$DEPLOY_FOLDER/
                                    scp -o StrictHostKeyChecking=no -P $REMOTE_PORT 404.html $REMOTE_USER@$REMOTE_HOST:$DEPLOY_FOLDER/
                                    scp -o StrictHostKeyChecking=no -r -P $REMOTE_PORT css/ $REMOTE_USER@$REMOTE_HOST:$DEPLOY_FOLDER/
                                    scp -o StrictHostKeyChecking=no -r -P $REMOTE_PORT js/ $REMOTE_USER@$REMOTE_HOST:$DEPLOY_FOLDER/
                                    scp -o StrictHostKeyChecking=no -r -P $REMOTE_PORT images/ $REMOTE_USER@$REMOTE_HOST:$DEPLOY_FOLDER/
                                    
                                    echo "Creating symlink and cleanup..."
                                    ssh -o StrictHostKeyChecking=no -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST """
                                        cd $DEPLOY_PATH
                                        # Tạo symlink current
                                        ln -sfn deploy/$DEPLOY_DATE current
                                        
                                        # Giữ lại 5 folder gần nhất, xóa các folder cũ
                                        cd deploy
                                        ls -t | tail -n +6 | xargs -r rm -rf
                                        
                                        echo 'Deploy completed successfully!'
                                        ls -la $DEPLOY_PATH/
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
                message: "${USERNAME} deploy ${env.JOB_NAME} #${env.BUILD_NUMBER} successful! ✅\nFirebase: https://${FIREBASE_PROJECT}.web.app\nRemote: http://${REMOTE_HOST}/jenkins/${USERNAME}2/current/"
            )
        }
        failure {
            echo 'Pipeline failed!'
            slackSend(
                channel: '#lnd-2025-workshop',
                color: 'danger',
                tokenCredentialId: 'SLACK_TOKEN',
                message: "${USERNAME} deploy ${env.JOB_NAME} #${env.BUILD_NUMBER} failed! ❌\nCheck logs: ${env.BUILD_URL}"
            )
        }
        always {
            echo 'Pipeline completed!'
        }
    }
}