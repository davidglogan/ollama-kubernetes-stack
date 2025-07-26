# Contributing to Ollama Kubernetes Stack

We welcome contributions to the Ollama Kubernetes Stack! This document provides guidelines for contributing to the project.

## 🚀 Quick Start for Contributors

### Prerequisites
- Kubernetes cluster (MicroK8s or equivalent)
- Helm v3.12+
- kubectl configured for your cluster
- Git and GitHub account

### Development Setup

1. **Fork and Clone**
```bash
git clone https://github.com/your-username/ollama-kubernetes-stack.git
cd ollama-kubernetes-stack
```

2. **Create Development Branch**
```bash
git checkout -b feature/your-feature-name
```

3. **Test Your Changes**
```bash
# Lint Helm charts
helm lint charts/ollama-stack

# Dry run deployment
helm template test charts/ollama-stack --dry-run

# Test installation
./scripts/install.sh
```

## 📝 Contribution Types

### 🐛 Bug Reports
- Use GitHub Issues with the bug report template
- Include system information and error logs
- Provide steps to reproduce the issue

### ✨ Feature Requests  
- Use GitHub Issues with the feature request template
- Describe the use case and expected behavior
- Consider backward compatibility

### 📚 Documentation
- Improve existing documentation
- Add examples and tutorials
- Update architecture diagrams

### 🔧 Code Contributions
- Helm chart improvements
- Script enhancements
- CI/CD pipeline updates

## 🛠️ Development Guidelines

### Code Standards

**Helm Charts:**
- Follow Helm best practices
- Use consistent naming conventions
- Include proper labels and annotations
- Add resource limits and requests

**Scripts:**
- Use bash with set -euo pipefail
- Include error handling
- Add helpful output messages
- Follow shell script best practices

**Documentation:**
- Use clear, concise language
- Include code examples
- Update diagrams when architecture changes
- Regenerate docs using: `python scripts/documentation/generate_docs.py`

### Testing Requirements

**Before Submitting:**
```bash
# 1. Lint Helm charts
helm lint charts/ollama-stack

# 2. Test template rendering
helm template ollama-test charts/ollama-stack

# 3. Test actual deployment
./scripts/install.sh

# 4. Verify functionality
curl -s http://192.168.1.101:8080
curl -s http://192.168.1.102:3000

# 5. Run system checks
./scripts/system-status.sh
```

## 📋 Pull Request Process

### 1. Preparation
- Ensure your fork is up to date
- Create a feature branch from main
- Make your changes with clear, atomic commits

### 2. Testing
- Test changes in a real Kubernetes environment
- Verify all services remain functional
- Update documentation if needed

### 3. Submission
- Create pull request with clear description
- Reference any related issues
- Include testing steps and verification

### 4. Review Process
- Address reviewer feedback
- Keep discussions focused and constructive
- Update PR based on review comments

## 🔄 Release Process

### Version Management
- Follow Semantic Versioning (SemVer)
- Update CHANGELOG.md for all changes
- Tag releases with proper version numbers

### Release Checklist
- [ ] All tests pass
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version bumped in Chart.yaml
- [ ] Release notes prepared

## 🏗️ Architecture Guidelines

### Namespace Organization
- Keep application and monitoring separated
- Use consistent naming conventions
- Follow Kubernetes best practices

### Storage Patterns
- Use PersistentVolumeClaims for data
- Configure appropriate storage classes
- Plan for backup and recovery

### Service Design
- Use appropriate service types
- Configure health checks
- Plan for scaling requirements

## 📊 Monitoring and Observability

### Metrics Guidelines
- Expose meaningful metrics
- Use standard metric names
- Include proper labels and tags

### Logging Standards
- Use structured logging
- Include correlation IDs
- Avoid logging sensitive data

## 🔒 Security Considerations

### Security Best Practices
- Follow least privilege principle
- Use RBAC appropriately
- Secure service communication
- Regular security updates

### Secrets Management
- Never commit secrets to git
- Use Kubernetes secrets appropriately
- Consider external secret management

## 🆘 Getting Help

### Communication Channels
- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and ideas
- **Documentation**: Check docs/ directory first

### Mentorship
- New contributors are welcome
- Ask questions in discussions
- Pair programming sessions available

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing to Ollama Kubernetes Stack!**

Generated on: 2025-07-26
