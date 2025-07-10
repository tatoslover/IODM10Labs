# Module 10 Lab - Docker, CI/CD & AWS Deployment

A comprehensive DevOps implementation demonstrating Docker containerization, CI/CD automation, and AWS cloud deployment through a real-time Socket.IO chat application.

## 🎯 **Lab Exercises**

### **Exercise 1: Docker Implementation**
- Create Dockerfile for Node.js application
- Build and optimize container image
- Publish to Docker Hub: `docker pull tatoslover/module10lab`
- **Docker Hub**: https://hub.docker.com/r/tatoslover/module10lab

### **Exercise 2: GitHub Actions CI/CD Pipeline**
- Automated testing and deployment workflow
- Docker Hub integration with secure credential management
- Triggers on main branch commits
- **GitHub Actions**: https://github.com/tatoslover/Module10Lab/actions

### **Exercise 3: AWS EC2 Setup & Docker Deployment**
- Create free-tier EC2 Ubuntu instance (t2.micro)
- Deploy Docker container to EC2
- Configure security groups and networking
- **Live Application**: http://44.211.146.21
- **Portfolio**: http://44.211.146.21/portfolio
- **Health Check**: http://44.211.146.21/health

### **Exercise 4: AWS Elastic Beanstalk Deployment**
- Deploy Node.js application to Elastic Beanstalk
- Managed platform with auto-scaling
- **Live Application**: http://beanstalkdemo-env.eba-6hpbm22d.us-east-1.elasticbeanstalk.com

## 🚀 **Quick Start**

### **Local Development**
```bash
# Clone repository
git clone https://github.com/tatoslover/Module10Lab.git
cd Module10Lab

# Install dependencies
npm install

# Run application
npm start
# Visit http://localhost:3000
```

### **Docker Deployment**
```bash
# Pull and run from Docker Hub
docker pull tatoslover/module10lab
docker run -p 3000:3000 tatoslover/module10lab

# Or build locally
docker build -t module10lab .
docker run -p 3000:3000 module10lab
```

## 🛠️ **Technical Stack**

- **Backend**: Node.js, Express.js
- **Real-time**: Socket.IO WebSocket communication
- **Frontend**: Vanilla JavaScript, responsive design
- **Containerization**: Docker with Alpine Linux
- **CI/CD**: GitHub Actions
- **Cloud**: AWS EC2, Elastic Beanstalk
- **Registry**: Docker Hub

## 🏗️ **Architecture**

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   GitHub Repo   │───▶│  GitHub Actions  │───▶│   Docker Hub    │
│   (Source Code) │    │   (CI/CD Build)  │    │  (Image Store)  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                                         │
                        ┌─────────────────┐              │
                        │   AWS EC2       │◀─────────────┘
                        │ (Docker Deploy) │
                        └─────────────────┘
                                                         
                        ┌─────────────────┐              
                        │ Elastic Beanstalk│◀─────────────┘
                        │ (Managed Deploy)│
                        └─────────────────┘
```

## 📁 **Project Structure**

```
Module10Lab/
├── .github/workflows/
│   └── ci-cd.yml              # GitHub Actions workflow
├── beanstalk-app/             # Elastic Beanstalk deployment
├── Dockerfile                 # Container configuration
├── docker-compose.yml         # Multi-container setup
├── index.js                   # Express server with Socket.IO
├── index.html                 # Portfolio interface
├── index-docker.html          # Docker-optimized interface
├── healthcheck.js             # Health monitoring
├── package.json               # Dependencies and scripts
└── README.md                  # This file
```

## 🔧 **Key Features**

### **Docker Implementation**
- Multi-stage builds for optimization
- Alpine Linux base (minimal size)
- Health checks and monitoring
- Production-ready configuration

### **CI/CD Pipeline**
- Automated testing on push
- Docker image building and publishing
- Secure credential management
- Multi-environment support

### **AWS Deployment**
- EC2 free-tier instance setup
- Docker container orchestration
- Security groups and networking
- Elastic Beanstalk managed hosting

### **Application Features**
- Real-time chat with Socket.IO
- User presence and typing indicators
- Responsive design
- Health monitoring endpoints
- Smart fallback for offline mode

## 🌐 **Live Demos**

| Platform | URL | Description |
|----------|-----|-------------|
| **EC2** | http://44.211.146.21 | Main application |
| **EC2 Portfolio** | http://44.211.146.21/portfolio | Portfolio demo |
| **Health Check** | http://44.211.146.21/health | Status monitoring |
| **Elastic Beanstalk** | http://beanstalkdemo-env.eba-6hpbm22d.us-east-1.elasticbeanstalk.com | Managed deployment |

## 🎓 **Skills Demonstrated**

- **Docker**: Containerization, image optimization, registry management
- **CI/CD**: Automated pipelines, testing, deployment automation
- **AWS**: EC2 setup, container deployment, Elastic Beanstalk
- **DevOps**: Infrastructure as code, monitoring, security
- **Node.js**: Server development, real-time applications
- **Frontend**: Responsive design, WebSocket integration

## 🔐 **Security & Best Practices**

- Non-root Docker container execution
- GitHub Secrets for credential management
- AWS security groups and IAM roles
- Health check endpoints for monitoring
- Minimal attack surface with Alpine Linux

## 💰 **Cost Management**

All deployments use AWS free tier:
- **EC2**: t2.micro instance (750 hours/month)
- **Elastic Beanstalk**: Single instance deployment
- **Storage**: 8GB EBS (within 30GB limit)
- **Monitoring**: Basic health checks included

## 🚀 **Getting Started**

1. **Clone the repository**
2. **Set up Docker Hub account**
3. **Configure AWS free tier account**
4. **Follow exercise instructions in portfolio**
5. **Deploy and test applications**

## 📚 **Documentation**

- **Portfolio**: Comprehensive lab documentation at http://44.211.146.21/portfolio
- **Docker Hub**: Image details and pull instructions
- **GitHub**: Source code and CI/CD workflows
- **AWS**: Live application demonstrations

## 🏆 **Lab Completion**

✅ **Exercise 1**: Docker implementation and publishing  
✅ **Exercise 2**: CI/CD pipeline automation  
✅ **Exercise 3**: AWS EC2 setup and deployment  
✅ **Exercise 4**: Elastic Beanstalk deployment  

All exercises completed successfully with live demonstrations available for trainer verification.

---

**Samuel Love** | [GitHub Repository](https://github.com/tatoslover/Module10Lab) | 2024