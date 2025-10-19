#!/bin/bash

# DevOps Tools Installation Script
# Installs essential DevOps tools for learning environment

set -e

echo "=========================================="
echo "DevOps Tools Installation Script"
echo "=========================================="
echo ""

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

echo "Detected OS: $OS"
echo ""

# Check if Homebrew is installed (macOS)
if [[ $OS == "macos" ]]; then
    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "✓ Homebrew already installed"
    fi
fi

echo ""
echo "Installing DevOps tools..."
echo ""

# Function to install tool
install_tool() {
    local tool=$1
    local install_cmd=$2

    if command -v $tool &> /dev/null; then
        echo "✓ $tool already installed ($(command -v $tool))"
    else
        echo "Installing $tool..."
        eval $install_cmd
        if command -v $tool &> /dev/null; then
            echo "✓ $tool installed successfully"
        else
            echo "✗ Failed to install $tool"
        fi
    fi
}

# Docker
if [[ $OS == "macos" ]]; then
    if ! command -v docker &> /dev/null; then
        echo "Docker: Please install Docker Desktop from https://www.docker.com/products/docker-desktop"
    else
        echo "✓ Docker already installed"
    fi
elif [[ $OS == "linux" ]]; then
    install_tool docker "curl -fsSL https://get.docker.com | sh && sudo usermod -aG docker \$USER"
fi

# kubectl
install_tool kubectl "brew install kubectl"

# kind (Kubernetes in Docker)
install_tool kind "brew install kind"

# Terraform
install_tool terraform "brew install terraform"

# AWS CLI
install_tool aws "brew install awscli"

# Google Cloud SDK (gcloud) - already installed based on earlier check
if ! command -v gcloud &> /dev/null; then
    echo "Installing Google Cloud SDK..."
    if [[ $OS == "macos" ]]; then
        brew install --cask google-cloud-sdk
    fi
else
    echo "✓ gcloud already installed"
fi

# Ansible
install_tool ansible "brew install ansible"

# Helm (Kubernetes package manager)
install_tool helm "brew install helm"

# GitHub CLI
install_tool gh "brew install gh"

# jq (JSON processor)
install_tool jq "brew install jq"

# yq (YAML processor)
install_tool yq "brew install yq"

# stern (multi-pod log tailing for K8s)
install_tool stern "brew install stern"

# k9s (Kubernetes CLI manager)
install_tool k9s "brew install k9s"

# kubectx/kubens (context and namespace switcher)
install_tool kubectx "brew install kubectx"

# terraform-docs
install_tool terraform-docs "brew install terraform-docs"

# tfsec (Terraform security scanner)
install_tool tfsec "brew install tfsec"

# checkov (IaC security scanner)
install_tool checkov "brew install checkov"

# tflint (Terraform linter)
install_tool tflint "brew install tflint"

# trivy (Container security scanner)
install_tool trivy "brew install aquasecurity/trivy/trivy"

# hadolint (Dockerfile linter)
install_tool hadolint "brew install hadolint"

# yamllint
install_tool yamllint "brew install yamllint"

# httpie (better curl)
install_tool http "brew install httpie"

# bat (better cat)
install_tool bat "brew install bat"

# fzf (fuzzy finder)
install_tool fzf "brew install fzf"

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "Installed tools summary:"
command -v docker &> /dev/null && echo "✓ Docker"
command -v kubectl &> /dev/null && echo "✓ kubectl"
command -v kind &> /dev/null && echo "✓ kind"
command -v terraform &> /dev/null && echo "✓ Terraform"
command -v aws &> /dev/null && echo "✓ AWS CLI"
command -v gcloud &> /dev/null && echo "✓ Google Cloud SDK"
command -v ansible &> /dev/null && echo "✓ Ansible"
command -v helm &> /dev/null && echo "✓ Helm"
command -v gh &> /dev/null && echo "✓ GitHub CLI"
command -v jq &> /dev/null && echo "✓ jq"
command -v yq &> /dev/null && echo "✓ yq"
command -v k9s &> /dev/null && echo "✓ k9s"
command -v tfsec &> /dev/null && echo "✓ tfsec"
command -v trivy &> /dev/null && echo "✓ trivy"

echo ""
echo "Next steps:"
echo "1. Restart your shell or run: source ~/.zshrc"
echo "2. Run setup scripts in scripts/sandbox/ to create practice environments"
echo "3. Check docs/ directory for learning guides"
echo ""
echo "For Docker on Linux, you may need to log out and back in for group changes to take effect."
