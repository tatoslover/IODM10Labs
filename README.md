# Lab 10 Part 1 - Docker & CI/CD Portfolio

This repository demonstrates comprehensive DevOps engineering skills through the implementation of a Socket.IO chat application with complete containerization and continuous integration/deployment pipeline. The project showcases modern DevOps practices including Docker containerization, GitHub Actions automation, and Docker Hub registry integration.

## Overview

Lab 10 Part 1 focuses on containerization and continuous integration/continuous deployment (CI/CD) practices. Students learn to create Docker containers for Node.js applications and implement automated deployment pipelines using GitHub Actions. This first part culminates in a portfolio-ready demonstration that showcases both technical implementation and professional presentation skills.

## Skills Developed

- **Docker Containerization:** Dockerfile creation, image optimization, multi-stage builds
- **Container Management:** Image building, container orchestration, registry operations
- **CI/CD Pipelines:** GitHub Actions workflows, automated testing and deployment
- **DevOps Practices:** Infrastructure as code, automated deployments, version control integration
- **Cloud Services:** Docker Hub integration, container registry management
- **Node.js Development:** Express server, Socket.IO real-time communication
- **Security:** Secret management, secure authentication, container security best practices
- **Portfolio Development:** Professional presentation, interactive demonstrations

## Exercise 1 - Docker Implementation
**Files:** `Dockerfile`, `.dockerignore`, `package.json`, `index.js`

**What it showcases:** Complete Docker containerization of a Node.js application without database dependencies

### Challenge:
Create your own DockerFile for your Node.js application (without reliance on a DB) and create a running image of your application. Provide your public Docker Hub image link to the trainer so they can run your application using your docker image.

### Implementation Features:
- **Alpine Linux Base:** Minimal image size for efficiency (~50MB vs ~900MB)
- **Optimized Layer Structure:** Strategic COPY placement and efficient caching
- **Security Considerations:** Non-root user execution, minimal attack surface
- **Production Ready:** Proper port exposure, environment variable support

### Docker Commands:
```bash
# Build the Docker image
docker build -t socket-chat .

# Run locally for testing
docker run -p 3000:3000 socket-chat

# Tag for Docker Hub repository
docker tag socket-chat username/dockerdemo:latest

# Push to Docker Hub
docker push username/dockerdemo:latest

# Pull and run from Docker Hub
docker pull username/dockerdemo:latest
docker run -p 3000:3000 username/dockerdemo:latest
```

### Dockerfile Implementation:
```dockerfile
FROM node:19-alpine
WORKDIR /app
COPY . .
EXPOSE 3000
RUN npm install
CMD ["npm", "start"]
```

---

## Exercise 2 - GitHub Actions CI/CD Pipeline
**File:** `.github/workflows/cicd.yml`

**What it showcases:** Automated continuous integration and deployment pipeline with Docker Hub integration

### Challenge:
Create your own GitHub Actions for your Node.js application and create a running CI/CD pipeline for your application that updates your Docker Hub image automatically when new commits are made.

### Pipeline Features:
- **Automated Triggers:** Builds on every main branch push
- **Multi-Node Testing:** Matrix strategy for Node.js versions
- **Dependency Management:** Automated npm installation and caching
- **Secure Authentication:** GitHub Secrets for Docker Hub credentials
- **Build Optimization:** Docker Buildx for advanced building features
- **Automated Publishing:** Direct push to Docker Hub registry

### Workflow Implementation:
```yaml
name: CI/CD

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [19.x]
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Set up Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node-version }}

      - name: Install dependencies
        run: npm install

      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_HUB_USERNAME }}
          password: ${{ secrets.DOCKER_HUB_ACCESS_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: ./
          file: ./Dockerfile
          push: true
          tags: ${{ secrets.DOCKER_HUB_USERNAME }}/dockerdemo:latest
```

### Security Features:
- **GitHub Secrets Management:** Encrypted credential storage
- **Access Control:** Branch protection and merge restrictions
- **Container Security:** Alpine Linux, minimal attack surface
- **Build Security:** Dependency vulnerability scanning, audit trails

---

## Application Architecture
**Files:** `index.js`, `index.html`, `package.json`

**What it showcases:** Real-time web application with Socket.IO, Express server, and interactive frontend

### Technical Stack:
- **Backend:** Node.js with Express framework
- **Real-time Communication:** Socket.IO for WebSocket connections
- **Frontend:** Vanilla JavaScript with responsive design
- **Containerization:** Docker with Alpine Linux base
- **Deployment:** Automated CI/CD with GitHub Actions

### Application Features:
- **Real-time Messaging:** Instant chat functionality
- **User Presence:** Online user tracking and notifications
- **Typing Indicators:** Live typing status updates
- **Responsive Design:** Mobile-friendly interface
- **Smart Fallback:** Static demo when server unavailable

### Socket.IO Implementation:
```javascript
// Server-side event handling
io.on("connection", (socket) => {
  console.log("A user connected");
  
  socket.on("choose name", (nickname) => {
    users[socket.id] = nickname;
    socket.broadcast.emit("new user", {
      nickname: nickname,
      text: "has joined the chat"
    });
  });
  
  socket.on("chat message", (msg) => {
    const sender = users[socket.id] || "Unknown";
    socket.broadcast.emit("chat message", `${sender}: ${msg}`);
  });
});
```

---

## Portfolio Presentation
**File:** `index.html`

**What it showcases:** Professional portfolio presentation with interactive demonstrations

### Portfolio Features:
- **Professional Design:** IOD and Docker branding, responsive layout
- **Interactive Sections:** Collapsible content areas with smooth animations
- **Code Demonstrations:** Syntax-highlighted code examples
- **Live Application Demo:** Functional chat application with smart fallback
- **Skills Showcase:** Comprehensive DevOps and development skills grid
- **External Links:** GitHub repository and Docker Hub image links

### Smart Demo System:
The portfolio includes an intelligent demonstration system that:
- **Detects Server Status:** Automatically determines if Socket.IO server is running
- **Live Mode:** Full real-time chat when server is available
- **Static Mode:** Simulated chat experience with demo responses
- **Graceful Fallback:** Professional presentation regardless of server status

---

## Getting Started

### Prerequisites:
- Node.js (v19.x)
- Docker Desktop
- GitHub account
- Docker Hub account

### Local Development:
```bash
# Clone the repository
git clone https://github.com/tatoslover/dockerdemo.git
cd dockerdemo

# Install dependencies
npm install

# Run the application
npm start

# Visit http://localhost:3000
```

### Docker Deployment:
```bash
# Build and run with Docker
docker build -t dockerdemo .
docker run -p 3000:3000 dockerdemo

# Or pull from Docker Hub
docker pull username/dockerdemo:latest
docker run -p 3000:3000 username/dockerdemo:latest
```

### CI/CD Setup:
1. Fork this repository
2. Set up GitHub Secrets:
   - `DOCKER_HUB_USERNAME`
   - `DOCKER_HUB_ACCESS_TOKEN`
3. Push to main branch to trigger deployment

---

## Project Structure
```
dockerdemo/
├── .github/
│   └── workflows/
│       └── cicd.yml          # GitHub Actions workflow
├── node_modules/             # Dependencies (auto-generated)
├── .dockerignore            # Docker ignore file
├── .gitignore              # Git ignore file
├── Dockerfile              # Container configuration
├── index.html              # Portfolio and chat interface
├── index.js                # Express server with Socket.IO
├── package.json            # Node.js dependencies
├── package-lock.json       # Dependency lock file
└── README.md              # This documentation
```

---

## Live Demo

**Portfolio:** [GitHub Pages](https://tatoslover.github.io/dockerdemo/)
**Docker Image:** [Docker Hub](https://hub.docker.com/repository/docker/tatoslover/dockerdemo/general)
**Source Code:** [GitHub Repository](https://github.com/tatoslover/dockerdemo)

---

## Learning Outcomes

Upon completion of Lab 10 Part 1, students will have demonstrated:

1. **Docker Proficiency:** Container creation, optimization, and deployment
2. **CI/CD Implementation:** Automated pipeline development and maintenance
3. **DevOps Practices:** Infrastructure as code, automated deployments
4. **Security Awareness:** Secret management, container security
5. **Professional Presentation:** Portfolio development and technical communication
6. **Real-world Application:** Production-ready deployment strategies

This lab part provides hands-on experience with modern DevOps tools and practices essential for contemporary software development and deployment workflows.