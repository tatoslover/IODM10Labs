#!/bin/bash

# AWS Deployment Script for Module 10 Lab
# This script helps deploy your application to AWS EC2 and Elastic Beanstalk

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOCKER_IMAGE="tatoslover/module10lab:latest"
EC2_KEY_NAME="module10lab-key"
SECURITY_GROUP="module10lab-security-group"
BEANSTALK_APP="module10lab-app"

echo -e "${BLUE}🚀 AWS Deployment Script for Module 10 Lab${NC}"
echo "=================================================="

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

# Function to check if AWS CLI is installed
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install it first:"
        echo "  macOS: brew install awscli"
        echo "  Linux: sudo apt-get install awscli"
        echo "  Windows: Download from https://aws.amazon.com/cli/"
        exit 1
    fi
    print_status "AWS CLI is installed"
}

# Function to check AWS credentials
check_aws_credentials() {
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured. Please run:"
        echo "  aws configure"
        echo "  Enter your Access Key ID, Secret Access Key, and region"
        exit 1
    fi
    print_status "AWS credentials are configured"
}

# Function to create security group
create_security_group() {
    print_info "Creating security group..."

    # Check if security group already exists
    if aws ec2 describe-security-groups --group-names $SECURITY_GROUP &> /dev/null; then
        print_warning "Security group $SECURITY_GROUP already exists"
        return 0
    fi

    # Create security group
    SECURITY_GROUP_ID=$(aws ec2 create-security-group \
        --group-name $SECURITY_GROUP \
        --description "Security group for Module 10 Lab" \
        --query 'GroupId' --output text)

    # Add inbound rules
    aws ec2 authorize-security-group-ingress \
        --group-id $SECURITY_GROUP_ID \
        --protocol tcp \
        --port 22 \
        --cidr 0.0.0.0/0

    aws ec2 authorize-security-group-ingress \
        --group-id $SECURITY_GROUP_ID \
        --protocol tcp \
        --port 80 \
        --cidr 0.0.0.0/0

    aws ec2 authorize-security-group-ingress \
        --group-id $SECURITY_GROUP_ID \
        --protocol tcp \
        --port 3000 \
        --cidr 0.0.0.0/0

    print_status "Security group created: $SECURITY_GROUP_ID"
}

# Function to create key pair
create_key_pair() {
    print_info "Creating key pair..."

    # Check if key pair already exists
    if aws ec2 describe-key-pairs --key-names $EC2_KEY_NAME &> /dev/null; then
        print_warning "Key pair $EC2_KEY_NAME already exists"
        return 0
    fi

    # Create key pair and save private key
    aws ec2 create-key-pair \
        --key-name $EC2_KEY_NAME \
        --query 'KeyMaterial' \
        --output text > ${EC2_KEY_NAME}.pem

    # Set proper permissions
    chmod 400 ${EC2_KEY_NAME}.pem

    print_status "Key pair created: ${EC2_KEY_NAME}.pem"
    print_warning "Keep this file secure! You'll need it to SSH into your instance."
}

# Function to launch EC2 instance
launch_ec2_instance() {
    print_info "Launching EC2 instance..."

    # Get latest Ubuntu AMI ID
    AMI_ID=$(aws ec2 describe-images \
        --owners 099720109477 \
        --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
        --query 'Images[*].[ImageId,CreationDate]' \
        --output text \
        | sort -k2 -r \
        | head -n1 \
        | cut -f1)

    print_info "Using AMI: $AMI_ID"

    # Launch instance
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id $AMI_ID \
        --count 1 \
        --instance-type t2.micro \
        --key-name $EC2_KEY_NAME \
        --security-groups $SECURITY_GROUP \
        --associate-public-ip-address \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=module10lab-server}]" \
        --user-data file://user-data.sh \
        --query 'Instances[0].InstanceId' \
        --output text)

    print_status "EC2 instance launched: $INSTANCE_ID"

    # Wait for instance to be running
    print_info "Waiting for instance to be running..."
    aws ec2 wait instance-running --instance-ids $INSTANCE_ID

    # Get public IP
    PUBLIC_IP=$(aws ec2 describe-instances \
        --instance-ids $INSTANCE_ID \
        --query 'Reservations[0].Instances[0].PublicIpAddress' \
        --output text)

    print_status "Instance is running!"
    print_info "Public IP: $PUBLIC_IP"
    print_info "SSH command: ssh -i ${EC2_KEY_NAME}.pem ubuntu@$PUBLIC_IP"

    # Save instance info
    echo "INSTANCE_ID=$INSTANCE_ID" > ec2-info.txt
    echo "PUBLIC_IP=$PUBLIC_IP" >> ec2-info.txt
    echo "SSH_COMMAND=ssh -i ${EC2_KEY_NAME}.pem ubuntu@$PUBLIC_IP" >> ec2-info.txt

    print_status "Instance information saved to ec2-info.txt"
}

# Function to create user data script
create_user_data() {
    print_info "Creating user data script..."

    cat > user-data.sh << 'EOF'
#!/bin/bash
# User data script for EC2 instance

# Update system
apt-get update -y

# Install Docker
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

# Start Docker service
systemctl start docker
systemctl enable docker

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Pull and run the application
docker pull tatoslover/module10lab:latest
docker run -d \
  --name module10lab-app \
  -p 80:3000 \
  -p 3000:3000 \
  -e NODE_ENV=docker \
  --restart unless-stopped \
  tatoslover/module10lab:latest

# Create a simple status check script
cat > /home/ubuntu/check-status.sh << 'SCRIPT'
#!/bin/bash
echo "=== Docker Status ==="
docker ps
echo ""
echo "=== Application Health ==="
curl -s http://localhost:3000/health || echo "Health check failed"
echo ""
echo "=== Application URLs ==="
echo "Main app: http://$(curl -s http://checkip.amazonaws.com/):3000"
echo "Docker interface: http://$(curl -s http://checkip.amazonaws.com/):3000/docker"
echo "Portfolio: http://$(curl -s http://checkip.amazonaws.com/):3000/portfolio"
echo "Health check: http://$(curl -s http://checkip.amazonaws.com/):3000/health"
SCRIPT

chmod +x /home/ubuntu/check-status.sh
chown ubuntu:ubuntu /home/ubuntu/check-status.sh

# Log completion
echo "$(date): User data script completed" >> /var/log/user-data.log
EOF

    print_status "User data script created"
}

# Function to create Beanstalk application
create_beanstalk_app() {
    print_info "Creating Elastic Beanstalk application..."

    # Check if EB CLI is installed
    if ! command -v eb &> /dev/null; then
        print_warning "EB CLI not found. Installing..."
        pip install awsebcli
    fi

    # Create application bundle
    print_info "Creating application bundle..."
    cd beanstalk-app
    zip -r ../module10lab-beanstalk.zip . -x "*.git*" "node_modules/*"
    cd ..

    # Create Beanstalk application
    aws elasticbeanstalk create-application \
        --application-name $BEANSTALK_APP \
        --description "Module 10 Lab - Socket.IO Chat Application"

    # Create application version
    aws elasticbeanstalk create-application-version \
        --application-name $BEANSTALK_APP \
        --version-label v1.0 \
        --source-bundle S3Bucket="elasticbeanstalk-$(aws configure get region)-$(aws sts get-caller-identity --query Account --output text)",S3Key="module10lab-beanstalk.zip"

    print_status "Beanstalk application created"
    print_info "Visit AWS Console to complete the environment creation"
}

# Function to show deployment status
show_deployment_status() {
    echo
    print_info "Deployment Status Summary:"
    echo "=========================="

    if [ -f ec2-info.txt ]; then
        echo
        print_status "EC2 Instance Deployed:"
        cat ec2-info.txt
        echo
        print_info "Application URLs:"
        source ec2-info.txt
        echo "  Main app: http://$PUBLIC_IP:3000"
        echo "  Docker interface: http://$PUBLIC_IP:3000/docker"
        echo "  Portfolio: http://$PUBLIC_IP:3000/portfolio"
        echo "  Health check: http://$PUBLIC_IP:3000/health"
        echo
        print_info "SSH into instance:"
        echo "  $SSH_COMMAND"
        echo "  sudo docker logs module10lab-app"
        echo "  ./check-status.sh"
    fi

    echo
    print_info "Next Steps:"
    echo "1. Wait 2-3 minutes for Docker to fully start"
    echo "2. Test the application URLs above"
    echo "3. For Beanstalk: Complete setup in AWS Console"
    echo "4. Remember to terminate resources when done!"
    echo
}

# Function to cleanup resources
cleanup_resources() {
    print_info "Cleaning up AWS resources..."

    if [ -f ec2-info.txt ]; then
        source ec2-info.txt
        print_info "Terminating EC2 instance: $INSTANCE_ID"
        aws ec2 terminate-instances --instance-ids $INSTANCE_ID
        print_status "Instance termination initiated"
    fi

    print_info "Use AWS Console to delete:"
    echo "  - Elastic Beanstalk application: $BEANSTALK_APP"
    echo "  - Security group: $SECURITY_GROUP"
    echo "  - Key pair: $EC2_KEY_NAME"
}

# Main deployment function
deploy_ec2() {
    print_info "Starting EC2 deployment..."
    check_aws_cli
    check_aws_credentials
    create_user_data
    create_security_group
    create_key_pair
    launch_ec2_instance
    show_deployment_status
}

# Help function
show_help() {
    echo
    echo "Usage: $0 [COMMAND]"
    echo
    echo "Commands:"
    echo "  deploy, d             - Deploy to EC2 (Exercise 1 & 2)"
    echo "  beanstalk, b          - Create Beanstalk app (Exercise 3)"
    echo "  status, s             - Show deployment status"
    echo "  cleanup, c            - Cleanup AWS resources"
    echo "  help, h               - Show this help"
    echo
    echo "Examples:"
    echo "  $0 deploy             - Deploy application to EC2"
    echo "  $0 status             - Check deployment status"
    echo "  $0 cleanup            - Clean up resources"
    echo
}

# Main script logic
case "${1:-deploy}" in
    deploy|d)
        deploy_ec2
        ;;
    beanstalk|b)
        create_beanstalk_app
        ;;
    status|s)
        show_deployment_status
        ;;
    cleanup|c)
        cleanup_resources
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
