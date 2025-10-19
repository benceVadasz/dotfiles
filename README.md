# Dotfiles - DevOps Learning Environment

My personal dotfiles for setting up a comprehensive DevOps learning and development environment.

## What's Inside

- **Shell Configuration**: Zsh with Oh My Zsh and Powerlevel10k theme
- **DevOps Tools**: Comprehensive aliases and functions for Docker, Kubernetes, Terraform, AWS, and more
- **Learning Resources**: Integrated documentation and sandbox environments
- **CI/CD Helpers**: Git workflow automation and GitHub Actions integration
- **Monitoring Tools**: System and application monitoring utilities
- **Custom Aliases & Functions**: Productivity-focused shortcuts and helpers

### Directory Structure

```plaintext
dotfiles/
├── zsh/
│   ├── .zshrc                    # Main zsh configuration
│   ├── aliases.zsh               # General aliases
│   ├── functions.zsh             # General functions
│   ├── keybindings.zsh          # Custom key bindings
│   ├── p10k.zsh                 # Powerlevel10k config
│   ├── devops/                  # DevOps-specific configurations
│   │   ├── docker.zsh           # Docker aliases & functions
│   │   ├── kubernetes.zsh       # Kubernetes helpers
│   │   ├── terraform.zsh        # Terraform/IaC tools
│   │   ├── aws.zsh              # AWS & cloud providers
│   │   ├── cicd.zsh             # CI/CD workflows
│   │   └── monitoring.zsh       # Monitoring & observability
│   └── plugins/                 # Zsh plugins
│       ├── zsh-syntax-highlighting/
│       ├── zsh-autosuggestions/
│       └── zsh-shift-select/
├── git/
│   ├── .gitconfig               # Git configuration
│   ├── git-aliases.zsh          # Comprehensive git aliases
│   └── hooks/                   # Git hooks templates
├── configs/                      # Tool configurations
│   ├── kubectl/
│   │   └── completion.zsh       # Kubectl autocomplete
│   ├── docker/
│   │   └── config.json.example
│   ├── terraform/
│   │   └── .terraformrc.example
│   └── ansible/
│       └── ansible.cfg.example
├── scripts/
│   ├── install.sh               # Main installation script
│   ├── setup/                   # Setup scripts
│   │   └── devops-tools.sh     # Install DevOps tools
│   └── sandbox/                 # Practice environments
│       └── k8s-local-cluster.sh # Local K8s cluster
├── docs/                        # Learning documentation
│   └── COMMANDS.md              # Quick reference guide
├── templates/                   # Reusable templates
│   ├── kubernetes/
│   ├── terraform/
│   └── cicd/
└── README.md
```

## Prerequisites

- Zsh
- [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- Git

## Installation

1. Clone the repository (with submodules):

```bash
git clone --recursive https://github.com/yourusername/dotfiles.git ~/.dotfiles
```

2. Run the installation script:

```bash
cd ~/.dotfiles
chmod +x scripts/install.sh
./scripts/install.sh
```

## Features

### 🐳 Docker Tools
- **50+ Docker aliases** for container management
- **Smart cleanup functions** with interactive prompts
- **Container debugging tools** (ddebug, dshell, dlogs)
- **Image building with validation** (dbuild)
- **Security scanning integration** (dscan with trivy)
- **Resource monitoring** (dstats, dsize, dtop)

### ☸️ Kubernetes Helpers
- **Comprehensive kubectl aliases** (k, kgp, kgs, etc.)
- **Pod debugging suite** (kdebug, kshell, klogs)
- **Cluster information tools** (kinfo, knodes, knamespaces)
- **Deployment management** (kdeploy, krestart, kscale-deploy)
- **Troubleshooting helpers** (kcrash, kpending, kerrors)
- **Port forwarding with guidance** (kport)
- **Auto-completion** for all kubectl commands

### 🏗️ Terraform/IaC
- **Safe apply/destroy workflows** with confirmations
- **State management helpers** (tfstate-*)
- **Workspace management** (tfwork-*)
- **Plan and cost estimation** (tfplan, tfcost)
- **Security scanning** (tfsec, checkov)
- **Import and debugging tools**

### ☁️ Cloud Providers
- **AWS CLI helpers** with cost awareness
- **Profile switching** (awsswitch)
- **EC2 management** (ec2list, ec2start, ec2stop)
- **S3 tools** (s3size, s3tree, s3public)
- **Lambda helpers** (lambdalist, lambdalogs)
- **CloudFormation tools** (cfnstatus, cfnoutputs)
- **Cost tracking** (awscosts, awscosts-service)
- **GCP helpers** (gcswitch, gcprojects)

### 🔄 CI/CD Workflows
- **Git workflow automation** (feature, hotfix, release)
- **GitHub Actions integration** (ghactions, ghrun)
- **Pull request helpers** (prcreate, prcheck, prmerge)
- **Local CI testing** (citest, cilint, cibuild)
- **Secret scanning** (cisecrets)
- **Pipeline validation** (cipipe)
- **Branch management** (branch-clean, branches)

### 📊 Monitoring & Observability
- **System monitoring** (sysmon, portcheck, diskmon)
- **Log analysis** (logtail, logsearch, logerrors)
- **Application health checks** (apphealth, apimetrics)
- **Container monitoring** (containerstats, containerhealth)
- **Performance testing** (loadtest, benchmark)
- **Network monitoring** (netmon, connections)

### 🎯 General Productivity
- **killport**: Kill process on specified port
- **Original aliases preserved**: dev, play, migration-gen, etc.
- **Enhanced git aliases**: 100+ git shortcuts
- **Custom key bindings** for terminal efficiency

### 🔌 Plugins
- zsh-syntax-highlighting - Command highlighting
- zsh-autosuggestions - Smart suggestions
- zsh-shift-select - Text selection with shift

## Updating

### Update dotfiles

```bash
cd ~/.dotfiles
git pull
```

### Update plugins

```bash
git submodule update --remote
```

## DevOps Learning Path

This environment is designed to accelerate your DevOps learning through daily practice.

### Getting Started

1. **Install DevOps Tools**
   ```bash
   cd ~/.dotfiles
   chmod +x scripts/setup/devops-tools.sh
   ./scripts/setup/devops-tools.sh
   ```

2. **Set Up Local Kubernetes Cluster**
   ```bash
   chmod +x scripts/sandbox/k8s-local-cluster.sh
   ./scripts/sandbox/k8s-local-cluster.sh
   ```

3. **Explore Available Commands**
   ```bash
   dhelp      # Docker commands
   khelp      # Kubernetes commands
   tfhelp     # Terraform commands
   awshelp    # AWS commands
   cihelp     # CI/CD commands
   monhelp    # Monitoring commands
   ```

4. **Read Quick Reference**
   ```bash
   cat docs/COMMANDS.md
   # or
   open docs/COMMANDS.md
   ```

### Practice Workflows

#### Docker Practice
```bash
# Build and run a container
drun ubuntu:latest
dshell <container>
dlogs <container>
dcleanup  # Clean up when done
```

#### Kubernetes Practice
```bash
# Set up local cluster (if not done already)
./scripts/sandbox/k8s-local-cluster.sh

# Practice commands
kgp                          # List pods
kubectl create deployment nginx --image=nginx
kdeploy nginx                # View deployment details
kshell <pod-name>            # Open shell in pod
```

#### Terraform Practice
```bash
# Create a simple config
mkdir tf-test && cd tf-test
# ... create main.tf ...
tfinit
tfvalidate-all
tfplan
tfapply
```

#### CI/CD Practice
```bash
# Create a feature branch
feature user-authentication

# Make changes...
git add .
git commit -m "Add user auth"
git push

# Create PR
prcreate "Add user authentication"

# Check CI status
prcheck
```

### Learning Resources

- **docs/COMMANDS.md** - Complete command reference
- **configs/** - Example configurations for various tools
- **templates/** - Starter templates for common tasks
- Inline help: Every function has `--help` or shows usage examples

## Customization

### Adding new aliases

Add them to `zsh/aliases.zsh` for general aliases, or to the appropriate file in `zsh/devops/` for DevOps-specific aliases.

### Adding new functions

Add them to `zsh/functions.zsh` for general functions, or create domain-specific functions in `zsh/devops/`.

### Adding new key bindings

Add them to `zsh/keybindings.zsh`

### Modifying DevOps helpers

Each DevOps tool has its own file in `zsh/devops/`:
- `docker.zsh` - Docker commands
- `kubernetes.zsh` - Kubernetes commands
- `terraform.zsh` - Terraform/IaC commands
- `aws.zsh` - Cloud provider commands
- `cicd.zsh` - CI/CD workflows
- `monitoring.zsh` - Monitoring tools

## Supported Tools

This environment includes helpers and configurations for:

### Container & Orchestration
- Docker & Docker Compose
- Kubernetes (kubectl, kind, k9s)
- Helm

### Infrastructure as Code
- Terraform
- CloudFormation
- Ansible (basic support)

### Cloud Providers
- AWS (EC2, S3, Lambda, CloudFormation, IAM, etc.)
- Google Cloud Platform (GCP/gcloud)
- Azure (basic aliases)

### CI/CD
- GitHub Actions
- GitLab CI
- GitHub CLI (gh)
- Git workflows (feature branches, releases, etc.)

### Monitoring & Observability
- System monitoring (CPU, memory, disk, network)
- Log analysis
- Application health checks
- Container monitoring
- Performance testing

### Security & Compliance
- Trivy (container scanning)
- tfsec (Terraform security)
- Checkov (IaC compliance)
- Secret detection
- Hadolint (Dockerfile linting)

### Utilities
- jq, yq (JSON/YAML processing)
- HTTPie (better curl)
- bat (better cat)
- fzf (fuzzy finder)
- stern (K8s log tailing)

## Troubleshooting

### Commands not found after installation
```bash
source ~/.zshrc
# or restart your terminal
```

### DevOps commands not loading
Check that DevOps configs are being sourced:
```bash
grep -A 5 "Load DevOps configurations" ~/.dotfiles/zsh/.zshrc
```

### Permission denied on scripts
```bash
chmod +x ~/.dotfiles/scripts/**/*.sh
```

### Kubectl completion not working
```bash
source ~/.dotfiles/configs/kubectl/completion.zsh
```

## Contributing

Feel free to fork and customize for your own use! Suggestions and improvements are welcome.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Oh My Zsh - Framework
- Powerlevel10k - Theme
- All plugin authors
- DevOps community for best practices and inspiration
