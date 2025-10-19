# CI/CD & Git Workflow Helpers
# Author: DevOps Learning Environment
# Purpose: Streamline CI/CD workflows and teach best practices

# ============================================================================
# GitHub CLI Aliases
# ============================================================================

alias ghpr='gh pr'
alias ghprls='gh pr list'
alias ghprc='gh pr create'
alias ghprv='gh pr view'
alias ghprd='gh pr diff'
alias ghprco='gh pr checkout'
alias ghprm='gh pr merge'

alias ghi='gh issue'
alias ghils='gh issue list'
alias ghic='gh issue create'
alias ghiv='gh issue view'

alias ghw='gh workflow'
alias ghwl='gh workflow list'
alias ghwr='gh workflow run'
alias ghwv='gh workflow view'

alias ghr='gh run'
alias ghrls='gh run list'
alias ghrv='gh run view'
alias ghrw='gh run watch'

alias ghrepo='gh repo'
alias ghrepoview='gh repo view'
alias ghrepoclone='gh repo clone'

# ============================================================================
# Git Workflow Aliases (extending existing git aliases)
# ============================================================================

alias gitmain='git checkout main || git checkout master'
alias gitdev='git checkout develop || git checkout dev'
alias gitclean='git fetch -p && git branch -vv | grep ": gone]" | awk "{print \$1}" | xargs git branch -d'

# ============================================================================
# Learning Functions
# ============================================================================

# Display help for CI/CD functions
cihelp() {
    cat << 'EOF'
CI/CD Helper Functions - Learning Guide
=======================================

Git Workflow:
  feature <name>      - Create feature branch from main/master
  hotfix <name>       - Create hotfix branch
  release <version>   - Create release branch
  finish-feature      - Merge feature back to develop
  sync-fork           - Sync fork with upstream

GitHub Actions:
  ghactions           - List all workflows
  ghrun <workflow>    - Trigger workflow run
  ghlogs <run-id>     - View workflow logs
  ghstatus            - Check workflow status
  ghsecrets           - List repository secrets

Pull Request Workflow:
  prcreate [title]    - Create PR with template
  prcheck             - Check PR status and CI
  prmerge [pr]        - Merge PR safely
  prdraft             - Create draft PR
  prready             - Mark draft PR as ready

CI/CD Testing:
  citest              - Run tests locally (like CI)
  cilint              - Run linters locally
  cibuild             - Build project like CI
  cienv               - Show CI environment variables
  cidocker            - Build Docker image like CI

Pipeline Debugging:
  cipipe <file>       - Validate CI/CD pipeline config
  cisecrets           - Check for secrets in code
  cidebug             - Debug CI failures
  ciartifacts         - Download CI artifacts

Branch Management:
  branches            - List branches with info
  branch-clean        - Delete merged branches
  branch-behind       - Show branches behind main
  branch-rename <n>   - Rename current branch

Examples:
  feature user-auth         - Create feature/user-auth branch
  prcreate "Add auth"       - Create PR with title
  ghrun "CI Pipeline"       - Trigger CI workflow
  citest                    - Run tests like CI does
  branch-clean              - Clean up merged branches

Use --help flag on any function for detailed usage.
EOF
}

# Create feature branch from main/develop
feature() {
    if [[ -z $1 ]]; then
        echo "Usage: feature <feature-name>"
        echo "Creates feature branch from main/master"
        return 1
    fi

    local feature_name=$1
    local branch="feature/$feature_name"
    local base_branch="main"

    # Check if main exists, otherwise use master
    git rev-parse --verify main &>/dev/null || base_branch="master"

    echo "Creating feature branch: $branch"
    echo "Base branch: $base_branch"
    echo ""

    # Fetch latest
    git fetch origin

    # Create and checkout feature branch
    git checkout -b $branch origin/$base_branch

    if [[ $? -eq 0 ]]; then
        echo ""
        echo "Feature branch created successfully!"
        echo "Branch: $branch"
        echo ""
        echo "Next steps:"
        echo "  1. Make your changes"
        echo "  2. Commit your work"
        echo "  3. Run: git push -u origin $branch"
        echo "  4. Create PR with: prcreate"
    fi
}

# Create hotfix branch
hotfix() {
    if [[ -z $1 ]]; then
        echo "Usage: hotfix <hotfix-name>"
        return 1
    fi

    local hotfix_name=$1
    local branch="hotfix/$hotfix_name"
    local base_branch="main"

    git rev-parse --verify main &>/dev/null || base_branch="master"

    echo "Creating hotfix branch: $branch"
    git fetch origin
    git checkout -b $branch origin/$base_branch

    if [[ $? -eq 0 ]]; then
        echo ""
        echo "Hotfix branch created!"
        echo "Remember: Hotfixes should be minimal and urgent fixes only"
    fi
}

# Create release branch
release() {
    if [[ -z $1 ]]; then
        echo "Usage: release <version>"
        echo "Example: release v1.2.0"
        return 1
    fi

    local version=$1
    local branch="release/$version"

    echo "Creating release branch: $branch"
    git checkout -b $branch develop

    if [[ $? -eq 0 ]]; then
        echo ""
        echo "Release branch created: $branch"
        echo ""
        echo "Next steps:"
        echo "  1. Update version numbers"
        echo "  2. Update CHANGELOG"
        echo "  3. Run final tests"
        echo "  4. Merge to main and tag"
    fi
}

# Finish feature (merge back)
finish-feature() {
    local current_branch=$(git branch --show-current)

    if [[ ! $current_branch =~ ^feature/ ]]; then
        echo "Not on a feature branch!"
        echo "Current branch: $current_branch"
        return 1
    fi

    echo "Finishing feature: $current_branch"
    echo ""

    # Update feature branch
    git fetch origin
    git rebase origin/develop

    if [[ $? -ne 0 ]]; then
        echo "Rebase failed. Resolve conflicts first."
        return 1
    fi

    # Switch to develop and merge
    git checkout develop
    git pull origin develop
    git merge --no-ff $current_branch

    echo ""
    echo "Feature merged to develop!"
    echo "Push with: git push origin develop"
    echo "Delete feature branch with: git branch -d $current_branch"
}

# Sync fork with upstream
sync-fork() {
    echo "=== Syncing Fork with Upstream ==="

    # Check if upstream exists
    if ! git remote | grep -q upstream; then
        echo "No upstream remote found."
        echo -n "Enter upstream repository URL: "
        read upstream_url
        git remote add upstream $upstream_url
    fi

    echo "Fetching from upstream..."
    git fetch upstream

    local base_branch="main"
    git rev-parse --verify main &>/dev/null || base_branch="master"

    echo "Merging upstream/$base_branch..."
    git checkout $base_branch
    git merge upstream/$base_branch

    echo ""
    echo "Fork synced! Push changes with:"
    echo "git push origin $base_branch"
}

# List all GitHub Actions workflows
ghactions() {
    echo "=== GitHub Actions Workflows ==="
    gh workflow list

    echo ""
    echo "Run workflow with: ghrun <workflow-name>"
}

# Trigger workflow run
ghrun() {
    if [[ -z $1 ]]; then
        echo "Usage: ghrun <workflow-name-or-file>"
        ghactions
        return 1
    fi

    local workflow=$1

    echo "Triggering workflow: $workflow"
    gh workflow run $workflow

    if [[ $? -eq 0 ]]; then
        echo ""
        echo "Workflow triggered! Monitor with:"
        echo "gh run watch"
    fi
}

# View workflow logs
ghlogs() {
    if [[ -z $1 ]]; then
        echo "Usage: ghlogs <run-id>"
        echo ""
        echo "Recent runs:"
        gh run list --limit 10
        return 1
    fi

    gh run view $1 --log
}

# Check workflow status
ghstatus() {
    echo "=== Recent Workflow Runs ==="
    gh run list --limit 10

    echo ""
    echo "Watch specific run with: gh run watch <run-id>"
}

# List repository secrets (names only, not values)
ghsecrets() {
    echo "=== Repository Secrets ==="
    gh secret list
}

# Create PR with template
prcreate() {
    local title=$1

    if [[ -z $title ]]; then
        echo "Creating PR interactively..."
        gh pr create
    else
        echo "Creating PR: $title"
        gh pr create --title "$title" --fill
    fi
}

# Check PR status and CI
prcheck() {
    local pr=${1:-$(gh pr view --json number -q .number)}

    if [[ -z $pr ]]; then
        echo "No PR found for current branch"
        return 1
    fi

    echo "=== PR #$pr Status ==="
    gh pr view $pr

    echo ""
    echo "=== CI Checks ==="
    gh pr checks $pr
}

# Merge PR safely
prmerge() {
    local pr=${1:-$(gh pr view --json number -q .number)}

    if [[ -z $pr ]]; then
        echo "No PR found for current branch"
        return 1
    fi

    echo "=== PR #$pr ==="
    gh pr view $pr

    echo ""
    echo "=== CI Status ==="
    gh pr checks $pr

    echo ""
    read -q "REPLY?Merge this PR? (y/n) "
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        gh pr merge $pr --auto --squash
    else
        echo "Cancelled."
    fi
}

# Create draft PR
prdraft() {
    local title=$1

    if [[ -z $title ]]; then
        gh pr create --draft
    else
        gh pr create --draft --title "$title"
    fi
}

# Mark draft PR as ready
prready() {
    local pr=${1:-$(gh pr view --json number -q .number)}

    if [[ -z $pr ]]; then
        echo "No PR found for current branch"
        return 1
    fi

    gh pr ready $pr
    echo "PR #$pr marked as ready for review"
}

# Run tests locally like CI
citest() {
    echo "=== Running Tests (CI Mode) ==="

    # Detect test framework and run
    if [[ -f package.json ]]; then
        echo "Detected Node.js project"
        npm test
    elif [[ -f Makefile ]] && grep -q "^test:" Makefile; then
        echo "Running make test"
        make test
    elif [[ -f pytest.ini ]] || [[ -f setup.py ]]; then
        echo "Detected Python project"
        pytest
    elif [[ -f Cargo.toml ]]; then
        echo "Detected Rust project"
        cargo test
    elif [[ -f go.mod ]]; then
        echo "Detected Go project"
        go test ./...
    else
        echo "No test framework detected"
        echo "Supported: npm, pytest, cargo, go, make"
    fi
}

# Run linters locally
cilint() {
    echo "=== Running Linters (CI Mode) ==="

    # Detect and run linters
    if [[ -f package.json ]]; then
        if grep -q "\"lint\"" package.json; then
            npm run lint
        fi
    elif [[ -f .eslintrc* ]] || [[ -f eslint.config* ]]; then
        npx eslint .
    elif [[ -f .flake8 ]] || [[ -f setup.cfg ]]; then
        flake8 .
    elif [[ -f .pylintrc ]]; then
        pylint **/*.py
    elif [[ -f Cargo.toml ]]; then
        cargo clippy
    elif [[ -f go.mod ]]; then
        golangci-lint run
    fi

    echo ""
    echo "Checking formatting..."
    if [[ -f package.json ]]; then
        npx prettier --check .
    elif [[ -f .black.toml ]] || command -v black &> /dev/null; then
        black --check .
    fi
}

# Build project like CI
cibuild() {
    echo "=== Building Project (CI Mode) ==="

    if [[ -f package.json ]]; then
        npm run build
    elif [[ -f Makefile ]] && grep -q "^build:" Makefile; then
        make build
    elif [[ -f setup.py ]]; then
        python setup.py build
    elif [[ -f Cargo.toml ]]; then
        cargo build --release
    elif [[ -f go.mod ]]; then
        go build ./...
    elif [[ -f Dockerfile ]]; then
        echo "Building Docker image..."
        docker build -t ${PWD##*/}:latest .
    fi
}

# Show CI environment
cienv() {
    echo "=== CI/CD Environment Variables ==="
    echo ""
    echo "Common CI variables to set locally for testing:"
    echo ""
    echo "GitHub Actions:"
    echo "  export CI=true"
    echo "  export GITHUB_ACTIONS=true"
    echo "  export GITHUB_WORKSPACE=$(pwd)"
    echo "  export GITHUB_REPOSITORY=owner/repo"
    echo ""
    echo "GitLab CI:"
    echo "  export CI=true"
    echo "  export GITLAB_CI=true"
    echo "  export CI_PROJECT_DIR=$(pwd)"
    echo ""
    echo "CircleCI:"
    echo "  export CI=true"
    echo "  export CIRCLECI=true"
    echo "  export CIRCLE_WORKING_DIRECTORY=$(pwd)"
}

# Validate CI/CD pipeline config
cipipe() {
    local file=$1

    if [[ -z $file ]]; then
        # Auto-detect CI file
        if [[ -f .github/workflows/*.yml ]] || [[ -f .github/workflows/*.yaml ]]; then
            echo "=== GitHub Actions Workflows ==="
            for f in .github/workflows/*.{yml,yaml}; do
                [[ -f $f ]] && echo "Validating: $f"
                # gh workflow view $(basename $f)
            done
        elif [[ -f .gitlab-ci.yml ]]; then
            echo "Validating GitLab CI config..."
            file=".gitlab-ci.yml"
            # gitlab-ci-lint would go here
        elif [[ -f .circleci/config.yml ]]; then
            echo "Validating CircleCI config..."
            file=".circleci/config.yml"
            circleci config validate $file 2>/dev/null || echo "Install circleci CLI for validation"
        elif [[ -f Jenkinsfile ]]; then
            echo "Found Jenkinsfile"
            file="Jenkinsfile"
        fi
    fi

    if [[ -n $file && -f $file ]]; then
        echo "Checking YAML syntax for: $file"
        if command -v yamllint &> /dev/null; then
            yamllint $file
        else
            python3 -c "import yaml; yaml.safe_load(open('$file'))" && echo "✓ Valid YAML syntax"
        fi
    fi
}

# Check for secrets in code
cisecrets() {
    echo "=== Scanning for Secrets ==="

    if command -v gitleaks &> /dev/null; then
        gitleaks detect --source . --verbose
    elif command -v truffleHog &> /dev/null; then
        truffleHog filesystem .
    else
        echo "Installing gitleaks recommended:"
        echo "brew install gitleaks"
        echo ""
        echo "Quick scan with grep:"
        grep -r -i "api[_-]key\|password\|secret\|token" --include="*.js" --include="*.py" --include="*.env*" . | grep -v node_modules || echo "No obvious secrets found"
    fi
}

# Debug CI failures
cidebug() {
    echo "=== CI Debugging Helper ==="
    echo ""
    echo "Recent failed runs:"
    gh run list --limit 5 --status failure

    echo ""
    echo "Common CI issues:"
    echo "1. Check environment variables (cienv)"
    echo "2. Run tests locally (citest)"
    echo "3. Check for secrets (cisecrets)"
    echo "4. Validate config (cipipe)"
    echo "5. Check Docker build (cibuild)"
    echo ""
    echo "View logs: ghlogs <run-id>"
}

# Download CI artifacts
ciartifacts() {
    local run_id=$1

    if [[ -z $run_id ]]; then
        echo "Usage: ciartifacts <run-id>"
        echo ""
        echo "Recent runs:"
        gh run list --limit 10
        return 1
    fi

    echo "Downloading artifacts from run: $run_id"
    gh run download $run_id
}

# List branches with info
branches() {
    echo "=== Git Branches ==="
    echo ""
    echo "Local branches:"
    git branch -vv

    echo ""
    echo "Remote branches:"
    git branch -r

    echo ""
    echo "Current branch:"
    git branch --show-current
}

# Clean up merged branches
branch-clean() {
    echo "=== Cleaning Merged Branches ==="
    echo ""

    # Fetch and prune
    git fetch -p

    # Get merged branches
    local base_branch=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
    echo "Base branch: $base_branch"
    echo ""

    echo "Merged branches (local):"
    git branch --merged $base_branch | grep -v "^\*\|master\|main\|develop"

    echo ""
    read -q "REPLY?Delete these branches? (y/n) "
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git branch --merged $base_branch | grep -v "^\*\|master\|main\|develop" | xargs -n 1 git branch -d
        echo "Cleaned up merged branches!"
    else
        echo "Cancelled."
    fi
}

# Show branches behind main
branch-behind() {
    local base_branch="main"
    git rev-parse --verify main &>/dev/null || base_branch="master"

    echo "=== Branches Behind $base_branch ==="
    echo ""

    git fetch origin

    for branch in $(git branch --format='%(refname:short)'); do
        if [[ $branch != $base_branch ]]; then
            local behind=$(git rev-list --count $branch..origin/$base_branch)
            if [[ $behind -gt 0 ]]; then
                echo "$branch is $behind commits behind"
            fi
        fi
    done
}

# Rename current branch
branch-rename() {
    if [[ -z $1 ]]; then
        echo "Usage: branch-rename <new-name>"
        echo "Current branch: $(git branch --show-current)"
        return 1
    fi

    local new_name=$1
    local old_name=$(git branch --show-current)

    echo "Renaming branch: $old_name -> $new_name"
    git branch -m $new_name

    echo ""
    echo "Branch renamed locally!"
    echo "To rename on remote:"
    echo "  git push origin :$old_name $new_name"
    echo "  git push origin -u $new_name"
}

# Quick commit and push
qcommit() {
    if [[ -z $1 ]]; then
        echo "Usage: qcommit <message>"
        return 1
    fi

    git add -A
    git commit -m "$1"
    git push
}

# Git work in progress
wip() {
    git add -A
    git commit -m "WIP: work in progress"
}

# Undo last commit (keep changes)
uncommit() {
    echo "Undoing last commit (keeping changes)..."
    git reset HEAD~1
}
