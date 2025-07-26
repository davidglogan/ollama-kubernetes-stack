# Git Management Guide for Ollama Kubernetes Stack

## 🚀 Initial Setup

### Installing Git on Ubuntu

```bash
# Update package list
sudo apt update

# Install Git
sudo apt install git -y

# Verify installation
git --version
```

### Initial Configuration

```bash
# Set your identity
git config --global user.name "Your Full Name"
git config --global user.email "your.email@example.com"

# Set default branch name
git config --global init.defaultBranch main

# Set default editor (optional)
git config --global core.editor "nano"

# Enable colored output
git config --global color.ui auto

# View all configurations
git config --list
```

### SSH Key Setup for GitHub

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your.email@example.com"
# Press Enter for default location
# Enter passphrase (optional but recommended)

# Start SSH agent
eval "$(ssh-agent -s)"

# Add SSH key to agent
ssh-add ~/.ssh/id_ed25519

# Copy public key to clipboard
cat ~/.ssh/id_ed25519.pub
# Copy this output to GitHub Settings → SSH Keys
```

**Adding SSH Key to GitHub:**
1. Go to [GitHub.com](https://github.com) → Settings → SSH and GPG keys
2. Click "New SSH key"
3. Give it a title (e.g., "Ubuntu AI Server")
4. Paste the public key
5. Click "Add SSH key"

### Test GitHub Connection

```bash
# Test SSH connection
ssh -T git@github.com
# Should return: "Hi username! You've successfully authenticated..."
```

## 📁 Repository Management

### Initialize Repository

```bash
cd ~/ai

# Initialize Git repository
git init

# Check repository status
git status

# View all files (including hidden)
ls -la
```

### Basic Git Workflow

```bash
# 1. Check status
git status

# 2. Add files to staging
git add .                    # Add all files
git add filename.txt         # Add specific file
git add docs/               # Add directory

# 3. Commit changes
git commit -m "Descriptive commit message"

# 4. View commit history
git log --oneline
git log --graph --oneline --all
```

### Remote Repository Setup

```bash
# Add remote repository (replace YOUR_USERNAME)
git remote add origin git@github.com:YOUR_USERNAME/ollama-kubernetes-stack.git

# Verify remote
git remote -v

# Push to remote repository
git push -u origin main

# For subsequent pushes
git push
```

## 🌿 Branch Management

### Creating and Switching Branches

```bash
# Create new branch
git branch feature-name

# Switch to branch
git checkout feature-name

# Create and switch in one command
git checkout -b feature-name

# List all branches
git branch -a

# Switch back to main
git checkout main
```

### Branch Operations

```bash
# Merge branch into main
git checkout main
git merge feature-name

# Delete branch after merging
git branch -d feature-name

# Force delete branch
git branch -D feature-name

# Push branch to remote
git push -u origin feature-name

# Delete remote branch
git push origin --delete feature-name
```

## 📝 Common Git Commands

### Status and Information

```bash
# Check repository status
git status

# View commit history
git log
git log --oneline
git log --graph --oneline --all

# Show changes in files
git diff
git diff --staged
git diff HEAD~1

# Show specific commit
git show COMMIT_HASH
```

### Staging and Committing

```bash
# Stage files
git add filename.txt
git add .
git add -A

# Unstage files
git reset filename.txt
git reset .

# Commit with message
git commit -m "Your commit message"

# Commit all tracked files
git commit -am "Your commit message"

# Amend last commit
git commit --amend
```

### Remote Operations

```bash
# Clone repository
git clone git@github.com:username/repo-name.git

# Fetch changes from remote
git fetch origin

# Pull changes from remote
git pull origin main

# Push changes to remote
git push origin main

# Push all branches
git push --all origin
```

## 🔄 Workflow for Ollama Stack Updates

### Daily Development Workflow

```bash
# 1. Start of day - get latest changes
git checkout main
git pull origin main

# 2. Create feature branch for your work
git checkout -b update-helm-charts

# 3. Make your changes
# ... edit files ...

# 4. Stage and commit changes
git add .
git commit -m "Update Helm charts with new resource limits"

# 5. Push feature branch
git push -u origin update-helm-charts

# 6. Create Pull Request on GitHub
# 7. After review, merge and cleanup
git checkout main
git pull origin main
git branch -d update-helm-charts
```

### Common Update Scenarios

**Updating Documentation:**
```bash
git checkout -b docs-update
# Edit documentation files
python3 scripts/documentation/generate_docs.py
git add docs/
git commit -m "Update documentation with latest system info"
git push -u origin docs-update
```

**Updating Helm Charts:**
```bash
git checkout -b helm-update
# Edit charts/ollama-stack/
helm lint charts/ollama-stack
git add charts/
git commit -m "Update Ollama deployment with new image version"
git push -u origin helm-update
```

**Adding New Features:**
```bash
git checkout -b feature-monitoring-alerts
# Add new monitoring configuration
git add .
git commit -m "Add Grafana alerting rules for AI model performance"
git push -u origin feature-monitoring-alerts
```

## 🚨 Troubleshooting

### Common Issues and Solutions

**Authentication Issues:**
```bash
# Re-add SSH key
ssh-add ~/.ssh/id_ed25519

# Test connection
ssh -T git@github.com

# Check SSH agent
ps aux | grep ssh-agent
```

**Merge Conflicts:**
```bash
# View conflicted files
git status

# Edit conflicted files manually
# Look for <<<<<<< HEAD and >>>>>>> markers

# After resolving conflicts
git add resolved-file.txt
git commit -m "Resolve merge conflict in resolved-file.txt"
```

**Undo Changes:**
```bash
# Undo unstaged changes
git checkout -- filename.txt

# Undo staged changes
git reset HEAD filename.txt

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1
```

**View File History:**
```bash
# See file changes over time
git log --follow filename.txt

# See what changed in a file
git log -p filename.txt

# See who changed what
git blame filename.txt
```

## 📊 Git Best Practices

### Commit Message Guidelines

**Good commit messages:**
```
✅ Add Grafana dashboard for Ollama metrics
✅ Fix LoadBalancer service configuration
✅ Update README with installation instructions
✅ Refactor Helm chart templates for better readability
```

**Bad commit messages:**
```
❌ Fix stuff
❌ Update
❌ Changes
❌ WIP
```

### Commit Message Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples:**
```bash
git commit -m "feat(helm): add resource limits to Ollama deployment"
git commit -m "fix(service): correct LoadBalancer IP configuration"
git commit -m "docs(readme): update installation instructions"
git commit -m "chore(deps): update Kubernetes API version"
```

### Repository Structure Best Practices

```
.gitignore          # Files to ignore
README.md           # Project overview
CHANGELOG.md        # Version history
CONTRIBUTING.md     # Contribution guidelines
charts/             # Helm charts
docs/               # Documentation
scripts/            # Automation scripts
.github/            # GitHub workflows
```

### .gitignore Configuration

```bash
# Create comprehensive .gitignore
cat > .gitignore << 'EOF'
# IDE and Editor
.vscode/
.idea/
*.swp
*.swo
*~

# OS Generated
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Kubernetes
*.log
*.tmp
.kube/
kubeconfig

# Helm
*.tgz
charts/*/charts/
requirements.lock

# Secrets and Keys
secrets/
*.key
*.pem
*.p12
*.crt
authkey
tailscale-*.yaml

# Terraform
*.tfstate
*.tfstate.backup
.terraform/
.terraform.lock.hcl

# Local Development
.env
.env.local
.env.*.local
override.yaml
local-values.yaml
debug.yaml

# Build and Dependencies
node_modules/
dist/
build/
*.tar.gz

# Backup files
*-backup-*
*.backup
EOF
```

## 🔧 Git Aliases for Productivity

```bash
# Set up useful Git aliases
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.cm commit
git config --global alias.cp cherry-pick
git config --global alias.lg "log --oneline --graph --all"
git config --global alias.last "log -1 HEAD"
git config --global alias.unstage "reset HEAD --"

# Usage examples
git st          # git status
git co main     # git checkout main
git lg          # pretty log graph
git cm -m "msg" # git commit -m "msg"
```

## 🚀 Advanced Git Operations

### Stashing Changes

```bash
# Save current work temporarily
git stash

# Save with message
git stash push -m "Work in progress on feature X"

# List stashes
git stash list

# Apply latest stash
git stash apply

# Apply and remove stash
git stash pop

# Apply specific stash
git stash apply stash@{1}

# Clear all stashes
git stash clear
```

### Cherry Picking

```bash
# Apply specific commit from another branch
git cherry-pick COMMIT_HASH

# Cherry pick multiple commits
git cherry-pick HASH1 HASH2 HASH3

# Cherry pick with no commit (stage only)
git cherry-pick --no-commit COMMIT_HASH
```

### Rebasing

```bash
# Interactive rebase to clean up commits
git rebase -i HEAD~3

# Rebase branch onto main
git checkout feature-branch
git rebase main

# Continue rebase after resolving conflicts
git rebase --continue

# Abort rebase
git rebase --abort
```

## 📋 Project-Specific Workflows

### Documentation Updates

```bash
# Update documentation workflow
git checkout -b docs-update-$(date +%Y%m%d)
python3 scripts/documentation/generate_docs.py
python3 docs/architecture/diagrams/generate_ascii_diagrams.py
git add docs/
git commit -m "docs: regenerate documentation with latest system config"
git push -u origin docs-update-$(date +%Y%m%d)
```

### Helm Chart Updates

```bash
# Helm chart update workflow
git checkout -b helm-update-$(date +%Y%m%d)
# Make changes to charts/ollama-stack/
helm lint charts/ollama-stack
helm template test charts/ollama-stack --dry-run
git add charts/
git commit -m "helm: update Ollama stack configuration"
git push -u origin helm-update-$(date +%Y%m%d)
```

### Release Management

```bash
# Create release branch
git checkout -b release-v1.1.0

# Update version in Chart.yaml
# Update CHANGELOG.md
# Final testing

git add .
git commit -m "chore: prepare release v1.1.0"
git push -u origin release-v1.1.0

# After testing, merge to main and tag
git checkout main
git merge release-v1.1.0
git tag -a v1.1.0 -m "Release version 1.1.0"
git push origin main --tags
```

---

## 🎯 Quick Reference

### Essential Commands
```bash
git status              # Check status
git add .               # Stage all changes
git commit -m "msg"     # Commit with message
git push                # Push to remote
git pull                # Pull from remote
git checkout -b branch  # Create and switch branch
git merge branch        # Merge branch
git log --oneline       # View commit history
```

### Emergency Commands
```bash
git stash               # Save work quickly
git reset --hard HEAD   # Discard all changes
git clean -fd           # Remove untracked files
git reflog              # Show all actions (recovery)
```

This guide covers everything you need for professional Git management of your Ollama Kubernetes Stack project!