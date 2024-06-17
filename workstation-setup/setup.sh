#!/usr/bin/env bash
#--------------------
# This script installs basic components for capstone project workstation (Ubuntu)
# Installs: AWS CLI, Ansible, Terraform, Docker
# Note: Script needs to be ran with sudo privilages to install packages via apt


# Function declarations
# Check if tool is present on the system
function check_command {
    if command -v "$1" &> /dev/null; then
        echo "$1 is already installed."
        return 0
    else
        return 1
    fi
}


# Script - start
# Update packages and install needed ones
echo "============================================="
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y curl gnupg software-properties-common unzip

# Go to home directory
cd ~

# Install Terraform
echo "============================================="
if ! check_command terraform; then
    echo "Installing Terraform..."

    # Get HashiCopr GPG key
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

    # Verify GPG key
    gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
    
    # Add official repository
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

    # Update package information
    sudo apt update

    # Install Terraform
    sudo apt-get install terraform

    # Verify installation
    tf_version=$(terraform -v)
    if [[ -n $tf_version ]]; then
        echo "Terraform installation was unsuccessfull - please proceed manually (https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)"
    else
        echo "Terraform installed succesfully"
    fi
else
    echo "Terraform is already installed."
fi
echo "============================================="

# Install Ansible
if ! check_command ansible; then
    echo "Installing Ansible..."

    sudo apt-get install -y ansible

    # Verify installation
    ansible_version=$(ansible --version)
    if [[ -n $ansible_version ]]; then
        echo "Ansible installation was unsuccessfull - please proceed manually (https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)"
    else
        echo "Ansible installed succesfully"
    fi
else
    echo "Ansible is already installed."
fi
echo "============================================="

# Install Docker
if ! check_command docker; then
    echo "Installing Docker..."

    # Change premissions to keyrings directory
    sudo install -m 0755 -d /etc/apt/keyrings

    # Fetch Docker GPG key
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add Docker repository
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update packages and repositories
    sudo apt-get update -y

    # Install Docker with Compose plugin
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-pluginelse

    # Verify installation
    docker_version=$(docker -v)
    if [[ -n $docker_version ]]; then
        echo "Docker installation was unsuccessfull - please proceed manually (https://docs.docker.com/engine/install/)"
    else
        echo "Docker installed succesfully"
    fi
else
    echo "Docker is already installed."
fi

# Post Docker install steps
sudo groupadd docker
sudo usermod -aG docker "$USER"
echo "============================================="

# Install AWS CLI
if ! check_command aws; then
    echo "Installing AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm awscliv2.zip
    rm -rf aws/

    # Verify installation
    aws_version=$(aws --version)
    if [[ -n $aws_version ]]; then
        echo "AWS CLI installation was unsuccessfull - please proceed manually (https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions)"
    else
        echo "AWS CLI installed succesfully"
    fi
else
    echo "AWS CLI is already installed."
fi
echo "============================================="

# Configure AWS CLI
echo "Before proceeding please configure AWS CLI with: aws configure"
echo "Docs: (https://docs.aws.amazon.com/cli/v1/userguide/cli-chap-configure.html)"
echo "============================================="

# Post installation messages
echo "============================================="
echo "Installation of Terraform, Ansible, Docker, Docker Compose, and AWS CLI is complete."
echo "Please log out and log back in to apply Docker group changes. Or open a new shell via: su - \$USER"
echo "In the ../terraform/ directory run: terraform init, to initilize Terraform"
echo "============================================="