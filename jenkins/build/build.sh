#!/bin/bash

# Build Script for Jenkins CI/CD Pipeline
# Author: Do Khanh Toan
# Description: Build the web application

set -e  # Exit on any error

echo "Starting build phase..."

# Change to application directory
cd web-performance-project1-initial

echo "Current directory: $(pwd)"

echo "Installing dependencies..."
npm install

echo "✅ Build phase completed successfully!"
