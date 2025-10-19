# Kubernetes Aliases and Functions
# Author: DevOps Learning Environment
# Purpose: Streamline kubectl workflows and teach K8s best practices

# ============================================================================
# Basic kubectl Aliases
# ============================================================================

alias k='kubectl'
alias kc='kubectl'
alias kube='kubectl'

# Get commands
alias kg='kubectl get'
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods --all-namespaces'
alias kgpw='kubectl get pods -w'
alias kgpwide='kubectl get pods -o wide'
alias kgd='kubectl get deployments'
alias kgs='kubectl get services'
alias kgsvc='kubectl get svc'
alias kgn='kubectl get nodes'
alias kgns='kubectl get namespaces'
alias kgi='kubectl get ingress'
alias kgcm='kubectl get configmaps'
alias kgsec='kubectl get secrets'
alias kgpvc='kubectl get pvc'
alias kgpv='kubectl get pv'

# Describe commands
alias kd='kubectl describe'
alias kdp='kubectl describe pod'
alias kdd='kubectl describe deployment'
alias kds='kubectl describe service'
alias kdn='kubectl describe node'

# Delete commands
alias kdel='kubectl delete'
alias kdelp='kubectl delete pod'
alias kdeld='kubectl delete deployment'
alias kdels='kubectl delete service'

# Logs and exec
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias kex='kubectl exec -it'
alias keti='kubectl exec -it'

# Apply and create
alias ka='kubectl apply -f'
alias kcreate='kubectl create'
alias kdry='kubectl apply --dry-run=client -o yaml'

# Edit and patch
alias ke='kubectl edit'
alias kp='kubectl patch'

# Context and namespace management
alias kctx='kubectl config current-context'
alias kctxs='kubectl config get-contexts'
alias kns='kubectl config set-context --current --namespace'
alias knsls='kubectl get namespaces'

# Top commands (requires metrics-server)
alias ktop='kubectl top'
alias ktopn='kubectl top nodes'
alias ktopp='kubectl top pods'

# Port forwarding
alias kpf='kubectl port-forward'

# Scale
alias kscale='kubectl scale'

# Rollout
alias kroll='kubectl rollout'
alias krollstat='kubectl rollout status'
alias krollhist='kubectl rollout history'
alias krollundo='kubectl rollout undo'

# Config
alias kcfg='kubectl config'
alias kcfgv='kubectl config view'

# ============================================================================
# Learning Functions
# ============================================================================

# Display help for Kubernetes functions
khelp() {
    cat << 'EOF'
Kubernetes Helper Functions - Learning Guide
============================================

Cluster Information:
  kinfo               - Show cluster info and current context
  knodes              - List nodes with resource usage
  kcontexts           - List all contexts and highlight current
  knamespaces         - List namespaces with pod counts

Pod Management:
  kpods [namespace]   - List pods in namespace with status
  kpod <name>         - Get detailed pod information
  kshell <pod>        - Open shell in pod (auto-detects sh/bash)
  kdebug <pod>        - Debug pod issues comprehensively
  klogs <pod> [grep]  - Tail logs with optional filter
  krestart <deploy>   - Restart deployment (recreate pods)

Resource Management:
  kresources          - Show cluster resource usage
  kevents             - Show recent cluster events
  kall [namespace]    - List all resources in namespace
  kwatch <resource>   - Watch resource changes in real-time
  ktop-pods           - Show pods with highest resource usage

Troubleshooting:
  kcrash              - List crashlooping/failing pods
  kpending            - List pending pods with reasons
  kerrors             - Show pods with errors
  kdrain <node>       - Safely drain node for maintenance
  kversion-check      - Check version skew

Deployment & Services:
  kdeploy <name>      - Get deployment with pods and events
  ksvc <name>         - Get service with endpoints
  kscale-deploy <n>   - Scale deployment to n replicas
  kexpose <deploy>    - Expose deployment as service

Development:
  krun-debug          - Run debug pod in cluster
  kport <pod> <port>  - Port-forward with helpful output
  kdiff <file>        - Show diff before applying
  kvalidate <file>    - Validate YAML without applying
  kapply-safe <file>  - Apply with validation and confirmation

Examples:
  kshell mypod              - Open shell in mypod
  klogs mypod error         - Show logs containing 'error'
  kdeploy myapp             - Show deployment details
  kscale-deploy myapp 5     - Scale to 5 replicas
  kport mypod 8080:80       - Forward local 8080 to pod 80

Use --help flag on any function for detailed usage.
EOF
}

# Show cluster information
kinfo() {
    echo "=== Cluster Information ==="
    kubectl cluster-info

    echo ""
    echo "=== Current Context ==="
    kubectl config current-context

    echo ""
    echo "=== Namespaces ==="
    kubectl get namespaces

    echo ""
    echo "=== Nodes ==="
    kubectl get nodes -o wide
}

# List nodes with resource usage
knodes() {
    echo "=== Cluster Nodes ==="
    kubectl get nodes -o custom-columns=\
NAME:.metadata.name,\
STATUS:.status.conditions[-1].type,\
ROLES:.metadata.labels."kubernetes\.io/role",\
VERSION:.status.nodeInfo.kubeletVersion,\
INTERNAL-IP:.status.addresses[0].address

    if kubectl top nodes &>/dev/null; then
        echo ""
        echo "=== Node Resource Usage ==="
        kubectl top nodes
    else
        echo ""
        echo "Note: Install metrics-server to see resource usage (kubectl top nodes)"
    fi
}

# List and switch contexts
kcontexts() {
    echo "=== Available Contexts ==="
    kubectl config get-contexts

    if [[ -n $1 ]]; then
        echo ""
        echo "Switching to context: $1"
        kubectl config use-context $1
    fi
}

# List namespaces with pod counts
knamespaces() {
    echo "=== Namespaces with Pod Counts ==="
    for ns in $(kubectl get ns -o jsonpath='{.items[*].metadata.name}'); do
        local count=$(kubectl get pods -n $ns --no-headers 2>/dev/null | wc -l | xargs)
        printf "%-30s %s pods\n" "$ns" "$count"
    done
}

# Enhanced pod listing
kpods() {
    local namespace=${1:---all-namespaces}

    if [[ $namespace == "--all-namespaces" ]]; then
        echo "=== All Pods ==="
        kubectl get pods --all-namespaces -o wide
    else
        echo "=== Pods in namespace: $namespace ==="
        kubectl get pods -n $namespace -o wide
    fi
}

# Get detailed pod information
kpod() {
    if [[ -z $1 ]]; then
        echo "Usage: kpod <pod-name> [namespace]"
        return 1
    fi

    local pod=$1
    local ns=${2:-$(kubectl config view --minify --output 'jsonpath={..namespace}')}
    local ns=${ns:-default}

    echo "=== Pod: $pod (namespace: $ns) ==="
    kubectl get pod $pod -n $ns -o wide

    echo ""
    echo "=== Pod Details ==="
    kubectl describe pod $pod -n $ns | head -50

    echo ""
    echo "=== Recent Logs ==="
    kubectl logs --tail=20 $pod -n $ns 2>/dev/null || echo "No logs available"
}

# Open shell in pod
kshell() {
    if [[ -z $1 ]]; then
        echo "Usage: kshell <pod> [namespace] [container]"
        echo "Example: kshell mypod default mycontainer"
        return 1
    fi

    local pod=$1
    local ns=${2:-$(kubectl config view --minify --output 'jsonpath={..namespace}')}
    local ns=${ns:-default}
    local container=$3

    local cmd="kubectl exec -it $pod -n $ns"
    [[ -n $container ]] && cmd="$cmd -c $container"

    # Try bash first, then sh
    $cmd -- bash 2>/dev/null || $cmd -- sh
}

# Debug pod comprehensively
kdebug() {
    if [[ -z $1 ]]; then
        echo "Usage: kdebug <pod> [namespace]"
        return 1
    fi

    local pod=$1
    local ns=${2:-$(kubectl config view --minify --output 'jsonpath={..namespace}')}
    local ns=${ns:-default}

    echo "=== Pod Status ==="
    kubectl get pod $pod -n $ns -o wide

    echo ""
    echo "=== Pod Events ==="
    kubectl get events -n $ns --field-selector involvedObject.name=$pod --sort-by='.lastTimestamp' | tail -10

    echo ""
    echo "=== Container Status ==="
    kubectl get pod $pod -n $ns -o jsonpath='{range .status.containerStatuses[*]}{.name}{"\t"}{.state}{"\t"}{.restartCount}{"\n"}{end}' | column -t

    echo ""
    echo "=== Recent Logs ==="
    kubectl logs --tail=50 $pod -n $ns 2>/dev/null || echo "No logs available"

    echo ""
    echo "=== Previous Logs (if crashed) ==="
    kubectl logs --previous --tail=30 $pod -n $ns 2>/dev/null || echo "No previous logs"

    echo ""
    echo "=== Pod YAML (condensed) ==="
    kubectl get pod $pod -n $ns -o yaml | grep -E "(status:|message:|reason:|image:)" | head -20
}

# Tail logs with optional grep
klogs() {
    if [[ -z $1 ]]; then
        echo "Usage: klogs <pod> [filter] [namespace]"
        echo "Example: klogs mypod error"
        return 1
    fi

    local pod=$1
    local filter=$2
    local ns=${3:-$(kubectl config view --minify --output 'jsonpath={..namespace}')}
    local ns=${ns:-default}

    echo "Streaming logs from $pod (namespace: $ns)..."

    if [[ -n $filter ]]; then
        kubectl logs -f $pod -n $ns 2>&1 | grep --color=always -i "$filter"
    else
        kubectl logs -f $pod -n $ns
    fi
}

# Restart deployment
krestart() {
    if [[ -z $1 ]]; then
        echo "Usage: krestart <deployment> [namespace]"
        return 1
    fi

    local deploy=$1
    local ns=${2:-$(kubectl config view --minify --output 'jsonpath={..namespace}')}
    local ns=${ns:-default}

    echo "Restarting deployment: $deploy (namespace: $ns)"
    kubectl rollout restart deployment/$deploy -n $ns
    kubectl rollout status deployment/$deploy -n $ns
}

# Show cluster resource usage
kresources() {
    echo "=== Cluster Resource Usage ==="

    if kubectl top nodes &>/dev/null; then
        echo "Nodes:"
        kubectl top nodes
        echo ""
        echo "Pods (top 10):"
        kubectl top pods --all-namespaces --sort-by=cpu | head -11
    else
        echo "Metrics server not available. Install with:"
        echo "kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
    fi
}

# Show recent events
kevents() {
    local ns=${1:---all-namespaces}

    echo "=== Recent Cluster Events ==="
    if [[ $ns == "--all-namespaces" ]]; then
        kubectl get events --all-namespaces --sort-by='.lastTimestamp' | tail -20
    else
        kubectl get events -n $ns --sort-by='.lastTimestamp' | tail -20
    fi
}

# List all resources in namespace
kall() {
    local ns=${1:-$(kubectl config view --minify --output 'jsonpath={..namespace}')}
    local ns=${ns:-default}

    echo "=== All Resources in namespace: $ns ==="
    kubectl get all -n $ns -o wide
}

# Watch resource changes
kwatch() {
    if [[ -z $1 ]]; then
        echo "Usage: kwatch <resource> [namespace]"
        echo "Example: kwatch pods"
        return 1
    fi

    local resource=$1
    local ns=${2:-$(kubectl config view --minify --output 'jsonpath={..namespace}')}
    local ns=${ns:-default}

    kubectl get $resource -n $ns -w
}

# List crashlooping pods
kcrash() {
    echo "=== CrashLooping Pods ==="
    kubectl get pods --all-namespaces --field-selector=status.phase!=Running,status.phase!=Succeeded
}

# List pending pods with reasons
kpending() {
    echo "=== Pending Pods ==="
    kubectl get pods --all-namespaces --field-selector=status.phase=Pending -o custom-columns=\
NAMESPACE:.metadata.namespace,\
NAME:.metadata.name,\
STATUS:.status.phase,\
REASON:.status.conditions[-1].reason,\
MESSAGE:.status.conditions[-1].message
}

# Show pods with errors
kerrors() {
    echo "=== Pods with Errors ==="
    kubectl get pods --all-namespaces -o wide | grep -E 'Error|CrashLoop|ImagePull|ErrImage'
}

# Get deployment details
kdeploy() {
    if [[ -z $1 ]]; then
        echo "Usage: kdeploy <deployment> [namespace]"
        return 1
    fi

    local deploy=$1
    local ns=${2:-$(kubectl config view --minify --output 'jsonpath={..namespace}')}
    local ns=${ns:-default}

    echo "=== Deployment: $deploy ==="
    kubectl get deployment $deploy -n $ns -o wide

    echo ""
    echo "=== Replica Sets ==="
    kubectl get rs -n $ns -l app=$deploy

    echo ""
    echo "=== Pods ==="
    kubectl get pods -n $ns -l app=$deploy -o wide

    echo ""
    echo "=== Recent Events ==="
    kubectl get events -n $ns --field-selector involvedObject.name=$deploy --sort-by='.lastTimestamp' | tail -5
}

# Get service details
ksvc() {
    if [[ -z $1 ]]; then
        echo "Usage: ksvc <service> [namespace]"
        return 1
    fi

    local svc=$1
    local ns=${2:-$(kubectl config view --minify --output 'jsonpath={..namespace}')}
    local ns=${ns:-default}

    echo "=== Service: $svc ==="
    kubectl get service $svc -n $ns -o wide

    echo ""
    echo "=== Endpoints ==="
    kubectl get endpoints $svc -n $ns

    echo ""
    echo "=== Service Details ==="
    kubectl describe service $svc -n $ns | head -30
}

# Scale deployment
kscale-deploy() {
    if [[ $# -lt 2 ]]; then
        echo "Usage: kscale-deploy <deployment> <replicas> [namespace]"
        echo "Example: kscale-deploy myapp 3"
        return 1
    fi

    local deploy=$1
    local replicas=$2
    local ns=${3:-$(kubectl config view --minify --output 'jsonpath={..namespace}')}
    local ns=${ns:-default}

    echo "Scaling $deploy to $replicas replicas..."
    kubectl scale deployment/$deploy --replicas=$replicas -n $ns
    kubectl rollout status deployment/$deploy -n $ns
}

# Run debug pod
krun-debug() {
    local ns=${1:-default}

    echo "Deploying debug pod in namespace: $ns"
    kubectl run debug-pod --image=nicolaka/netshoot -it --rm -n $ns -- /bin/bash
}

# Port forward with helpful output
kport() {
    if [[ $# -lt 2 ]]; then
        echo "Usage: kport <pod> <local-port:remote-port> [namespace]"
        echo "Example: kport mypod 8080:80"
        return 1
    fi

    local pod=$1
    local ports=$2
    local ns=${3:-$(kubectl config view --minify --output 'jsonpath={..namespace}')}
    local ns=${ns:-default}

    local local_port=$(echo $ports | cut -d: -f1)
    local remote_port=$(echo $ports | cut -d: -f2)

    echo "Port forwarding setup:"
    echo "  Pod: $pod (namespace: $ns)"
    echo "  Local: localhost:$local_port"
    echo "  Remote: $remote_port"
    echo ""
    echo "Access at: http://localhost:$local_port"
    echo "Press Ctrl+C to stop"
    echo ""

    kubectl port-forward $pod -n $ns $ports
}

# Show diff before applying
kdiff() {
    if [[ -z $1 ]]; then
        echo "Usage: kdiff <file>"
        return 1
    fi

    kubectl diff -f $1
}

# Validate YAML without applying
kvalidate() {
    if [[ -z $1 ]]; then
        echo "Usage: kvalidate <file>"
        return 1
    fi

    kubectl apply --dry-run=client -f $1
}

# Apply with confirmation
kapply-safe() {
    if [[ -z $1 ]]; then
        echo "Usage: kapply-safe <file>"
        return 1
    fi

    echo "Validating..."
    kubectl apply --dry-run=client -f $1

    if [[ $? -eq 0 ]]; then
        echo ""
        read -q "REPLY?Apply this configuration? (y/n) "
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            kubectl apply -f $1
        else
            echo "Cancelled."
        fi
    fi
}

# Drain node safely
kdrain() {
    if [[ -z $1 ]]; then
        echo "Usage: kdrain <node>"
        echo "Safely drains node for maintenance"
        return 1
    fi

    local node=$1

    echo "This will drain node: $node"
    echo "Pods will be evicted and rescheduled on other nodes."
    read -q "REPLY?Continue? (y/n) "
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        kubectl drain $node --ignore-daemonsets --delete-emptydir-data
        echo ""
        echo "Node drained. To make it schedulable again, run:"
        echo "kubectl uncordon $node"
    else
        echo "Cancelled."
    fi
}

# Check version skew
kversion-check() {
    echo "=== Kubernetes Version Information ==="
    kubectl version --short

    echo ""
    echo "=== Node Versions ==="
    kubectl get nodes -o custom-columns=\
NAME:.metadata.name,\
VERSION:.status.nodeInfo.kubeletVersion
}

# Expose deployment as service
kexpose() {
    if [[ -z $1 ]]; then
        echo "Usage: kexpose <deployment> [port] [type] [namespace]"
        echo "Example: kexpose myapp 80 LoadBalancer"
        return 1
    fi

    local deploy=$1
    local port=${2:-80}
    local type=${3:-ClusterIP}
    local ns=${4:-$(kubectl config view --minify --output 'jsonpath={..namespace}')}
    local ns=${ns:-default}

    echo "Exposing deployment $deploy as $type service on port $port..."
    kubectl expose deployment $deploy --port=$port --type=$type -n $ns

    echo ""
    kubectl get service $deploy -n $ns
}

# Get pod by label
kgetl() {
    if [[ -z $1 ]]; then
        echo "Usage: kgetl <label-selector> [namespace]"
        echo "Example: kgetl app=myapp"
        return 1
    fi

    local selector=$1
    local ns=${2:-$(kubectl config view --minify --output 'jsonpath={..namespace}')}
    local ns=${ns:-default}

    kubectl get pods -n $ns -l $selector -o wide
}

# Quick pod logs from deployment
klog-deploy() {
    if [[ -z $1 ]]; then
        echo "Usage: klog-deploy <deployment> [namespace]"
        return 1
    fi

    local deploy=$1
    local ns=${2:-$(kubectl config view --minify --output 'jsonpath={..namespace}')}
    local ns=${ns:-default}

    local pod=$(kubectl get pods -n $ns -l app=$deploy -o jsonpath='{.items[0].metadata.name}')

    if [[ -z $pod ]]; then
        echo "No pods found for deployment: $deploy"
        return 1
    fi

    echo "Streaming logs from pod: $pod"
    kubectl logs -f $pod -n $ns
}
