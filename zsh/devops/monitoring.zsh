# Monitoring & Observability Helpers
# Author: DevOps Learning Environment
# Purpose: Streamline monitoring and observability workflows

# ============================================================================
# System Monitoring Aliases
# ============================================================================

alias ports='lsof -i -P | grep LISTEN'
alias connections='lsof -i'
alias bandwidth='nettop -m tcp'
alias processes='ps aux | head -20'

# ============================================================================
# Docker Monitoring
# ============================================================================

alias docker-top='docker stats --no-stream'
alias docker-monitor='docker stats'

# ============================================================================
# Learning Functions
# ============================================================================

# Display help for monitoring functions
monhelp() {
    cat << 'EOF'
Monitoring & Observability Helper Functions
===========================================

System Monitoring:
  sysmon              - Show system resource usage
  portcheck <port>    - Check what's using a port
  netmon              - Monitor network connections
  diskmon             - Show disk usage
  procmon [name]      - Monitor specific process

Log Analysis:
  logtail <file>      - Tail log with highlighting
  logsearch <pattern> - Search across log files
  logerrors [file]    - Find errors in logs
  logstats <file>     - Show log statistics

Application Monitoring:
  apphealth <url>     - Check application health
  apimetrics <url>    - Monitor API endpoint
  webcheck <url>      - Check website status

Performance:
  loadtest <url>      - Simple load test
  benchmark <cmd>     - Benchmark command execution
  profile <cmd>       - Profile command resource usage

Container Monitoring:
  containerstats      - Detailed container statistics
  containerhealth <c> - Check container health
  containerlogs <c>   - Analyze container logs

Examples:
  sysmon                      - View system resources
  portcheck 8080              - See what's on port 8080
  apphealth http://localhost  - Check app health
  logerrors /var/log/app.log  - Find errors in logs

Use --help flag on any function for detailed usage.
EOF
}

# System resource monitoring
sysmon() {
    echo "=== System Resource Monitor ==="
    echo ""
    echo "Date: $(date)"
    echo ""

    echo "=== CPU Usage ==="
    top -l 1 -n 10 -o cpu | grep -A 10 "PID"

    echo ""
    echo "=== Memory Usage ==="
    vm_stat | perl -ne '/page size of (\d+)/ and $size=$1; /Pages\s+([^:]+)[^\d]+(\d+)/ and printf("%-16s % 16.2f Mi\n", "$1:", $2 * $size / 1048576);'

    echo ""
    echo "=== Disk Usage ==="
    df -h | head -10

    echo ""
    echo "=== Load Average ==="
    uptime

    echo ""
    echo "=== Network Connections ==="
    netstat -an | grep ESTABLISHED | wc -l | xargs echo "Established connections:"
}

# Check what's using a port
portcheck() {
    if [[ -z $1 ]]; then
        echo "Usage: portcheck <port>"
        echo ""
        echo "Currently listening ports:"
        lsof -i -P | grep LISTEN | awk '{print $9}' | sort -u
        return 1
    fi

    local port=$1

    echo "=== Checking Port $port ==="
    lsof -i :$port -P

    if [[ $? -ne 0 ]]; then
        echo "No process found on port $port"
    fi
}

# Monitor network connections
netmon() {
    echo "=== Network Connection Monitor ==="
    echo "Press Ctrl+C to stop"
    echo ""

    while true; do
        clear
        echo "=== Active Connections ($(date)) ==="
        netstat -an | grep ESTABLISHED | head -20
        echo ""
        echo "Total Established: $(netstat -an | grep ESTABLISHED | wc -l)"
        echo "Total Listening: $(lsof -i -P | grep LISTEN | wc -l)"
        sleep 2
    done
}

# Disk usage monitoring
diskmon() {
    echo "=== Disk Usage Monitor ==="
    echo ""

    echo "Filesystem usage:"
    df -h

    echo ""
    echo "Largest directories in current path:"
    du -sh */ 2>/dev/null | sort -hr | head -10

    echo ""
    echo "Disk I/O:"
    iostat -d 1 2 | tail -n +3
}

# Monitor specific process
procmon() {
    if [[ -z $1 ]]; then
        echo "Usage: procmon <process-name>"
        echo ""
        echo "Running processes:"
        ps aux | head -20
        return 1
    fi

    local proc=$1

    echo "=== Monitoring Process: $proc ==="
    echo "Press Ctrl+C to stop"
    echo ""

    while true; do
        clear
        echo "=== Process: $proc ($(date)) ==="
        ps aux | grep -i $proc | grep -v grep
        echo ""
        echo "CPU and Memory over time:"
        top -l 1 -stats pid,command,cpu,mem | grep -i $proc | head -5
        sleep 2
    done
}

# Tail log with highlighting
logtail() {
    if [[ -z $1 ]]; then
        echo "Usage: logtail <log-file>"
        return 1
    fi

    local file=$1

    if [[ ! -f $file ]]; then
        echo "File not found: $file"
        return 1
    fi

    echo "Tailing log: $file"
    echo "Highlighting: ERROR (red), WARN (yellow), INFO (green)"
    echo ""

    tail -f $file | sed -e 's/ERROR/\x1b[31mERROR\x1b[0m/g' \
                         -e 's/WARN/\x1b[33mWARN\x1b[0m/g' \
                         -e 's/INFO/\x1b[32mINFO\x1b[0m/g'
}

# Search across log files
logsearch() {
    if [[ -z $1 ]]; then
        echo "Usage: logsearch <pattern> [directory]"
        echo "Example: logsearch 'error' /var/log"
        return 1
    fi

    local pattern=$1
    local dir=${2:-.}

    echo "Searching for '$pattern' in $dir"
    echo ""

    find $dir -type f -name "*.log" -exec grep -l "$pattern" {} \; 2>/dev/null | while read file; do
        echo "=== $file ==="
        grep -n "$pattern" "$file" | head -5
        echo ""
    done
}

# Find errors in logs
logerrors() {
    local file=${1:-"*.log"}

    echo "=== Finding Errors in Logs ==="
    echo ""

    if [[ -f $file ]]; then
        echo "File: $file"
        grep -i "error\|exception\|fatal\|critical" $file | tail -20
    else
        echo "Searching all .log files in current directory"
        grep -r -i "error\|exception\|fatal\|critical" --include="*.log" . | tail -20
    fi
}

# Show log statistics
logstats() {
    if [[ -z $1 ]]; then
        echo "Usage: logstats <log-file>"
        return 1
    fi

    local file=$1

    if [[ ! -f $file ]]; then
        echo "File not found: $file"
        return 1
    fi

    echo "=== Log Statistics for $file ==="
    echo ""
    echo "Total lines: $(wc -l < $file)"
    echo "File size: $(du -h $file | cut -f1)"
    echo ""
    echo "Log levels:"
    echo "  ERROR: $(grep -c ERROR $file 2>/dev/null || echo 0)"
    echo "  WARN: $(grep -c WARN $file 2>/dev/null || echo 0)"
    echo "  INFO: $(grep -c INFO $file 2>/dev/null || echo 0)"
    echo "  DEBUG: $(grep -c DEBUG $file 2>/dev/null || echo 0)"
    echo ""
    echo "First entry: $(head -1 $file)"
    echo "Last entry: $(tail -1 $file)"
}

# Check application health
apphealth() {
    if [[ -z $1 ]]; then
        echo "Usage: apphealth <url> [interval]"
        echo "Example: apphealth http://localhost:8080/health 5"
        return 1
    fi

    local url=$1
    local interval=${2:-5}

    echo "=== Application Health Monitor ==="
    echo "URL: $url"
    echo "Interval: ${interval}s"
    echo "Press Ctrl+C to stop"
    echo ""

    while true; do
        local start=$(date +%s)
        local http_code=$(curl -s -o /dev/null -w "%{http_code}" $url)
        local end=$(date +%s)
        local duration=$((end - start))

        local timestamp=$(date "+%Y-%m-%d %H:%M:%S")

        if [[ $http_code -eq 200 ]]; then
            echo "[$timestamp] ✓ Healthy - HTTP $http_code - ${duration}s response time"
        else
            echo "[$timestamp] ✗ Unhealthy - HTTP $http_code - ${duration}s response time"
        fi

        sleep $interval
    done
}

# Monitor API endpoint
apimetrics() {
    if [[ -z $1 ]]; then
        echo "Usage: apimetrics <url>"
        return 1
    fi

    local url=$1

    echo "=== API Metrics for $url ==="
    echo ""

    # Make request and show metrics
    curl -w "\n\nPerformance Metrics:\n\
    DNS Lookup Time:     %{time_namelookup}s\n\
    TCP Connection Time: %{time_connect}s\n\
    TLS Handshake Time:  %{time_appconnect}s\n\
    Time to First Byte:  %{time_starttransfer}s\n\
    Total Time:          %{time_total}s\n\
    \n\
    HTTP Code:           %{http_code}\n\
    Response Size:       %{size_download} bytes\n" \
    -o /dev/null -s $url
}

# Check website status
webcheck() {
    if [[ -z $1 ]]; then
        echo "Usage: webcheck <url>"
        return 1
    fi

    local url=$1

    echo "=== Website Check: $url ==="
    echo ""

    # HTTP status
    local status=$(curl -s -o /dev/null -w "%{http_code}" $url)
    echo "HTTP Status: $status"

    # Response time
    local response_time=$(curl -s -o /dev/null -w "%{time_total}" $url)
    echo "Response Time: ${response_time}s"

    # SSL certificate (if HTTPS)
    if [[ $url =~ ^https ]]; then
        echo ""
        echo "SSL Certificate:"
        echo | openssl s_client -servername $(echo $url | sed 's|https://||' | cut -d/ -f1) -connect $(echo $url | sed 's|https://||' | cut -d/ -f1):443 2>/dev/null | openssl x509 -noout -dates
    fi

    # DNS lookup
    echo ""
    echo "DNS Resolution:"
    host $(echo $url | sed 's|https\?://||' | cut -d/ -f1)
}

# Simple load test
loadtest() {
    if [[ -z $1 ]]; then
        echo "Usage: loadtest <url> [requests] [concurrency]"
        echo "Example: loadtest http://localhost:8080 100 10"
        return 1
    fi

    local url=$1
    local requests=${2:-100}
    local concurrency=${3:-10}

    if ! command -v ab &> /dev/null; then
        echo "Apache Bench (ab) not installed"
        echo "Install with: brew install apache2"
        echo ""
        echo "Alternative: Using curl for simple test"

        echo "Running $requests requests to $url..."
        for i in $(seq 1 $requests); do
            curl -s -o /dev/null -w "%{http_code} - %{time_total}s\n" $url
        done
        return 0
    fi

    echo "=== Load Test ==="
    echo "URL: $url"
    echo "Requests: $requests"
    echo "Concurrency: $concurrency"
    echo ""

    ab -n $requests -c $concurrency $url
}

# Benchmark command
benchmark() {
    if [[ -z $1 ]]; then
        echo "Usage: benchmark <command>"
        echo "Example: benchmark 'npm test'"
        return 1
    fi

    local cmd=$@
    local runs=5

    echo "=== Benchmarking Command ==="
    echo "Command: $cmd"
    echo "Runs: $runs"
    echo ""

    for i in $(seq 1 $runs); do
        echo "Run $i:"
        time eval $cmd
        echo ""
    done
}

# Profile command resource usage
profile() {
    if [[ -z $1 ]]; then
        echo "Usage: profile <command>"
        echo "Example: profile 'npm run build'"
        return 1
    fi

    local cmd=$@

    echo "=== Profiling Command ==="
    echo "Command: $cmd"
    echo ""

    /usr/bin/time -l $cmd
}

# Detailed container statistics
containerstats() {
    echo "=== Container Statistics ==="
    echo ""

    if ! docker ps -q | grep -q .; then
        echo "No running containers"
        return 0
    fi

    docker stats --no-stream --format "table {{.Name}}\t{{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}"

    echo ""
    echo "Container processes:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
}

# Check container health
containerhealth() {
    if [[ -z $1 ]]; then
        echo "Usage: containerhealth <container>"
        return 1
    fi

    local container=$1

    echo "=== Container Health: $container ==="
    echo ""

    # Container status
    docker inspect $container --format='
    Status: {{.State.Status}}
    Running: {{.State.Running}}
    Started: {{.State.StartedAt}}
    Health: {{.State.Health.Status}}
    RestartCount: {{.RestartCount}}
    '

    # Resource usage
    echo ""
    echo "Resource Usage:"
    docker stats --no-stream $container

    # Recent logs
    echo ""
    echo "Recent Logs (last 20 lines):"
    docker logs --tail 20 $container
}

# Analyze container logs
containerlogs() {
    if [[ -z $1 ]]; then
        echo "Usage: containerlogs <container>"
        return 1
    fi

    local container=$1

    echo "=== Analyzing Logs for $container ==="
    echo ""

    local logfile=$(mktemp)
    docker logs $container > $logfile 2>&1

    echo "Total log lines: $(wc -l < $logfile)"
    echo ""

    echo "Log level breakdown:"
    echo "  ERRORS: $(grep -i error $logfile | wc -l)"
    echo "  WARNINGS: $(grep -i warn $logfile | wc -l)"
    echo "  INFO: $(grep -i info $logfile | wc -l)"

    echo ""
    echo "Recent errors:"
    grep -i error $logfile | tail -5

    rm $logfile
}
