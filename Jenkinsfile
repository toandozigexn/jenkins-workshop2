pipeline {
    agent any
    
    tools {
        nodejs 'NodeJS-20'
    }
    
    environment {
        // Credentials
        FIREBASE_TOKEN = credentials('FIREBASE_TOKEN')
        
        // Configuration
        FIREBASE_PROJECT = 'toandk-jenkins-workshop2'
        
        // Dynamic variables for notifications
        DEPLOY_TIME = sh(script: 'date "+%Y-%m-%d %H:%M:%S"', returnStdout: true).trim()
        GIT_AUTHOR = sh(script: 'git log -1 --pretty=format:"%an"', returnStdout: true).trim()
        GIT_COMMIT_MSG = sh(script: 'git log -1 --pretty=format:"%s"', returnStdout: true).trim()
        
        // URLs
        FIREBASE_URL = "https://${FIREBASE_PROJECT}.web.app"
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
                sh 'bash jenkins/build/build.sh'
            }
        }
        
        stage('Lint/Test') {
            steps {
                echo 'Running lint and tests...'
                sh 'bash jenkins/test/test.sh'
            }
        }
        
        stage('Deploy') {
            parallel {
                stage('Deploy to Firebase') {
                    steps {
                        echo 'Deploying to Firebase...'
                        sh 'bash jenkins/deploy/firebase-deploy.sh'
                    }
                }
                
                stage('Deploy to Remote Server') {
                    steps {
                        echo 'Deploying to Remote Server...'
                        sh 'bash jenkins/deploy/remote-deploy.sh'
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