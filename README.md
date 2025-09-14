# Jenkins CI/CD Workshop 2

A comprehensive Jenkins CI/CD pipeline that automatically builds, tests, and deploys a web application to both Firebase Hosting and a remote CentOS server.

## 🚀 Features

- **Automated CI/CD Pipeline**: Triggers on every push to `main` branch
- **Multi-Platform Deployment**: Deploy to Firebase Hosting and remote server simultaneously
- **Code Quality Checks**: ESLint linting and automated testing
- **Modular Architecture**: Separated build, test, and deploy scripts
- **Slack Notifications**: Real-time deployment status updates
- **Version Management**: Timestamped deployments with automatic cleanup

## 📁 Project Structure

```
jenkins-workshop2/
├── web-performance-project1-initial/    # Web application source code
│   ├── index.html                       # Main HTML file
│   ├── css/                            # Stylesheets
│   ├── js/                             # JavaScript files
│   ├── images/                         # Image assets
│   ├── package.json                    # Node.js dependencies
│   └── firebase.json                   # Firebase configuration
├── jenkins/                            # CI/CD scripts (not pushed to repo)
│   ├── build/
│   │   └── build.sh                    # Build script
│   ├── test/
│   │   └── test.sh                     # Test script
│   └── deploy/
│       ├── firebase-deploy.sh          # Firebase deployment
│       └── remote-deploy.sh            # Remote server deployment
├── Jenkinsfile                         # Main pipeline definition
├── docker-compose.yml                  # Jenkins container setup
├── Dockerfile                          # Jenkins image configuration
└── plugins.txt                         # Required Jenkins plugins
```

## 🛠️ Prerequisites

- Docker and Docker Compose
- GitHub repository with webhook access
- Firebase project with hosting enabled
- Remote server with SSH access
- Slack workspace (optional)

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/your-username/jenkins-workshop2.git
cd jenkins-workshop2
```

### 2. Start Jenkins
```bash
docker-compose up -d
```

### 3. Access Jenkins
- Open http://localhost:8080
- Get initial admin password: `docker-compose exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword`

### 4. Configure Credentials
Add the following credentials in Jenkins:

| Credential ID | Type | Description |
|---------------|------|-------------|
| `FIREBASE_TOKEN` | Secret text | Firebase CI token |
| `GITHUB_TOKEN` | Secret text | GitHub Personal Access Token |
| `SLACK_TOKEN` | Secret text | Slack Bot Token (optional) |

### 5. Create Pipeline Job
1. New Item → Pipeline
2. Configure Git repository: `https://github.com/your-username/jenkins-workshop2.git`
3. Pipeline script from SCM → Git
4. Script Path: `Jenkinsfile`

## 🔧 Configuration

### Environment Variables

The pipeline uses the following configuration:

```groovy
environment {
    FIREBASE_TOKEN = credentials('FIREBASE_TOKEN')
    FIREBASE_PROJECT = 'your-firebase-project'
    REMOTE_HOST = 'your-remote-server.com'
    REMOTE_PATH = 'jenkins/your-app'
}
```

### Firebase Setup
1. Create Firebase project
2. Enable Firebase Hosting
3. Get CI token: `firebase login:ci`
4. Add token to Jenkins credentials

### Remote Server Setup
1. Ensure SSH access to remote server
2. Create deployment directory: `/usr/share/nginx/html/jenkins/your-app`
3. Configure nginx to serve from this directory

## 📋 Pipeline Stages

### 1. Checkout
- Clones the repository
- Extracts commit information for notifications

### 2. Build
- Installs Node.js dependencies
- Prepares application for deployment

### 3. Lint/Test
- Runs ESLint for code quality
- Executes automated tests
- Fails pipeline on warnings or test failures

### 4. Deploy (Parallel)
- **Firebase Deploy**: Deploys to Firebase Hosting
- **Remote Deploy**: Deploys to CentOS server with timestamped folders

### 5. Post Actions
- Sends Slack notifications
- Logs deployment URLs and status

## 🔄 Deployment Process

### Firebase Deployment
- Uses Firebase CLI with service account authentication
- Deploys to `https://{PROJECT_ID}.web.app`
- Automatic cleanup of temporary files

### Remote Server Deployment
- Creates timestamped deployment folders: `deploy/YYYYMMDD_HHMMSS/`
- Copies essential files: `index.html`, `css/`, `js/`, `images/`
- Creates symlink: `current -> deploy/{latest}`
- Keeps only 5 most recent deployments
- Deploys to: `http://your-remote-server.com/jenkins/your-app/current/`

## 📱 Notifications

### Slack Integration
- **Success**: Deployment URLs, commit info, build details
- **Failure**: Error details, build logs, troubleshooting info

### Console Output
- Detailed logs for each stage
- Deployment URLs and timestamps
- File transfer status

## 🐛 Troubleshooting

### Common Issues

1. **SSH Permission Denied**
   ```bash
   # Check SSH key permissions
   chmod 600 /var/jenkins_home/.ssh/id_rsa
   ```

2. **Firebase Authentication Failed**
   - Verify Firebase project exists
   - Check token validity
   - Ensure proper permissions

3. **Remote Server Connection Issues**
   - Verify SSH connectivity
   - Check firewall settings
   - Confirm deployment directory exists

### Debug Commands
```bash
# Test SSH connection
ssh -i /var/jenkins_home/.ssh/id_rsa -p 22 user@your-remote-server.com

# Check Firebase project
firebase projects:list

# Verify deployment directory
ls -la /usr/share/nginx/html/jenkins/your-app/
```

## 🔒 Security Notes

- SSH keys are stored securely in Jenkins credentials
- Firebase tokens are masked in logs
- Deployment scripts use minimal required permissions
- Temporary files are automatically cleaned up

## 📚 Additional Resources

- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [Firebase Hosting Guide](https://firebase.google.com/docs/hosting)
- [Docker Compose Reference](https://docs.docker.com/compose/)

## 👥 Contributing

1. Fork the repository
2. Create feature branch
3. Make changes
4. Test pipeline locally
5. Submit pull request

## 📄 License

This project is part of a Jenkins CI/CD workshop and is for educational purposes.

---

**Author**: Do Khanh Toan  
**Workshop**: Jenkins CI/CD Pipeline  
**Version**: 2.0