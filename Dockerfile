FROM jenkins/jenkins:lts

USER root

# Install Node.js and Firebase CLI
RUN apt-get update && apt-get install -y \
    python3-pip \
    curl \
    gnupg \
    rsync \
    openssh-client

# Install Node.js 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# Install Firebase CLI globally
RUN npm install -g firebase-tools

# Install Docker CLI (alternative method)
RUN curl -fsSL https://get.docker.com | sh

USER jenkins

# Install Jenkins plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt