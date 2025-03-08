#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
YELLOW='\033[1;33m'

# Function to print status messages
print_status() {
    echo -e "${GREEN}[*] $1${NC}"
}

print_error() {
    echo -e "${RED}[!] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}[!] $1${NC}"
}

# Check if inventory file exists
if [ ! -f "inventory.ini" ]; then
    print_error "hosts file not found. Please create an inventory file first."
    exit 1
fi


# Check if .env file exists
if [ ! -f ".env" ]; then
    print_error ".env file not found. Please create it first."
    exit 1
fi

# Source the .env file to get environment variables
source .env

# Check if SERVER_IP is set
if [ -z "$SERVER_IP" ]; then
    print_error "SERVER_IP not found in .env file. Please add it."
    exit 1
fi

# Start deployment process
print_status "Starting deployment process..."

# Step 1: Install Docker and dependencies
print_status "Installing Docker and dependencies..."
ansible-playbook -i inventory.ini ./playbooks/playbook.yml
if [ $? -ne 0 ]; then
    print_error "Docker installation failed. Aborting."
    exit 1
fi

# Step 2: Deploy application
print_status "Deploying application..."
ansible-playbook -i inventory.ini ./playbooks/deploy.yml
if [ $? -ne 0 ]; then
    print_error "Application deployment failed. Aborting."
    exit 1
fi

# Check if services are running
print_status "Checking service status..."
ansible -i hosts all -m shell -a "docker ps" --become

print_status "Deployment completed successfully!"
print_warning "Please check the following URLs:"
print_warning "WordPress: http://${SERVER_IP}"
print_warning "phpMyAdmin: http://${SERVER_IP}:8080" 