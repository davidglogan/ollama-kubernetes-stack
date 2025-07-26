#!/bin/bash
# Development Workflow Helper

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

show_usage() {
    echo "🌿 Safe Development Workflow"
    echo "==========================="
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  start <feature-name>    Start new feature branch"
    echo "  status                  Show current status"
    echo "  save <message>          Safely commit changes" 
    echo "  push                    Push current branch"
    echo "  switch <branch>         Switch to existing branch"
    echo "  finish                  Merge feature and return to main"
    echo "  emergency               Emergency stash and return to main"
    echo ""
    echo "Examples:"
    echo "  $0 start security-fixes"
    echo "  $0 save 'Add example configuration'"
    echo "  $0 push"
    echo "  $0 finish"
}

start_feature() {
    local feature_name="$1"
    
    if [[ -z "$feature_name" ]]; then
        echo "❌ Feature name required"
        echo "Usage: $0 start <feature-name>"
        exit 1
    fi
    
    # Sanitize branch name
    feature_name=$(echo "$feature_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g')
    local branch_name="feature/$feature_name"
    
    print_info "Starting new feature: $branch_name"
    
    # Ensure we're on main
    if git show-ref --verify --quiet refs/heads/main; then
        git checkout main
    else
        git checkout master
    fi
    
    # Pull latest
    if git remote get-url origin &>/dev/null; then
        git pull origin $(git branch --show-current)
    fi
    
    # Create branch
    git checkout -b "$branch_name"
    print_success "Created branch: $branch_name"
    print_info "You can now safely make changes!"
}

safe_save() {
    local message="$1"
    
    if [[ -z "$message" ]]; then
        echo "❌ Commit message required"
        echo "Usage: $0 save '<message>'"
        exit 1
    fi
    
    print_info "Staging changes..."
    git add .
    
    print_info "Checking for sensitive data..."
    # The pre-commit hook will handle this
    
    git commit -m "$message"
    print_success "Changes committed safely!"
}

show_status() {
    echo "📊 Current Development Status"
    echo "============================"
    echo ""
    echo "Current branch: $(git branch --show-current)"
    echo "Last commit: $(git log -1 --pretty=format:'%h - %s (%cr)')"
    echo ""
    echo "Changes:"
    git status --short
    echo ""
    echo "Recent branches:"
    git branch --sort=-committerdate | head -5
}

push_current() {
    local current_branch=$(git branch --show-current)
    
    if [[ "$current_branch" == "main" || "$current_branch" == "master" ]]; then
        print_warning "You're on $current_branch branch"
        read -p "Are you sure you want to push to $current_branch? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Push cancelled"
            return 1
        fi
    fi
    
    print_info "Pushing $current_branch to origin..."
    git push -u origin "$current_branch"
    print_success "Branch pushed successfully!"
}

finish_feature() {
    local current_branch=$(git branch --show-current)
    
    if [[ "$current_branch" == "main" || "$current_branch" == "master" ]]; then
        print_warning "Already on $current_branch branch"
        return 0
    fi
    
    print_info "Finishing feature: $current_branch"
    
    # Switch to main
    if git show-ref --verify --quiet refs/heads/main; then
        git checkout main
        git pull origin main
        git merge "$current_branch"
    else
        git checkout master
        git pull origin master
        git merge "$current_branch"
    fi
    
    print_success "Feature merged successfully!"
    
    # Optionally delete feature branch
    read -p "Delete feature branch $current_branch? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git branch -d "$current_branch"
        print_success "Feature branch deleted"
    fi
}

emergency_stash() {
    print_warning "Emergency stash - saving all work"
    git add .
    git stash push -m "Emergency stash - $(date)"
    
    if git show-ref --verify --quiet refs/heads/main; then
        git checkout main
    else
        git checkout master
    fi
    
    print_success "Work stashed and switched to main branch"
    print_info "Recover with: git stash pop"
}

# Main command handler
case "${1:-}" in
    "start")
        start_feature "${2:-}"
        ;;
    "status")
        show_status
        ;;
    "save")
        safe_save "${2:-}"
        ;;
    "push")
        push_current
        ;;
    "switch")
        git checkout "${2:-}"
        ;;
    "finish")
        finish_feature
        ;;
    "emergency")
        emergency_stash
        ;;
    *)
        show_usage
        ;;
esac
