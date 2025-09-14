#!/bin/bash

# Remote Server Deploy Script for Jenkins CI/CD Pipeline
# Author: Do Khanh Toan
# Description: Deploy application to remote server via SSH

set -e  # Exit on any error

# Configuration
REMOTE_USER="newbie"
REMOTE_HOST="118.69.34.46"
REMOTE_PORT="3334"
DEPLOY_PATH="/usr/share/nginx/html/jenkins/toandk2"
DEPLOY_DATE=$(date "+%Y%m%d_%H%M%S")

echo "Starting remote server deployment..."

# Change to application directory
cd web-performance-project1-initial

echo "Current directory: $(pwd)"
echo "Target server: $REMOTE_USER@$REMOTE_HOST:$REMOTE_PORT"
echo "Deploy path: $DEPLOY_PATH"

# Create deployment folder
DEPLOY_FOLDER="$DEPLOY_PATH/deploy/$DEPLOY_DATE"
echo "Creating deployment folder: $DEPLOY_FOLDER"

ssh -i /var/jenkins_home/.ssh/id_rsa -o StrictHostKeyChecking=no -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "mkdir -p $DEPLOY_FOLDER"

# Copy essential files
echo "Copying essential files to remote server..."

# Copy index.html
echo "  Copying index.html..."
scp -i /var/jenkins_home/.ssh/id_rsa -o StrictHostKeyChecking=no -P $REMOTE_PORT index.html $REMOTE_USER@$REMOTE_HOST:$DEPLOY_FOLDER/

# Copy 404.html (if exists)
echo "  Copying 404.html..."
scp -i /var/jenkins_home/.ssh/id_rsa -o StrictHostKeyChecking=no -P $REMOTE_PORT 404.html $REMOTE_USER@$REMOTE_HOST:$DEPLOY_FOLDER/ 2>/dev/null || echo "  404.html not found, skipping..."

# Copy CSS folder (if exists)
echo "  Copying CSS folder..."
scp -i /var/jenkins_home/.ssh/id_rsa -o StrictHostKeyChecking=no -P $REMOTE_PORT -r css/ $REMOTE_USER@$REMOTE_HOST:$DEPLOY_FOLDER/ 2>/dev/null || echo "  CSS folder not found, skipping..."

# Copy JS folder (if exists)
echo "  Copying JS folder..."
scp -i /var/jenkins_home/.ssh/id_rsa -o StrictHostKeyChecking=no -P $REMOTE_PORT -r js/ $REMOTE_USER@$REMOTE_HOST:$DEPLOY_FOLDER/ 2>/dev/null || echo "  JS folder not found, skipping..."

# Copy Images folder (if exists)
echo "  Copying Images folder..."
scp -i /var/jenkins_home/.ssh/id_rsa -o StrictHostKeyChecking=no -P $REMOTE_PORT -r images/ $REMOTE_USER@$REMOTE_HOST:$DEPLOY_FOLDER/ 2>/dev/null || echo "  Images folder not found, skipping..."

# Create symlink and cleanup
echo "Creating symlink and cleanup..."
ssh -i /var/jenkins_home/.ssh/id_rsa -o StrictHostKeyChecking=no -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "
    cd $DEPLOY_PATH
    
    # Create symlink current
    echo 'Creating symlink: current -> deploy/$DEPLOY_DATE'
    ln -sfn deploy/$DEPLOY_DATE current
    
    # Keep only 5 recent folders, remove old ones
    echo 'Cleaning up old deployments...'
    cd deploy
    ls -t | tail -n +6 | xargs -r rm -rf
    
    echo 'Deploy completed successfully!'
    echo 'Files deployed:'
    ls -la $DEPLOY_PATH/current/
"

echo "✅ Remote server deployment completed successfully!"
echo "🌐 Application URL: http://$REMOTE_HOST/jenkins/toandk2/current/"
