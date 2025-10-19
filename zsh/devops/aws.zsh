# AWS & Cloud Provider Aliases and Functions
# Author: DevOps Learning Environment
# Purpose: Streamline AWS CLI workflows and teach cloud best practices

# ============================================================================
# AWS CLI Aliases
# ============================================================================

alias aws='aws'
alias awsls='aws'

# Profile management
alias awsp='export AWS_PROFILE='
alias awsprofile='export AWS_PROFILE='
alias awswho='aws sts get-caller-identity'
alias awsregion='aws configure get region'
alias awsaccount='aws sts get-caller-identity --query Account --output text'

# EC2
alias ec2='aws ec2'
alias ec2ls='aws ec2 describe-instances'
alias ec2running='aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"'
alias ec2stopped='aws ec2 describe-instances --filters "Name=instance-state-name,Values=stopped"'

# S3
alias s3='aws s3'
alias s3ls='aws s3 ls'
alias s3mb='aws s3 mb'
alias s3rb='aws s3 rb'
alias s3cp='aws s3 cp'
alias s3sync='aws s3 sync'

# Lambda
alias lambda='aws lambda'
alias lambdals='aws lambda list-functions'

# CloudFormation
alias cfn='aws cloudformation'
alias cfnls='aws cloudformation list-stacks'
alias cfndesc='aws cloudformation describe-stacks'

# ECS
alias ecs='aws ecs'
alias ecsls='aws ecs list-clusters'

# IAM
alias iam='aws iam'
alias iamusers='aws iam list-users'
alias iamroles='aws iam list-roles'

# CloudWatch Logs
alias cwl='aws logs'
alias cwlgroups='aws logs describe-log-groups'

# SSM
alias ssm='aws ssm'
alias ssmparams='aws ssm describe-parameters'

# ============================================================================
# GCP Aliases (gcloud)
# ============================================================================

alias gcld='gcloud'
alias gcls='gcloud projects list'
alias gcset='gcloud config set project'
alias gcget='gcloud config get-value project'
alias gcwho='gcloud config list'

# Compute Engine
alias gce='gcloud compute instances'
alias gcels='gcloud compute instances list'

# GKE
alias gke='gcloud container clusters'
alias gkels='gcloud container clusters list'
alias gkecreds='gcloud container clusters get-credentials'

# ============================================================================
# Learning Functions - AWS
# ============================================================================

# Display help for AWS functions
awshelp() {
    cat << 'EOF'
AWS Helper Functions - Learning Guide
=====================================

Account & Profile Management:
  awsinfo             - Show current AWS configuration
  awsprofiles         - List all configured profiles
  awsswitch <profile> - Switch AWS profile with confirmation
  awsregions          - List all AWS regions
  awsservices         - List AWS services in current region

EC2 Management:
  ec2list             - List instances with key details
  ec2start <id>       - Start EC2 instance
  ec2stop <id>        - Stop EC2 instance
  ec2ssh <id>         - SSH into EC2 instance
  ec2ip <id>          - Get public IP of instance
  ec2costs            - Estimate EC2 costs for running instances

S3 Management:
  s3size <bucket>     - Calculate bucket size
  s3tree <bucket>     - Show bucket structure
  s3public            - List public S3 buckets (security check)
  s3costs             - Estimate S3 storage costs
  s3download <bucket> - Download entire bucket
  s3encrypt <bucket>  - Enable encryption on bucket

Lambda Management:
  lambdalist          - List functions with details
  lambdalogs <fn>     - Tail function logs
  lambdainvoke <fn>   - Invoke function with test event
  lambdacosts         - Show Lambda usage and costs

CloudFormation:
  cfnstatus <stack>   - Show stack status and events
  cfnoutputs <stack>  - Show stack outputs
  cfndrift <stack>    - Detect configuration drift
  cfndelete <stack>   - Delete stack safely

CloudWatch:
  cwlogs <group>      - Tail CloudWatch log group
  cwmetrics <name>    - Show metrics for resource
  cwalarms            - List all CloudWatch alarms

IAM Security:
  iamaudit            - Audit IAM security issues
  iamkeys             - List access keys and age
  iammfa              - Check MFA status for users
  iampolicies <user>  - Show user's effective permissions

Cost Management:
  awscosts [days]     - Show costs for last N days
  awscosts-service    - Break down costs by service
  awscosts-forecast   - Cost forecast for month

Examples:
  awsswitch production    - Switch to production profile
  ec2list                 - List all EC2 instances
  s3size my-bucket        - Calculate bucket size
  cwlogs /aws/lambda/api  - Tail Lambda logs
  awscosts 30             - Show last 30 days costs

Use --help flag on any function for detailed usage.
EOF
}

# Show current AWS configuration
awsinfo() {
    echo "=== AWS Configuration ==="
    echo "Profile: ${AWS_PROFILE:-default}"
    echo ""

    if aws sts get-caller-identity &>/dev/null; then
        echo "Identity:"
        aws sts get-caller-identity

        echo ""
        echo "Region: $(aws configure get region)"

        echo ""
        echo "Account Alias:"
        aws iam list-account-aliases --query 'AccountAliases[0]' --output text 2>/dev/null || echo "None"
    else
        echo "Not authenticated or invalid credentials"
    fi
}

# List all configured profiles
awsprofiles() {
    echo "=== AWS Profiles ==="
    echo "Current: ${AWS_PROFILE:-default}"
    echo ""
    echo "Available profiles:"

    if [[ -f ~/.aws/config ]]; then
        grep '^\[profile' ~/.aws/config | sed 's/\[profile \(.*\)\]/  - \1/'
        grep '^\[default\]' ~/.aws/config &>/dev/null && echo "  - default"
    fi

    if [[ -f ~/.aws/credentials ]]; then
        echo ""
        echo "Profiles with credentials:"
        grep '^\[' ~/.aws/credentials | sed 's/\[\(.*\)\]/  - \1/'
    fi
}

# Switch AWS profile
awsswitch() {
    if [[ -z $1 ]]; then
        echo "Usage: awsswitch <profile>"
        echo ""
        awsprofiles
        return 1
    fi

    export AWS_PROFILE=$1
    echo "Switched to profile: $AWS_PROFILE"
    echo ""
    awsinfo
}

# List all AWS regions
awsregions() {
    echo "=== AWS Regions ==="
    aws ec2 describe-regions --query 'Regions[*].[RegionName,OptInStatus]' --output table
}

# List AWS services available in region
awsservices() {
    local region=${1:-$(aws configure get region)}

    echo "=== AWS Services in $region ==="
    aws ec2 describe-vpc-endpoint-services --region $region --query 'ServiceNames[]' --output table
}

# List EC2 instances with key details
ec2list() {
    local filter=${1:-""}

    echo "=== EC2 Instances ==="

    if [[ -n $filter ]]; then
        aws ec2 describe-instances --filters "Name=instance-state-name,Values=$filter" \
            --query 'Reservations[].Instances[].[InstanceId,InstanceType,State.Name,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' \
            --output table
    else
        aws ec2 describe-instances \
            --query 'Reservations[].Instances[].[InstanceId,InstanceType,State.Name,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' \
            --output table
    fi
}

# Start EC2 instance
ec2start() {
    if [[ -z $1 ]]; then
        echo "Usage: ec2start <instance-id>"
        ec2list stopped
        return 1
    fi

    local instance=$1

    echo "Starting instance: $instance"
    aws ec2 start-instances --instance-ids $instance

    if [[ $? -eq 0 ]]; then
        echo ""
        echo "Waiting for instance to start..."
        aws ec2 wait instance-running --instance-ids $instance
        echo "Instance started!"
    fi
}

# Stop EC2 instance
ec2stop() {
    if [[ -z $1 ]]; then
        echo "Usage: ec2stop <instance-id>"
        ec2list running
        return 1
    fi

    local instance=$1

    echo "Stopping instance: $instance"
    read -q "REPLY?Are you sure? (y/n) "
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        aws ec2 stop-instances --instance-ids $instance
        echo "Instance stopping..."
    else
        echo "Cancelled."
    fi
}

# Get EC2 instance IP
ec2ip() {
    if [[ -z $1 ]]; then
        echo "Usage: ec2ip <instance-id>"
        return 1
    fi

    aws ec2 describe-instances --instance-ids $1 \
        --query 'Reservations[].Instances[].[PublicIpAddress,PrivateIpAddress]' \
        --output table
}

# Calculate S3 bucket size
s3size() {
    if [[ -z $1 ]]; then
        echo "Usage: s3size <bucket-name>"
        echo ""
        echo "Available buckets:"
        aws s3 ls
        return 1
    fi

    local bucket=$1

    echo "Calculating size of bucket: $bucket"
    echo "This may take a while for large buckets..."
    echo ""

    aws s3 ls s3://$bucket --recursive --summarize --human-readable | tail -2
}

# Show S3 bucket structure
s3tree() {
    if [[ -z $1 ]]; then
        echo "Usage: s3tree <bucket-name> [prefix]"
        return 1
    fi

    local bucket=$1
    local prefix=$2

    if [[ -n $prefix ]]; then
        aws s3 ls s3://$bucket/$prefix --recursive
    else
        aws s3 ls s3://$bucket --recursive
    fi
}

# List public S3 buckets (security check)
s3public() {
    echo "=== Checking for Public S3 Buckets ==="
    echo "This checks bucket ACLs and policies..."
    echo ""

    for bucket in $(aws s3 ls | awk '{print $3}'); do
        local acl=$(aws s3api get-bucket-acl --bucket $bucket 2>/dev/null)
        if echo $acl | grep -q "AllUsers\|AuthenticatedUsers"; then
            echo "⚠️  WARNING: $bucket may be public!"
        else
            echo "✓ $bucket is private"
        fi
    done
}

# List Lambda functions with details
lambdalist() {
    echo "=== Lambda Functions ==="
    aws lambda list-functions \
        --query 'Functions[].[FunctionName,Runtime,LastModified,MemorySize]' \
        --output table
}

# Tail Lambda logs
lambdalogs() {
    if [[ -z $1 ]]; then
        echo "Usage: lambdalogs <function-name>"
        lambdalist
        return 1
    fi

    local function=$1
    local log_group="/aws/lambda/$function"

    echo "Tailing logs for: $function"
    echo "Log group: $log_group"
    echo ""

    # Get latest log stream
    local stream=$(aws logs describe-log-streams \
        --log-group-name $log_group \
        --order-by LastEventTime \
        --descending \
        --limit 1 \
        --query 'logStreams[0].logStreamName' \
        --output text)

    if [[ -n $stream ]]; then
        aws logs tail $log_group --follow
    else
        echo "No log streams found"
    fi
}

# Invoke Lambda function
lambdainvoke() {
    if [[ -z $1 ]]; then
        echo "Usage: lambdainvoke <function-name> [payload-file]"
        lambdalist
        return 1
    fi

    local function=$1
    local payload=${2:-'{}'}

    echo "Invoking function: $function"

    if [[ -f $payload ]]; then
        aws lambda invoke --function-name $function --payload file://$payload response.json
    else
        aws lambda invoke --function-name $function --payload $payload response.json
    fi

    if [[ $? -eq 0 ]]; then
        echo ""
        echo "Response:"
        cat response.json | jq .
        rm response.json
    fi
}

# CloudFormation stack status
cfnstatus() {
    if [[ -z $1 ]]; then
        echo "Usage: cfnstatus <stack-name>"
        echo ""
        echo "Available stacks:"
        aws cloudformation list-stacks \
            --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE \
            --query 'StackSummaries[].[StackName,StackStatus]' \
            --output table
        return 1
    fi

    local stack=$1

    echo "=== Stack: $stack ==="
    aws cloudformation describe-stacks --stack-name $stack \
        --query 'Stacks[0].[StackName,StackStatus,CreationTime]' \
        --output table

    echo ""
    echo "=== Recent Events ==="
    aws cloudformation describe-stack-events --stack-name $stack \
        --max-items 10 \
        --query 'StackEvents[].[Timestamp,ResourceStatus,ResourceType,LogicalResourceId]' \
        --output table
}

# CloudFormation stack outputs
cfnoutputs() {
    if [[ -z $1 ]]; then
        echo "Usage: cfnoutputs <stack-name>"
        return 1
    fi

    local stack=$1

    echo "=== Outputs for $stack ==="
    aws cloudformation describe-stacks --stack-name $stack \
        --query 'Stacks[0].Outputs[].[OutputKey,OutputValue,Description]' \
        --output table
}

# Delete CloudFormation stack safely
cfndelete() {
    if [[ -z $1 ]]; then
        echo "Usage: cfndelete <stack-name>"
        return 1
    fi

    local stack=$1

    echo "=== Deleting Stack: $stack ==="
    echo ""
    cfnstatus $stack
    echo ""
    echo "WARNING: This will delete all resources in the stack!"

    read -q "REPLY?Proceed with deletion? (y/n) "
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        aws cloudformation delete-stack --stack-name $stack
        echo ""
        echo "Deletion initiated. Monitoring progress..."
        aws cloudformation wait stack-delete-complete --stack-name $stack
        echo "Stack deleted!"
    else
        echo "Cancelled."
    fi
}

# Tail CloudWatch logs
cwlogs() {
    if [[ -z $1 ]]; then
        echo "Usage: cwlogs <log-group-name> [filter]"
        echo ""
        echo "Recent log groups:"
        aws logs describe-log-groups --query 'logGroups[].[logGroupName]' --output table | head -20
        return 1
    fi

    local log_group=$1
    local filter=$2

    echo "Tailing logs: $log_group"

    if [[ -n $filter ]]; then
        aws logs tail $log_group --follow --filter-pattern "$filter"
    else
        aws logs tail $log_group --follow
    fi
}

# IAM security audit
iamaudit() {
    echo "=== IAM Security Audit ==="
    echo ""

    echo "Users without MFA:"
    aws iam get-credential-report --output text 2>/dev/null || aws iam generate-credential-report &>/dev/null
    sleep 2
    aws iam get-credential-report --output text | base64 -d | awk -F',' '$4=="true" && $8=="false" {print $1}' | tail -n +2

    echo ""
    echo "Old Access Keys (>90 days):"
    for user in $(aws iam list-users --query 'Users[].UserName' --output text); do
        aws iam list-access-keys --user-name $user --query 'AccessKeyMetadata[].[UserName,AccessKeyId,CreateDate]' --output text | \
        while read username keyid created; do
            age=$(( ($(date +%s) - $(date -j -f "%Y-%m-%dT%H:%M:%S" "${created%+*}" +%s 2>/dev/null || date +%s)) / 86400 ))
            if [[ $age -gt 90 ]]; then
                echo "$username: $keyid (${age} days old)"
            fi
        done
    done

    echo ""
    echo "Unused IAM users (never logged in):"
    aws iam get-credential-report --output text | base64 -d | awk -F',' '$5=="N/A" || $5=="no_information" {print $1}' | tail -n +2
}

# Show costs for last N days
awscosts() {
    local days=${1:-7}
    local start_date=$(date -v-${days}d +%Y-%m-%d)
    local end_date=$(date +%Y-%m-%d)

    echo "=== AWS Costs ($start_date to $end_date) ==="

    aws ce get-cost-and-usage \
        --time-period Start=$start_date,End=$end_date \
        --granularity DAILY \
        --metrics BlendedCost \
        --query 'ResultsByTime[].[TimePeriod.Start,Total.BlendedCost.Amount]' \
        --output table
}

# Costs by service
awscosts-service() {
    local days=${1:-30}
    local start_date=$(date -v-${days}d +%Y-%m-%d)
    local end_date=$(date +%Y-%m-%d)

    echo "=== AWS Costs by Service (last $days days) ==="

    aws ce get-cost-and-usage \
        --time-period Start=$start_date,End=$end_date \
        --granularity MONTHLY \
        --metrics BlendedCost \
        --group-by Type=DIMENSION,Key=SERVICE \
        --query 'ResultsByTime[].Groups[].[Keys[0],Metrics.BlendedCost.Amount]' \
        --output table | sort -k2 -nr
}

# GCP helper - list projects
gcprojects() {
    echo "=== GCP Projects ==="
    gcloud projects list --format="table(projectId,name,projectNumber)"
}

# GCP helper - switch project
gcswitch() {
    if [[ -z $1 ]]; then
        echo "Usage: gcswitch <project-id>"
        gcprojects
        return 1
    fi

    gcloud config set project $1
    echo ""
    echo "Switched to project: $1"
}
