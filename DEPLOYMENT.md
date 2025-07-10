# Deployment Guide

This guide explains how to deploy the Socket.IO Chat Application to different environments using environment-specific configurations.

## Overview

The application supports multiple deployment environments:
- **Netlify**: Static portfolio site (uses `index.html`)
- **Docker**: Containerized chat application (uses `index-docker.html`)
- **AWS**: Production containerized deployment (uses `index-docker.html` with enhanced security)

## Environment-Specific HTML Files

### 1. `index.html` - Portfolio Version (Netlify)
- Comprehensive portfolio presentation
- Interactive demonstrations and code examples
- Skills showcase and project overview
- Smart fallback for when Socket.IO server is unavailable
- Optimized for static site deployment

### 2. `index-docker.html` - Chat Application (Docker/AWS)
- Focused on real-time chat functionality
- Cleaner, simpler interface
- Docker deployment information display
- Optimized for containerized environments
- Real-time user presence and typing indicators

## Deployment Methods

### Method 1: Environment Variables (Recommended)

The application automatically serves different HTML files based on the `NODE_ENV` environment variable:

```bash
# Default/Portfolio mode
NODE_ENV=portfolio npm start

# Docker mode
NODE_ENV=docker npm start
```

### Method 2: Explicit Routes

Access different versions via specific routes:
- `/` - Default (portfolio or docker based on NODE_ENV)
- `/portfolio` - Always serves portfolio version
- `/docker` - Always serves Docker version

## Docker Deployment

### Local Docker Build and Run

```bash
# Build the Docker image
docker build -t socket-chat:latest .

# Run the container
docker run -p 3000:3000 socket-chat:latest

# The app will automatically use index-docker.html
```

### Docker Hub Deployment

```bash
# Tag for Docker Hub
docker tag socket-chat:latest your-username/socket-chat:latest

# Push to Docker Hub
docker push your-username/socket-chat:latest

# Run from Docker Hub
docker pull your-username/socket-chat:latest
docker run -p 3000:3000 your-username/socket-chat:latest
```

### Docker Compose (Optional)

Create a `docker-compose.yml` file:

```yaml
version: '3.8'
services:
  chat-app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=docker
    restart: unless-stopped
```

Run with:
```bash
docker-compose up -d
```

## AWS Deployment

### Using AWS ECS/Fargate

1. **Build and push to ECR:**
```bash
# Build using AWS-specific Dockerfile
docker build -f Dockerfile.aws -t socket-chat:aws .

# Tag for ECR
docker tag socket-chat:aws 123456789012.dkr.ecr.us-east-1.amazonaws.com/socket-chat:latest

# Push to ECR
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/socket-chat:latest
```

2. **Create ECS Task Definition:**
```json
{
  "family": "socket-chat",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::123456789012:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "socket-chat",
      "image": "123456789012.dkr.ecr.us-east-1.amazonaws.com/socket-chat:latest",
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "NODE_ENV",
          "value": "docker"
        }
      ],
      "healthCheck": {
        "command": ["CMD-SHELL", "node healthcheck.js"],
        "interval": 30,
        "timeout": 5,
        "retries": 3
      },
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/socket-chat",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

3. **Create ECS Service with Application Load Balancer**

### Using AWS EC2

1. **Launch EC2 instance with Docker installed**
2. **Pull and run the container:**
```bash
docker pull your-username/socket-chat:latest
docker run -d -p 80:3000 --name socket-chat your-username/socket-chat:latest
```

## Netlify Deployment

### Option 1: Deploy Portfolio Only

1. Create a separate repository with only the portfolio files
2. Copy `index.html` and any static assets
3. Deploy to Netlify via GitHub integration

### Option 2: Deploy Full Project with Build Command

1. Add build script to `package.json`:
```json
{
  "scripts": {
    "build": "mkdir -p dist && cp index.html dist/",
    "start": "npm run build && node index.js"
  }
}
```

2. Configure Netlify:
   - Build command: `npm run build`
   - Publish directory: `dist`

## CI/CD Pipeline Updates

### GitHub Actions for Multi-Environment Deployment

Update `.github/workflows/cicd.yml`:

```yaml
name: CI/CD Multi-Environment

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        environment: [docker, aws]
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Set up Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '19.x'

      - name: Install dependencies
        run: npm ci

      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_HUB_USERNAME }}
          password: ${{ secrets.DOCKER_HUB_ACCESS_TOKEN }}

      - name: Build and push Docker image
        uses: docker/build-push-action@v4
        with:
          context: ./
          file: ${{ matrix.environment == 'aws' && './Dockerfile.aws' || './Dockerfile' }}
          push: true
          tags: ${{ secrets.DOCKER_HUB_USERNAME }}/socket-chat:${{ matrix.environment }}

      - name: Deploy to AWS (if aws environment)
        if: matrix.environment == 'aws'
        run: |
          # Add AWS deployment commands here
          echo "Deploying to AWS..."
```

## Environment Configuration

### Environment Variables

Create `.env` files for different environments:

**`.env.docker`:**
```
NODE_ENV=docker
PORT=3000
```

**`.env.aws`:**
```
NODE_ENV=docker
PORT=3000
AWS_REGION=us-east-1
```

**`.env.netlify`:**
```
NODE_ENV=portfolio
```

### Docker Environment Variables

Pass environment variables to Docker containers:

```bash
# Using environment file
docker run --env-file .env.docker -p 3000:3000 socket-chat:latest

# Using individual variables
docker run -e NODE_ENV=docker -p 3000:3000 socket-chat:latest
```

## Monitoring and Logging

### Health Check Endpoints

The application includes health check endpoints:
- `/health` - Returns application health status
- Used by Docker HEALTHCHECK and AWS ECS health checks

### Logging

Configure logging for different environments:

```javascript
// Add to index.js
const logger = process.env.NODE_ENV === 'docker' ? 
  console : // Simple console logging for Docker
  require('winston').createLogger({...}); // Advanced logging for AWS
```

## Security Considerations

### Docker Security
- Non-root user execution (in Dockerfile.aws)
- Minimal base image (Alpine Linux)
- Health checks for container monitoring
- Secrets management via environment variables

### AWS Security
- IAM roles for ECS tasks
- VPC configuration for network isolation
- Security groups for port access control
- CloudWatch logging for audit trails

## Troubleshooting

### Common Issues

1. **Port conflicts:**
   - Ensure port 3000 is available
   - Use `docker ps` to check running containers

2. **Environment variable issues:**
   - Verify NODE_ENV is set correctly
   - Check Docker environment variables with `docker exec`

3. **Health check failures:**
   - Ensure health check endpoint is accessible
   - Check container logs with `docker logs`

### Debug Commands

```bash
# Check container environment
docker exec -it container-name env

# Check container logs
docker logs container-name

# Access container shell
docker exec -it container-name sh

# Test health check
curl http://localhost:3000/health
```

## Summary

This deployment strategy allows you to:
- Use the same codebase for multiple environments
- Maintain different user experiences for different deployment targets
- Easily switch between environments using configuration
- Implement environment-specific optimizations
- Maintain consistent CI/CD pipelines across environments

Choose the deployment method that best fits your needs and infrastructure requirements.