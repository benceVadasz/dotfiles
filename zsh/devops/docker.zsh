# Docker Aliases and Functions
# Author: DevOps Learning Environment
# Purpose: Streamline Docker workflows and teach best practices

# ============================================================================
# Basic Docker Aliases
# ============================================================================

alias d='docker'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dpsaq='docker ps -a -q'
alias di='docker images'
alias dia='docker images -a'
alias drm='docker rm'
alias drmi='docker rmi'
alias dex='docker exec -it'
alias dins='docker inspect'
alias dlog='docker logs'
alias dlogf='docker logs -f'
alias dpull='docker pull'
alias dpush='docker push'
alias dtag='docker tag'
alias dnet='docker network ls'
alias dvol='docker volume ls'

# ============================================================================
# Docker Compose Aliases
# ============================================================================

alias dc='docker-compose'
alias dcu='docker-compose up'
alias dcud='docker-compose up -d'
alias dcd='docker-compose down'
alias dcb='docker-compose build'
alias dck='docker-compose kill'
alias dcr='docker-compose restart'
alias dcl='docker-compose logs'
alias dclf='docker-compose logs -f'
alias dcps='docker-compose ps'
alias dcpull='docker-compose pull'
alias dcstart='docker-compose start'
alias dcstop='docker-compose stop'

# ============================================================================
# Docker System Commands
# ============================================================================

alias dsys='docker system df'
alias dprune='docker system prune'
alias dpruneall='docker system prune -a'
alias dstats='docker stats'
alias dinfo='docker info'
alias dversion='docker version'

# ============================================================================
# Learning Functions
# ============================================================================

# Display help for Docker functions
dhelp() {
    cat << 'EOF'
Docker Helper Functions - Learning Guide
========================================

Container Management:
  dclean              - Remove all stopped containers
  dclean-all          - Remove ALL containers (running + stopped)
  dkillall            - Stop all running containers
  dlogs <container>   - Tail logs with optional grep filter
  dshell <container>  - Open shell in running container
  drun <image>        - Run container interactively with best practices

Image Management:
  dclean-images       - Remove dangling images
  dclean-images-all   - Remove ALL unused images
  dbuild <tag>        - Build image with best practices check
  dscan <image>       - Scan image for vulnerabilities (if trivy installed)

Network & Volume:
  dnet-inspect <net>  - Inspect network with formatted output
  dvol-inspect <vol>  - Inspect volume with formatted output
  dnet-clean          - Remove unused networks
  dvol-clean          - Remove unused volumes

Learning:
  ddebug <container>  - Debug container issues
  dsize <container>   - Show container size
  dports              - Show all port mappings
  dtop                - Show running containers with resource usage

Examples:
  dlogs myapp error     - Show logs containing 'error'
  dshell myapp          - Open bash/sh in myapp container
  dbuild myapp:v1.0     - Build with tag and validation

Use --help flag on any function for detailed usage.
EOF
}

# Clean up stopped containers
dclean() {
    echo "Removing stopped containers..."
    local stopped=$(docker ps -a -q -f status=exited)
    if [[ -z "$stopped" ]]; then
        echo "No stopped containers to remove."
    else
        docker rm $stopped
        echo "Cleaned up $(echo $stopped | wc -w) stopped containers."
    fi
}

# Clean up ALL containers (dangerous!)
dclean-all() {
    echo "WARNING: This will remove ALL containers (running and stopped)!"
    read -q "REPLY?Are you sure? (y/n) "
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker rm -f $(docker ps -a -q) 2>/dev/null && echo "All containers removed." || echo "No containers to remove."
    else
        echo "Cancelled."
    fi
}

# Stop all running containers
dkillall() {
    echo "Stopping all running containers..."
    local running=$(docker ps -q)
    if [[ -z "$running" ]]; then
        echo "No running containers."
    else
        docker stop $running
        echo "Stopped $(echo $running | wc -w) containers."
    fi
}

# Tail logs with optional grep filter
dlogs() {
    if [[ -z $1 ]]; then
        echo "Usage: dlogs <container> [filter]"
        echo "Example: dlogs myapp error"
        return 1
    fi

    local container=$1
    local filter=$2

    if [[ -n $filter ]]; then
        docker logs -f $container 2>&1 | grep --color=always -i $filter
    else
        docker logs -f $container
    fi
}

# Open shell in running container
dshell() {
    if [[ -z $1 ]]; then
        echo "Usage: dshell <container> [shell]"
        echo "Example: dshell myapp bash"
        return 1
    fi

    local container=$1
    local shell=${2:-bash}

    # Try bash first, fall back to sh
    docker exec -it $container $shell 2>/dev/null || docker exec -it $container sh
}

# Run container interactively with best practices
drun() {
    if [[ -z $1 ]]; then
        echo "Usage: drun <image> [command]"
        echo "Runs container with: --rm (auto-remove), -it (interactive), current dir mounted"
        echo "Example: drun ubuntu:latest"
        return 1
    fi

    local image=$1
    shift

    echo "Running $image interactively (auto-remove on exit)..."
    docker run --rm -it -v $(pwd):/workspace -w /workspace $image "$@"
}

# Clean dangling images
dclean-images() {
    echo "Removing dangling images..."
    local dangling=$(docker images -f "dangling=true" -q)
    if [[ -z "$dangling" ]]; then
        echo "No dangling images to remove."
    else
        docker rmi $dangling
        echo "Cleaned up $(echo $dangling | wc -w) dangling images."
    fi
}

# Clean ALL unused images (dangerous!)
dclean-images-all() {
    echo "WARNING: This will remove ALL unused images!"
    read -q "REPLY?Are you sure? (y/n) "
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker image prune -a -f
        echo "All unused images removed."
    else
        echo "Cancelled."
    fi
}

# Build with best practices check
dbuild() {
    if [[ -z $1 ]]; then
        echo "Usage: dbuild <tag> [dockerfile]"
        echo "Example: dbuild myapp:v1.0 ./Dockerfile"
        return 1
    fi

    local tag=$1
    local dockerfile=${2:-Dockerfile}

    if [[ ! -f $dockerfile ]]; then
        echo "Error: Dockerfile not found at $dockerfile"
        return 1
    fi

    echo "Building image: $tag"
    echo "Dockerfile: $dockerfile"
    echo ""

    # Check for common issues
    if ! grep -q "^FROM" $dockerfile; then
        echo "WARNING: No FROM instruction found in Dockerfile!"
    fi

    # Build with no cache option
    echo "Build options:"
    echo "  1) Normal build"
    echo "  2) No cache (--no-cache)"
    read "choice?Select option (1-2): "

    case $choice in
        2)
            docker build --no-cache -t $tag -f $dockerfile .
            ;;
        *)
            docker build -t $tag -f $dockerfile .
            ;;
    esac

    if [[ $? -eq 0 ]]; then
        echo ""
        echo "Build successful! Image tagged as: $tag"
        docker images | grep $(echo $tag | cut -d: -f1)
    fi
}

# Debug container issues
ddebug() {
    if [[ -z $1 ]]; then
        echo "Usage: ddebug <container>"
        echo "Shows comprehensive debug info for a container"
        return 1
    fi

    local container=$1

    echo "=== Container Status ==="
    docker ps -a --filter name=$container --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

    echo ""
    echo "=== Recent Logs (last 50 lines) ==="
    docker logs --tail 50 $container

    echo ""
    echo "=== Container Inspect ==="
    docker inspect $container --format='
    Image: {{.Config.Image}}
    State: {{.State.Status}}
    Started: {{.State.StartedAt}}
    RestartCount: {{.RestartCount}}
    ExitCode: {{.State.ExitCode}}
    Ports: {{range $p, $conf := .NetworkSettings.Ports}}{{$p}} -> {{(index $conf 0).HostPort}} {{end}}
    Networks: {{range $net, $conf := .NetworkSettings.Networks}}{{$net}} {{end}}
    '
}

# Show container size
dsize() {
    if [[ -z $1 ]]; then
        echo "All container sizes:"
        docker ps -a --format "table {{.Names}}\t{{.Size}}"
    else
        docker ps -a --filter name=$1 --format "table {{.Names}}\t{{.Size}}"
    fi
}

# Show all port mappings
dports() {
    echo "Container port mappings:"
    docker ps --format "table {{.Names}}\t{{.Ports}}"
}

# Show running containers with resource usage
dtop() {
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
}

# Network inspection with formatting
dnet-inspect() {
    if [[ -z $1 ]]; then
        echo "Usage: dnet-inspect <network>"
        docker network ls
        return 1
    fi

    docker network inspect $1 --format='
    Network: {{.Name}}
    Driver: {{.Driver}}
    Scope: {{.Scope}}
    Subnet: {{range .IPAM.Config}}{{.Subnet}}{{end}}
    Gateway: {{range .IPAM.Config}}{{.Gateway}}{{end}}
    Containers: {{range $k, $v := .Containers}}
      - {{$v.Name}} ({{$v.IPv4Address}}){{end}}
    '
}

# Volume inspection with formatting
dvol-inspect() {
    if [[ -z $1 ]]; then
        echo "Usage: dvol-inspect <volume>"
        docker volume ls
        return 1
    fi

    docker volume inspect $1 --format='
    Volume: {{.Name}}
    Driver: {{.Driver}}
    Mountpoint: {{.Mountpoint}}
    Created: {{.CreatedAt}}
    '
}

# Clean unused networks
dnet-clean() {
    echo "Removing unused networks..."
    docker network prune -f
}

# Clean unused volumes
dvol-clean() {
    echo "WARNING: This will remove all unused volumes!"
    read -q "REPLY?Are you sure? (y/n) "
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker volume prune -f
        echo "Unused volumes removed."
    else
        echo "Cancelled."
    fi
}

# Scan image for vulnerabilities (requires trivy)
dscan() {
    if [[ -z $1 ]]; then
        echo "Usage: dscan <image>"
        echo "Scans image for vulnerabilities using trivy"
        echo "Install trivy: brew install aquasecurity/trivy/trivy"
        return 1
    fi

    if ! command -v trivy &> /dev/null; then
        echo "Trivy not installed. Install with: brew install aquasecurity/trivy/trivy"
        return 1
    fi

    trivy image $1
}

# Show Docker disk usage with details
ddisk() {
    echo "=== Docker Disk Usage ==="
    docker system df -v
}

# Complete cleanup (interactive)
dcleanup() {
    echo "Docker Complete Cleanup Wizard"
    echo "==============================="
    echo ""
    echo "This will help you clean up Docker resources safely."
    echo ""

    # Stopped containers
    local stopped=$(docker ps -a -q -f status=exited | wc -l | xargs)
    echo "Stopped containers: $stopped"
    if [[ $stopped -gt 0 ]]; then
        read -q "REPLY?Remove stopped containers? (y/n) "
        echo
        [[ $REPLY =~ ^[Yy]$ ]] && dclean
    fi

    # Dangling images
    local dangling=$(docker images -f "dangling=true" -q | wc -l | xargs)
    echo ""
    echo "Dangling images: $dangling"
    if [[ $dangling -gt 0 ]]; then
        read -q "REPLY?Remove dangling images? (y/n) "
        echo
        [[ $REPLY =~ ^[Yy]$ ]] && dclean-images
    fi

    # Unused networks
    echo ""
    read -q "REPLY?Remove unused networks? (y/n) "
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && dnet-clean

    echo ""
    echo "Cleanup complete! Current disk usage:"
    docker system df
}

# Export container as image
dexport() {
    if [[ $# -lt 2 ]]; then
        echo "Usage: dexport <container> <image-name:tag>"
        echo "Example: dexport mycontainer myimage:v1.0"
        return 1
    fi

    local container=$1
    local image=$2

    echo "Exporting container $container as image $image..."
    docker commit $container $image

    if [[ $? -eq 0 ]]; then
        echo "Successfully created image: $image"
        docker images | grep $(echo $image | cut -d: -f1)
    fi
}

# Quick container restart
drestart() {
    if [[ -z $1 ]]; then
        echo "Usage: drestart <container>"
        return 1
    fi

    echo "Restarting container: $1"
    docker restart $1
    docker ps --filter name=$1
}

# Monitor container logs in real-time with timestamp
dwatch() {
    if [[ -z $1 ]]; then
        echo "Usage: dwatch <container>"
        echo "Monitor container logs in real-time with timestamps"
        return 1
    fi

    docker logs -f --timestamps $1
}
