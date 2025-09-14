#!/bin/bash

# Test script for Jenkins CI/CD Pipeline
# Author: Do Khanh Toan
# Description: Run lint and tests for web application

set -e  # Exit on any error

echo "Starting test phase..."

# Change to application directory
cd web-performance-project1-initial

echo "Installing dependencies..."
npm install

echo "Running lint and tests..."
npm run test:ci

echo "✅ Test phase completed successfully!"
