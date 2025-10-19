#!/bin/bash

# Kubernetes Local Cluster Setup
# Creates a local Kind cluster for learning and testing

set -e

CLUSTER_NAME=${1:-"devops-learning"}

echo "=========================================="
echo "Kubernetes Local Cluster Setup"
echo "=========================================="
echo ""

# Check if kind is installed
if ! command -v kind &> /dev/null; then
    echo "Error: kind is not installed"
    echo "Install with: brew install kind"
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed"
    echo "Install with: brew install kubectl"
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "Error: Docker is not running"
    echo "Please start Docker Desktop and try again"
    exit 1
fi

echo "Creating Kind cluster: $CLUSTER_NAME"
echo ""

# Create kind cluster with custom configuration
cat <<EOF | kind create cluster --name $CLUSTER_NAME --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
- role: worker
- role: worker
EOF

if [[ $? -ne 0 ]]; then
    echo "Failed to create cluster"
    exit 1
fi

echo ""
echo "✓ Cluster created successfully!"
echo ""

# Wait for cluster to be ready
echo "Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=120s

echo ""
echo "Installing essential add-ons..."
echo ""

# Install metrics-server for resource monitoring
echo "Installing metrics-server..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Patch metrics-server for kind
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'

# Install nginx ingress controller
echo "Installing nginx ingress controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait for ingress controller
echo "Waiting for ingress controller..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

echo ""
echo "=========================================="
echo "Cluster Setup Complete!"
echo "=========================================="
echo ""
echo "Cluster name: $CLUSTER_NAME"
echo "Nodes:"
kubectl get nodes
echo ""
echo "Namespaces:"
kubectl get namespaces
echo ""
echo "Installed components:"
echo "  ✓ metrics-server (for kubectl top)"
echo "  ✓ nginx-ingress (for ingress resources)"
echo ""
echo "Quick start commands:"
echo "  kubectl get nodes              # View cluster nodes"
echo "  kubectl get pods -A            # View all pods"
echo "  kubectl create namespace test  # Create test namespace"
echo "  k9s                            # Launch K9s (if installed)"
echo ""
echo "Create a test deployment:"
echo "  kubectl create deployment nginx --image=nginx"
echo "  kubectl expose deployment nginx --port=80 --type=LoadBalancer"
echo ""
echo "Delete cluster when done:"
echo "  kind delete cluster --name $CLUSTER_NAME"
echo ""
echo "Happy learning! 🚀"
