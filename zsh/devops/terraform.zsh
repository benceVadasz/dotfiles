# Terraform & IaC Aliases and Functions
# Author: DevOps Learning Environment
# Purpose: Streamline Terraform workflows and teach IaC best practices

# ============================================================================
# Basic Terraform Aliases
# ============================================================================

alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfv='terraform validate'
alias tff='terraform fmt'
alias tffr='terraform fmt -recursive'
alias tfs='terraform show'
alias tfo='terraform output'
alias tfr='terraform refresh'
alias tfg='terraform graph'
alias tfw='terraform workspace'
alias tfwl='terraform workspace list'
alias tfws='terraform workspace select'
alias tfwn='terraform workspace new'
alias tfst='terraform state'
alias tfsl='terraform state list'
alias tfss='terraform state show'
alias tfc='terraform console'

# ============================================================================
# Terraform Safety Aliases (with confirmation)
# ============================================================================

alias tfa!='terraform apply -auto-approve'
alias tfd!='terraform destroy -auto-approve'

# ============================================================================
# Learning Functions
# ============================================================================

# Display help for Terraform functions
tfhelp() {
    cat << 'EOF'
Terraform Helper Functions - Learning Guide
===========================================

Planning & Validation:
  tfinit              - Initialize with backend config
  tfplan              - Create and save execution plan
  tfplan-destroy      - Create destroy plan
  tfvalidate-all      - Validate all .tf files
  tffmt-check         - Check formatting without changes
  tfcost [plan]       - Estimate costs (requires infracost)

Applying Changes:
  tfapply [plan]      - Apply with confirmation
  tfapply-target <r>  - Apply specific resource only
  tfdestroy-safe      - Destroy with multiple confirmations
  tfdestroy-target    - Destroy specific resource

State Management:
  tfstate-list        - List all resources in state
  tfstate-show <r>    - Show resource details
  tfstate-backup      - Backup state file
  tfstate-pull        - Pull remote state
  tfstate-rm <r>      - Remove resource from state (careful!)
  tfstate-mv <s> <d>  - Move resource in state

Workspace Management:
  tfwork-new <name>   - Create and switch to workspace
  tfwork-list         - List all workspaces
  tfwork-del <name>   - Delete workspace (safe)

Troubleshooting:
  tfdebug             - Run with debug logging
  tfrefresh-state     - Refresh state from real infrastructure
  tfuntaint <r>       - Remove tainted mark from resource
  tftaint <r>         - Mark resource for recreation
  tfgraph-viz         - Generate visual dependency graph

Development:
  tfclean             - Clean .terraform directory
  tfupgrade           - Upgrade provider versions
  tfimport <r> <id>   - Import existing resource
  tfmodule-update     - Update all modules
  tfdocs [dir]        - Generate documentation (requires terraform-docs)

Security:
  tfscan              - Scan for security issues (requires tfsec)
  tfcompliance        - Check compliance (requires checkov)
  tflint              - Lint terraform files (requires tflint)

Examples:
  tfplan prod.plan              - Create plan named prod.plan
  tfapply prod.plan             - Apply saved plan
  tfstate-show aws_instance.web - Show instance details
  tfapply-target aws_s3_bucket.data - Apply only S3 bucket
  tfwork-new staging            - Create staging workspace

Use --help flag on any function for detailed usage.
EOF
}

# Enhanced init with backend config
tfinit() {
    echo "=== Terraform Init ==="

    if [[ -n $1 ]]; then
        echo "Initializing with backend config: $1"
        terraform init -backend-config=$1
    else
        terraform init
    fi

    if [[ $? -eq 0 ]]; then
        echo ""
        echo "Initialization successful!"
        echo ""
        echo "Provider versions:"
        terraform version
    fi
}

# Create and save execution plan
tfplan() {
    local plan_file=${1:-tfplan}

    echo "=== Creating Terraform Plan ==="
    echo "Plan will be saved to: $plan_file"
    echo ""

    terraform plan -out=$plan_file

    if [[ $? -eq 0 ]]; then
        echo ""
        echo "Plan created successfully: $plan_file"
        echo "To apply: tfapply $plan_file"
        echo "To view: terraform show $plan_file"
    fi
}

# Create destroy plan
tfplan-destroy() {
    local plan_file=${1:-destroy.plan}

    echo "=== Creating Destroy Plan ==="
    echo "WARNING: This will plan to destroy all resources!"
    echo ""

    terraform plan -destroy -out=$plan_file

    if [[ $? -eq 0 ]]; then
        echo ""
        echo "Destroy plan created: $plan_file"
        echo "Review carefully before applying!"
    fi
}

# Apply with confirmation
tfapply() {
    if [[ -n $1 && -f $1 ]]; then
        # Applying a saved plan
        echo "=== Applying Saved Plan: $1 ==="
        echo ""
        terraform show $1
        echo ""
        read -q "REPLY?Apply this plan? (y/n) "
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            terraform apply $1
        else
            echo "Cancelled."
        fi
    else
        # Interactive plan and apply
        echo "=== Terraform Apply ==="
        terraform apply
    fi
}

# Apply specific resource only
tfapply-target() {
    if [[ -z $1 ]]; then
        echo "Usage: tfapply-target <resource>"
        echo "Example: tfapply-target aws_instance.web"
        echo ""
        echo "Available resources:"
        terraform state list
        return 1
    fi

    local resource=$1

    echo "=== Applying Target: $resource ==="
    echo "This will only affect: $resource"
    echo ""

    terraform plan -target=$resource

    echo ""
    read -q "REPLY?Apply these changes? (y/n) "
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        terraform apply -target=$resource
    else
        echo "Cancelled."
    fi
}

# Safe destroy with multiple confirmations
tfdestroy-safe() {
    echo "=== Terraform Destroy ==="
    echo "WARNING: This will destroy ALL resources managed by this configuration!"
    echo ""

    # First confirmation
    read -q "REPLY?Are you absolutely sure you want to destroy everything? (y/n) "
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        return 0
    fi

    # Show what will be destroyed
    echo ""
    echo "Resources that will be destroyed:"
    terraform plan -destroy

    # Second confirmation
    echo ""
    read -q "REPLY?Proceed with destruction? (y/n) "
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        return 0
    fi

    # Final confirmation - type workspace name
    local workspace=$(terraform workspace show)
    echo ""
    echo "Current workspace: $workspace"
    echo -n "Type workspace name to confirm: "
    read confirm_workspace

    if [[ $confirm_workspace == $workspace ]]; then
        terraform destroy
    else
        echo "Workspace name mismatch. Cancelled for safety."
    fi
}

# Destroy specific resource
tfdestroy-target() {
    if [[ -z $1 ]]; then
        echo "Usage: tfdestroy-target <resource>"
        echo "Example: tfdestroy-target aws_instance.web"
        echo ""
        echo "Available resources:"
        terraform state list
        return 1
    fi

    local resource=$1

    echo "=== Destroying Target: $resource ==="
    echo "WARNING: This will destroy: $resource"
    echo ""

    terraform plan -destroy -target=$resource

    echo ""
    read -q "REPLY?Destroy this resource? (y/n) "
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        terraform destroy -target=$resource
    else
        echo "Cancelled."
    fi
}

# List all resources in state
tfstate-list() {
    echo "=== Terraform State Resources ==="
    terraform state list | nl
}

# Show resource details
tfstate-show() {
    if [[ -z $1 ]]; then
        echo "Usage: tfstate-show <resource>"
        echo ""
        echo "Available resources:"
        terraform state list
        return 1
    fi

    terraform state show $1
}

# Backup state file
tfstate-backup() {
    local backup_name="terraform.tfstate.backup-$(date +%Y%m%d-%H%M%S)"

    if [[ -f terraform.tfstate ]]; then
        cp terraform.tfstate $backup_name
        echo "State backed up to: $backup_name"
    else
        echo "No local state file found."
        echo "For remote state, use: terraform state pull > $backup_name"
    fi
}

# Pull remote state
tfstate-pull() {
    local output=${1:-terraform.tfstate.pull}

    echo "Pulling remote state to: $output"
    terraform state pull > $output

    if [[ $? -eq 0 ]]; then
        echo "State saved to: $output"
        echo "Size: $(du -h $output | cut -f1)"
    fi
}

# Remove resource from state (with warning)
tfstate-rm() {
    if [[ -z $1 ]]; then
        echo "Usage: tfstate-rm <resource>"
        echo "WARNING: This removes the resource from state but doesn't destroy it!"
        return 1
    fi

    local resource=$1

    echo "=== Remove from State ==="
    echo "Resource: $resource"
    echo ""
    echo "WARNING: This will remove the resource from Terraform state."
    echo "The actual infrastructure will NOT be destroyed."
    echo "Terraform will no longer manage this resource."
    echo ""

    read -q "REPLY?Continue? (y/n) "
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Backup first
        tfstate-backup
        terraform state rm $resource
    else
        echo "Cancelled."
    fi
}

# Move resource in state
tfstate-mv() {
    if [[ $# -lt 2 ]]; then
        echo "Usage: tfstate-mv <source> <destination>"
        echo "Example: tfstate-mv aws_instance.old aws_instance.new"
        return 1
    fi

    local source=$1
    local dest=$2

    echo "Moving in state: $source -> $dest"

    # Backup first
    tfstate-backup
    terraform state mv $source $dest
}

# Validate all terraform files
tfvalidate-all() {
    echo "=== Validating Terraform Configuration ==="

    # Format check
    echo "Checking formatting..."
    if terraform fmt -check -recursive; then
        echo "✓ Formatting is correct"
    else
        echo "✗ Formatting issues found. Run: tff"
    fi

    echo ""
    echo "Validating configuration..."
    terraform validate

    if [[ $? -eq 0 ]]; then
        echo ""
        echo "✓ Configuration is valid!"
    fi
}

# Check formatting without changes
tffmt-check() {
    echo "=== Checking Terraform Formatting ==="
    terraform fmt -check -recursive -diff

    if [[ $? -eq 0 ]]; then
        echo ""
        echo "✓ All files are properly formatted!"
    else
        echo ""
        echo "Run 'tff' to fix formatting issues"
    fi
}

# Create new workspace
tfwork-new() {
    if [[ -z $1 ]]; then
        echo "Usage: tfwork-new <workspace-name>"
        return 1
    fi

    local workspace=$1

    echo "Creating and switching to workspace: $workspace"
    terraform workspace new $workspace

    if [[ $? -eq 0 ]]; then
        echo ""
        echo "Current workspace:"
        terraform workspace show
    fi
}

# List workspaces with current highlighted
tfwork-list() {
    echo "=== Terraform Workspaces ==="
    terraform workspace list

    echo ""
    echo "Current workspace: $(terraform workspace show)"
}

# Delete workspace safely
tfwork-del() {
    if [[ -z $1 ]]; then
        echo "Usage: tfwork-del <workspace-name>"
        return 1
    fi

    local workspace=$1
    local current=$(terraform workspace show)

    if [[ $workspace == $current ]]; then
        echo "Cannot delete current workspace: $workspace"
        echo "Switch to another workspace first."
        return 1
    fi

    if [[ $workspace == "default" ]]; then
        echo "Cannot delete default workspace!"
        return 1
    fi

    echo "Deleting workspace: $workspace"
    read -q "REPLY?Are you sure? (y/n) "
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        terraform workspace delete $workspace
    else
        echo "Cancelled."
    fi
}

# Run with debug logging
tfdebug() {
    echo "=== Running Terraform with Debug Logging ==="
    echo "Log level: TRACE"
    echo ""

    TF_LOG=TRACE terraform "$@"
}

# Refresh state from infrastructure
tfrefresh-state() {
    echo "=== Refreshing Terraform State ==="
    echo "This will update state from real infrastructure."
    echo ""

    terraform refresh

    if [[ $? -eq 0 ]]; then
        echo ""
        echo "State refreshed successfully!"
    fi
}

# Untaint resource
tfuntaint() {
    if [[ -z $1 ]]; then
        echo "Usage: tfuntaint <resource>"
        echo "Removes tainted mark from resource"
        return 1
    fi

    echo "Removing taint from: $1"
    terraform untaint $1
}

# Taint resource for recreation
tftaint() {
    if [[ -z $1 ]]; then
        echo "Usage: tftaint <resource>"
        echo "Marks resource for recreation on next apply"
        return 1
    fi

    local resource=$1

    echo "=== Tainting Resource ==="
    echo "Resource: $resource"
    echo ""
    echo "This will mark the resource for destruction and recreation."
    echo ""

    read -q "REPLY?Continue? (y/n) "
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        terraform taint $resource
    else
        echo "Cancelled."
    fi
}

# Clean terraform directory
tfclean() {
    echo "=== Cleaning Terraform Directory ==="
    echo "This will remove .terraform directory and lock file."
    echo ""

    read -q "REPLY?Continue? (y/n) "
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf .terraform .terraform.lock.hcl
        echo "Cleaned! Run 'tfinit' to reinitialize."
    else
        echo "Cancelled."
    fi
}

# Upgrade providers
tfupgrade() {
    echo "=== Upgrading Terraform Providers ==="
    terraform init -upgrade

    if [[ $? -eq 0 ]]; then
        echo ""
        echo "Providers upgraded! New versions:"
        terraform version
    fi
}

# Import existing resource
tfimport() {
    if [[ $# -lt 2 ]]; then
        echo "Usage: tfimport <resource-address> <resource-id>"
        echo "Example: tfimport aws_instance.web i-1234567890abcdef0"
        return 1
    fi

    local address=$1
    local id=$2

    echo "=== Importing Resource ==="
    echo "Address: $address"
    echo "ID: $id"
    echo ""

    terraform import $address $id

    if [[ $? -eq 0 ]]; then
        echo ""
        echo "Import successful! Resource state:"
        terraform state show $address | head -20
    fi
}

# Update modules
tfmodule-update() {
    echo "=== Updating Terraform Modules ==="
    terraform get -update

    if [[ $? -eq 0 ]]; then
        echo ""
        echo "Modules updated! Run 'tfinit' to reinitialize."
    fi
}

# Generate visual dependency graph
tfgraph-viz() {
    local output=${1:-graph.png}

    if ! command -v dot &> /dev/null; then
        echo "Graphviz not installed. Install with: brew install graphviz"
        return 1
    fi

    echo "Generating dependency graph..."
    terraform graph | dot -Tpng > $output

    if [[ $? -eq 0 ]]; then
        echo "Graph saved to: $output"
        echo "Opening..."
        open $output 2>/dev/null || echo "Open $output to view the graph"
    fi
}

# Generate documentation
tfdocs() {
    local dir=${1:-.}

    if ! command -v terraform-docs &> /dev/null; then
        echo "terraform-docs not installed."
        echo "Install with: brew install terraform-docs"
        return 1
    fi

    echo "=== Generating Terraform Documentation ==="
    terraform-docs markdown table $dir > $dir/README.md

    echo "Documentation generated: $dir/README.md"
}

# Scan for security issues
tfscan() {
    if ! command -v tfsec &> /dev/null; then
        echo "tfsec not installed."
        echo "Install with: brew install tfsec"
        return 1
    fi

    echo "=== Scanning for Security Issues ==="
    tfsec .
}

# Check compliance
tfcompliance() {
    if ! command -v checkov &> /dev/null; then
        echo "checkov not installed."
        echo "Install with: brew install checkov"
        return 1
    fi

    echo "=== Checking Compliance ==="
    checkov -d .
}

# Lint terraform files
tflint() {
    if ! command -v tflint &> /dev/null; then
        echo "tflint not installed."
        echo "Install with: brew install tflint"
        return 1
    fi

    echo "=== Linting Terraform Files ==="
    tflint
}

# Estimate costs
tfcost() {
    local plan_file=$1

    if ! command -v infracost &> /dev/null; then
        echo "infracost not installed."
        echo "Install with: brew install infracost"
        echo "Configure with: infracost auth login"
        return 1
    fi

    if [[ -n $plan_file ]]; then
        echo "=== Estimating Costs from Plan ==="
        infracost breakdown --path $plan_file
    else
        echo "=== Estimating Costs ==="
        infracost breakdown --path .
    fi
}

# Show current workspace info
tfinfo() {
    echo "=== Terraform Configuration Info ==="
    echo ""
    echo "Workspace: $(terraform workspace show)"
    echo "Version: $(terraform version | head -1)"
    echo ""
    echo "Providers:"
    terraform version
    echo ""
    echo "Resources in state: $(terraform state list | wc -l | xargs)"
    echo ""
    echo "Recent state modifications:"
    ls -lht terraform.tfstate* 2>/dev/null | head -5
}

# Quick output all
tfout() {
    echo "=== Terraform Outputs ==="
    terraform output
}

# Output specific value
tfout-get() {
    if [[ -z $1 ]]; then
        echo "Available outputs:"
        terraform output
        return 0
    fi

    terraform output -raw $1
}

# Show plan in JSON
tfplan-json() {
    local plan_file=${1:-tfplan}

    if [[ ! -f $plan_file ]]; then
        echo "Plan file not found: $plan_file"
        echo "Create one with: tfplan $plan_file"
        return 1
    fi

    terraform show -json $plan_file | jq .
}
