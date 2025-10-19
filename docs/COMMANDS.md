# DevOps Commands Quick Reference

This document provides a quick reference for all the custom DevOps aliases and functions available in your environment.

## Table of Contents
- [Docker Commands](#docker-commands)
- [Kubernetes Commands](#kubernetes-commands)
- [Terraform Commands](#terraform-commands)
- [AWS Commands](#aws-commands)
- [CI/CD Commands](#cicd-commands)
- [Monitoring Commands](#monitoring-commands)

## Docker Commands

### Basic Aliases
```bash
d               # docker
dps             # docker ps
dpsa            # docker ps -a
di              # docker images
dex             # docker exec -it
dlog            # docker logs
dlogf           # docker logs -f

# Docker Compose
dc              # docker-compose
dcu             # docker-compose up
dcud            # docker-compose up -d
dcd             # docker-compose down
dcl             # docker-compose logs -f
```

### Functions
```bash
dhelp                    # Show Docker help
dclean                   # Remove stopped containers
dclean-all               # Remove ALL containers (careful!)
dkillall                 # Stop all running containers
dlogs <container> [grep] # Tail logs with optional filter
dshell <container>       # Open shell in container
drun <image>             # Run container interactively
dbuild <tag>             # Build image with validation
ddebug <container>       # Debug container issues
dsize [container]        # Show container sizes
dports                   # Show all port mappings
dcleanup                 # Interactive cleanup wizard
```

## Kubernetes Commands

### Basic Aliases
```bash
k               # kubectl
kgp             # kubectl get pods
kgpa            # kubectl get pods --all-namespaces
kgd             # kubectl get deployments
kgs             # kubectl get services
kl              # kubectl logs
klf             # kubectl logs -f
kex             # kubectl exec -it
kd              # kubectl describe
ka              # kubectl apply -f
```

### Functions
```bash
khelp                     # Show Kubernetes help
kinfo                     # Show cluster info
knodes                    # List nodes with resources
kpods [namespace]         # List pods in namespace
kshell <pod>              # Open shell in pod
kdebug <pod>              # Debug pod comprehensively
klogs <pod> [filter]      # Tail logs with filter
krestart <deployment>     # Restart deployment
kcrash                    # List crashlooping pods
kpending                  # List pending pods
kdeploy <name>            # Get deployment details
ksvc <name>               # Get service details
kscale-deploy <name> <n>  # Scale deployment
krun-debug                # Run debug pod in cluster
kport <pod> <ports>       # Port-forward with help
```

## Terraform Commands

### Basic Aliases
```bash
tf              # terraform
tfi             # terraform init
tfp             # terraform plan
tfa             # terraform apply
tfd             # terraform destroy
tfv             # terraform validate
tff             # terraform fmt
tfo             # terraform output
tfw             # terraform workspace
```

### Functions
```bash
tfhelp                    # Show Terraform help
tfinit [backend-config]   # Init with backend config
tfplan [file]             # Create and save plan
tfplan-destroy [file]     # Create destroy plan
tfapply [plan]            # Apply with confirmation
tfapply-target <resource> # Apply specific resource
tfdestroy-safe            # Safe destroy with confirmations
tfstate-list              # List all state resources
tfstate-show <resource>   # Show resource details
tfstate-backup            # Backup state file
tfwork-new <name>         # Create workspace
tfclean                   # Clean .terraform directory
tfimport <addr> <id>      # Import existing resource
tfscan                    # Scan for security issues
tfcost [plan]             # Estimate costs
```

## AWS Commands

### Basic Aliases
```bash
awsp            # export AWS_PROFILE=
awswho          # aws sts get-caller-identity
ec2ls           # aws ec2 describe-instances
ec2running      # List running instances
s3ls            # aws s3 ls
lambdals        # aws lambda list-functions
```

### Functions
```bash
awshelp                   # Show AWS help
awsinfo                   # Show current AWS config
awsprofiles               # List all profiles
awsswitch <profile>       # Switch AWS profile
awsregions                # List all regions
ec2list [filter]          # List EC2 instances
ec2start <instance-id>    # Start EC2 instance
ec2stop <instance-id>     # Stop EC2 instance
s3size <bucket>           # Calculate bucket size
s3tree <bucket>           # Show bucket structure
s3public                  # Check for public buckets
lambdalist                # List Lambda functions
lambdalogs <function>     # Tail function logs
cfnstatus <stack>         # Show stack status
cfnoutputs <stack>        # Show stack outputs
awscosts [days]           # Show costs for N days
```

## CI/CD Commands

### Git Workflow
```bash
feature <name>            # Create feature branch
hotfix <name>             # Create hotfix branch
release <version>         # Create release branch
finish-feature            # Merge feature to develop
sync-fork                 # Sync fork with upstream
```

### GitHub Actions
```bash
ghactions                 # List workflows
ghrun <workflow>          # Trigger workflow
ghlogs <run-id>           # View workflow logs
ghstatus                  # Check workflow status
prcreate [title]          # Create pull request
prcheck                   # Check PR status
prmerge [pr]              # Merge PR safely
```

### CI Testing
```bash
citest                    # Run tests locally like CI
cilint                    # Run linters locally
cibuild                   # Build project like CI
cipipe [file]             # Validate CI config
cisecrets                 # Check for secrets
cidebug                   # Debug CI failures
```

## Monitoring Commands

### System Monitoring
```bash
sysmon                    # System resource monitor
portcheck <port>          # Check what's using port
netmon                    # Monitor network connections
diskmon                   # Show disk usage
procmon <name>            # Monitor specific process
```

### Log Analysis
```bash
logtail <file>            # Tail log with highlighting
logsearch <pattern> [dir] # Search across logs
logerrors [file]          # Find errors in logs
logstats <file>           # Show log statistics
```

### Application Monitoring
```bash
apphealth <url>           # Check app health
apimetrics <url>          # Show API metrics
webcheck <url>            # Check website status
loadtest <url> [n] [c]    # Simple load test
```

### Container Monitoring
```bash
containerstats            # Detailed container stats
containerhealth <name>    # Check container health
containerlogs <name>      # Analyze container logs
```

## Tips & Best Practices

1. **Use tab completion**: Most commands support tab completion
2. **Check help first**: Use `<command>help` functions (e.g., `dhelp`, `khelp`)
3. **Start with dry runs**: Use plan/validate commands before applying changes
4. **Monitor resources**: Regular use of monitoring commands prevents issues
5. **Clean up regularly**: Use cleanup functions to save disk space
6. **Use workspaces**: Separate dev/staging/prod with Terraform workspaces
7. **Profile switching**: Use `awsswitch` and `gcswitch` for safe profile management

## Learning Workflow

1. **Start with help**: `<tool>help` to see all available functions
2. **Practice in sandbox**: Use sandbox scripts in `scripts/sandbox/`
3. **Read docs**: Check `docs/` directory for detailed guides
4. **Use templates**: Find templates in `templates/` directory
5. **Experiment safely**: Use local environments and dry-run modes first

## Quick Access

To view this file anytime:
```bash
cat ~/.dotfiles/docs/COMMANDS.md
# or
open ~/.dotfiles/docs/COMMANDS.md
```

For more detailed information, check the other documentation files:
- `DOCKER.md` - Docker learning guide
- `KUBERNETES.md` - Kubernetes learning guide
- `TERRAFORM.md` - Terraform/IaC guide
- `AWS.md` - AWS best practices
- `WORKFLOWS.md` - Common DevOps workflows
