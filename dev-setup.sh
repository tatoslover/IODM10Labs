#!/bin/bash

# Development Setup Script for Module10Lab
# This script helps you quickly set up and manage your Docker development environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CONTAINER_NAME="module10lab-chat"
IMAGE_NAME="module10lab"
PORT=3000
DOCKER_HUB_IMAGE="tatoslover/module10lab"

echo -e "${BLUE}🐳 Module10Lab Development Setup${NC}"
echo "================================="

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker Desktop first."
        exit 1
    fi
    print_status "Docker is running"
}

# Stop and remove existing container
cleanup_container() {
    if docker ps -a --format "table {{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
        print_info "Stopping and removing existing container..."
        docker stop ${CONTAINER_NAME} > /dev/null 2>&1 || true
        docker rm ${CONTAINER_NAME} > /dev/null 2>&1 || true
        print_status "Cleaned up existing container"
    fi
}

# Build Docker image
build_image() {
    print_info "Building Docker image..."
    docker build -t ${IMAGE_NAME}:latest .
    print_status "Docker image built successfully"
}

# Run Docker container
run_container() {
    print_info "Starting Docker container..."
    docker run -d \
        -p ${PORT}:${PORT} \
        --name ${CONTAINER_NAME} \
        -e NODE_ENV=docker \
        ${IMAGE_NAME}:latest
    print_status "Container started successfully"
}

# Check container health
check_health() {
    print_info "Checking container health..."
    sleep 3

    if curl -s http://localhost:${PORT}/health > /dev/null; then
        print_status "Container is healthy and responding"
        print_info "Application is available at: http://localhost:${PORT}"
        print_info "Docker-specific interface: http://localhost:${PORT}/docker"
        print_info "Portfolio interface: http://localhost:${PORT}/portfolio"
    else
        print_warning "Container might not be ready yet. Please wait a moment and try accessing http://localhost:${PORT}"
    fi
}

# Show container logs
show_logs() {
    print_info "Container logs:"
    docker logs ${CONTAINER_NAME} --tail 10
}

# Main setup function
setup() {
    echo
    print_info "Starting development setup..."
    check_docker
    cleanup_container
    build_image
    run_container
    check_health
    echo
    print_status "Setup complete! 🎉"
    echo
    echo "Quick commands:"
    echo "  View logs:     docker logs ${CONTAINER_NAME}"
    echo "  Stop:          docker stop ${CONTAINER_NAME}"
    echo "  Restart:       docker restart ${CONTAINER_NAME}"
    echo "  Remove:        docker rm ${CONTAINER_NAME}"
    echo "  Rebuild:       ./dev-setup.sh"
    echo
}

# Function to push to Docker Hub
push_to_hub() {
    print_info "Pushing to Docker Hub..."
    docker tag ${IMAGE_NAME}:latest ${DOCKER_HUB_IMAGE}:latest
    docker push ${DOCKER_HUB_IMAGE}:latest
    print_status "Successfully pushed to Docker Hub"
}

# Function to pull from Docker Hub
pull_from_hub() {
    print_info "Pulling latest from Docker Hub..."
    docker pull ${DOCKER_HUB_IMAGE}:latest
    print_status "Successfully pulled from Docker Hub"
}

# Function to run from Docker Hub
run_from_hub() {
    print_info "Running from Docker Hub image..."
    cleanup_container
    docker run -d \
        -p ${PORT}:${PORT} \
        --name ${CONTAINER_NAME} \
        -e NODE_ENV=docker \
        ${DOCKER_HUB_IMAGE}:latest
    print_status "Container started from Docker Hub image"
    check_health
}

# Function to setup ngrok (if available)
setup_ngrok() {
    if command -v ngrok &> /dev/null; then
        print_info "Setting up ngrok for public access..."
        print_warning "Run this command in a new terminal: ngrok http ${PORT}"
        print_info "This will give you a public URL to share your app"
    else
        print_warning "ngrok not found. Install it with: brew install ngrok"
        print_info "After installation, run: ngrok http ${PORT}"
    fi
}

# Function to show status
show_status() {
    echo
    print_info "Current Status:"
    echo "==============="

    if docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -q "^${CONTAINER_NAME}"; then
        print_status "Container is running"
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep "^${CONTAINER_NAME}"
        echo
        print_info "Health check:"
        if curl -s http://localhost:${PORT}/health > /dev/null; then
            print_status "Application is responding"
            echo "  URL: http://localhost:${PORT}"
        else
            print_warning "Application not responding"
        fi
    else
        print_warning "Container is not running"
    fi
    echo
}

# Function to clean everything
clean_all() {
    print_info "Cleaning up Docker resources..."
    cleanup_container

    # Remove image if exists
    if docker images --format "table {{.Repository}}" | grep -q "^${IMAGE_NAME}$"; then
        docker rmi ${IMAGE_NAME}:latest
        print_status "Removed Docker image"
    fi

    print_status "Cleanup complete"
}

# Help function
show_help() {
    echo
    echo "Usage: $0 [COMMAND]"
    echo
    echo "Commands:"
    echo "  setup, start, s       - Build and run the application (default)"
    echo "  status, st            - Show current status"
    echo "  logs, l               - Show container logs"
    echo "  stop                  - Stop the container"
    echo "  restart, r            - Restart the container"
    echo "  clean, c              - Clean up containers and images"
    echo "  push, p               - Push to Docker Hub"
    echo "  pull                  - Pull from Docker Hub"
    echo "  run-hub, rh           - Run from Docker Hub image"
    echo "  ngrok, n              - Setup ngrok for public access"
    echo "  help, h               - Show this help"
    echo
    echo "Examples:"
    echo "  $0                    - Run full setup"
    echo "  $0 status             - Check if container is running"
    echo "  $0 logs               - View recent logs"
    echo "  $0 clean              - Clean up everything"
    echo
}

# Main script logic
case "${1:-setup}" in
    setup|start|s)
        setup
        ;;
    status|st)
        show_status
        ;;
    logs|l)
        if docker ps --format "table {{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
            show_logs
        else
            print_warning "Container is not running"
        fi
        ;;
    stop)
        if docker ps --format "table {{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
            docker stop ${CONTAINER_NAME}
            print_status "Container stopped"
        else
            print_warning "Container is not running"
        fi
        ;;
    restart|r)
        if docker ps -a --format "table {{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
            docker restart ${CONTAINER_NAME}
            print_status "Container restarted"
            check_health
        else
            print_warning "Container does not exist. Run setup first."
        fi
        ;;
    clean|c)
        clean_all
        ;;
    push|p)
        push_to_hub
        ;;
    pull)
        pull_from_hub
        ;;
    run-hub|rh)
        run_from_hub
        ;;
    ngrok|n)
        setup_ngrok
        ;;
    help|h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
