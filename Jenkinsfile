pipeline {
    agent any
    
    tools {
        nodejs 'NodeJS-20'
    }
    
    parameters {
        string(name: 'FIREBASE_PROJECT', defaultValue: 'toandk-jenkins-workshop2', description: 'Firebase Project ID')
        string(name: 'REMOTE_USER', defaultValue: 'newbie', description: 'Remote Server Username')
        string(name: 'REMOTE_HOST', defaultValue: '118.69.34.46', description: 'Remote Server IP Address')
        string(name: 'REMOTE_PORT', defaultValue: '3334', description: 'Remote Server SSH Port')
        string(name: 'DEPLOY_PATH', defaultValue: '/usr/share/nginx/html/jenkins/toandk2', description: 'Remote Server Deploy Path')
    }
    
    environment {
        // Credentials
        FIREBASE_TOKEN = credentials('FIREBASE_TOKEN')
        
        // Environment variables
        FIREBASE_PROJECT = "${params.FIREBASE_PROJECT}"
        REMOTE_USER = "${params.REMOTE_USER}"
        REMOTE_HOST = "${params.REMOTE_HOST}"
        REMOTE_PORT = "${params.REMOTE_PORT}"
        DEPLOY_PATH = "${params.DEPLOY_PATH}"
        
        // Dynamic variables 
        DEPLOY_TIME = sh(script: 'date "+%Y-%m-%d %H:%M:%S"', returnStdout: true).trim()
        DEPLOY_DATE = sh(script: 'date "+%Y%m%d_%H%M%S"', returnStdout: true).trim()
        GIT_AUTHOR = sh(script: 'git log -1 --pretty=format:"%an"', returnStdout: true).trim()
        GIT_COMMIT_MSG = sh(script: 'git log -1 --pretty=format:"%s"', returnStdout: true).trim()
        
        // Dynamic URLs
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
                                # Sử dụng token với GOOGLE_APPLICATION_CREDENTIALS
                                export GOOGLE_APPLICATION_CREDENTIALS="/tmp/firebase-token.json"
                                echo "$FIREBASE_TOKEN" > /tmp/firebase-token.json
                                firebase deploy --only hosting --project="$FIREBASE_PROJECT" --non-interactive
                                rm -f /tmp/firebase-token.json
                            '''
                        }
                    }
                }
                
                stage('Deploy to Remote Server') {
                    steps {
                        echo 'Deploying to Remote Server...'
                        dir('web-performance-project1-initial') {
                            sh '''
                                DEPLOY_FOLDER="$DEPLOY_PATH/deploy/$DEPLOY_DATE"
                                
                                echo "Creating deployment folder: $DEPLOY_FOLDER"
                                ssh -i /var/jenkins_home/.ssh/id_rsa -o StrictHostKeyChecking=no -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "mkdir -p $DEPLOY_FOLDER"
                                
                                echo "Copying essential files to remote server..."
                                # Sử dụng scp để copy files cần thiết
                                scp -i /var/jenkins_home/.ssh/id_rsa -o StrictHostKeyChecking=no -P $REMOTE_PORT index.html $REMOTE_USER@$REMOTE_HOST:$DEPLOY_FOLDER/
                                scp -i /var/jenkins_home/.ssh/id_rsa -o StrictHostKeyChecking=no -P $REMOTE_PORT 404.html $REMOTE_USER@$REMOTE_HOST:$DEPLOY_FOLDER/ 2>/dev/null || true
                                scp -i /var/jenkins_home/.ssh/id_rsa -o StrictHostKeyChecking=no -P $REMOTE_PORT -r css/ $REMOTE_USER@$REMOTE_HOST:$DEPLOY_FOLDER/ 2>/dev/null || true
                                scp -i /var/jenkins_home/.ssh/id_rsa -o StrictHostKeyChecking=no -P $REMOTE_PORT -r js/ $REMOTE_USER@$REMOTE_HOST:$DEPLOY_FOLDER/ 2>/dev/null || true
                                scp -i /var/jenkins_home/.ssh/id_rsa -o StrictHostKeyChecking=no -P $REMOTE_PORT -r images/ $REMOTE_USER@$REMOTE_HOST:$DEPLOY_FOLDER/ 2>/dev/null || true
                                
                                echo "Creating symlink and cleanup..."
                                ssh -i /var/jenkins_home/.ssh/id_rsa -o StrictHostKeyChecking=no -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST """
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
    
    post {
        success {
            echo 'Pipeline succeeded!'
            echo "✅ Deployment Successful!"
            echo "Author: ${GIT_AUTHOR}"
            echo "Commit: ${GIT_COMMIT_MSG}"
            echo "Job: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
            echo "Time: ${DEPLOY_TIME}"
            echo "Firebase: ${FIREBASE_URL}"
            echo "Remote Server: ${REMOTE_URL}"
            echo "Build Logs: ${env.BUILD_URL}"
            
            // Slack notification - temporarily disabled
            /*
            slackSend(
                channel: '#lnd-2025-workshop',
                color: 'good',
                tokenCredentialId: 'SLACK_TOKEN',
                message: """*✅ Deployment Successful!*
*Author:* ${GIT_AUTHOR}
*Commit:* ${GIT_COMMIT_MSG}
*Job:* ${env.JOB_NAME} #${env.BUILD_NUMBER}
*Time:* ${DEPLOY_TIME}

*Links:*
• Firebase: ${FIREBASE_URL}
• Remote Server: ${REMOTE_URL}
• Build Logs: ${env.BUILD_URL}"""
            )
            */
        }
        failure {
            echo 'Pipeline failed!'
            echo "❌ Deployment Failed!"
            echo "Author: ${GIT_AUTHOR}"
            echo "Commit: ${GIT_COMMIT_MSG}"
            echo "Job: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
            echo "Time: ${DEPLOY_TIME}"
            echo "Check Logs: ${env.BUILD_URL}"
            
            // Slack notification - temporarily disabled
            /*
            slackSend(
                channel: '#lnd-2025-workshop',
                color: 'danger',
                tokenCredentialId: 'SLACK_TOKEN',
                message: """*❌ Deployment Failed!*
*Author:* ${GIT_AUTHOR}
*Commit:* ${GIT_COMMIT_MSG}
*Job:* ${env.JOB_NAME} #${env.BUILD_NUMBER}
*Time:* ${DEPLOY_TIME}
*Check Logs:* ${env.BUILD_URL}"""
            )
            */
        }
        always {
            echo 'Pipeline completed!'
        }
    }
}