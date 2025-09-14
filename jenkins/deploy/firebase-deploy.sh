#!/bin/bash

# Firebase Deploy Script for Jenkins CI/CD Pipeline
# Author: Do Khanh Toan
# Description: Deploy application to Firebase Hosting

set -e  # Exit on any error

# Configuration
FIREBASE_PROJECT="toandk-jenkins-workshop2"
FIREBASE_TOKEN=${FIREBASE_TOKEN}

echo "Starting Firebase deployment..."

# Change to application directory
cd web-performance-project1-initial

echo "Current directory: $(pwd)"
echo "Firebase Project: $FIREBASE_PROJECT"

# Create temporary token file
echo "Setting up Firebase authentication..."
export GOOGLE_APPLICATION_CREDENTIALS="/tmp/firebase-token.json"
echo "$FIREBASE_TOKEN" > /tmp/firebase-token.json

# Deploy to Firebase
echo "Deploying to Firebase Hosting..."
firebase deploy --only hosting --project="$FIREBASE_PROJECT" --non-interactive

# Cleanup
echo "Cleaning up temporary files..."
rm -f /tmp/firebase-token.json

echo "✅ Firebase deployment completed successfully!"
echo "🌐 Application URL: https://$FIREBASE_PROJECT.web.app"
