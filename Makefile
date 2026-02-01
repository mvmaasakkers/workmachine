.PHONY: help setup setup-local setup-remote lint check check-local install-ansible install-ansible-lint test tags clean

# Default target
help:
	@echo "Available targets:"
	@echo "  make setup          - Run playbook on remote server (192.168.68.71)"
	@echo "  make setup-local    - Run playbook locally on this machine"
	@echo "  make setup-remote   - Same as 'make setup'"
	@echo "  make lint           - Run ansible-lint on playbooks"
	@echo "  make check          - Dry-run the playbook (check mode)"
	@echo "  make check-local    - Dry-run the playbook locally (check mode)"
	@echo "  make install-ansible - Install Ansible via pip"
	@echo "  make install-ansible-lint - Install ansible-lint"
	@echo "  make test           - Run playbook in check mode with diff"
	@echo "  make tags           - Show available tags"
	@echo "  make clean          - Clean up temporary files"

# Install Ansible if not present
install-ansible:
	@if which ansible-playbook > /dev/null 2>&1; then \
		echo "Ansible is already installed"; \
	elif which apt > /dev/null 2>&1; then \
		echo "Installing Ansible via apt..."; \
		sudo apt update && sudo apt install -y ansible; \
	else \
		echo "Installing Ansible via pip..."; \
		pip3 install --user ansible 2>/dev/null || pipx install ansible-core; \
	fi

# Install ansible-lint
install-ansible-lint:
	@if which ansible-lint > /dev/null 2>&1; then \
		echo "ansible-lint is already installed"; \
	elif which apt > /dev/null 2>&1; then \
		echo "Installing ansible-lint via apt..."; \
		sudo apt install -y ansible-lint 2>/dev/null || pipx install ansible-lint; \
	else \
		echo "Installing ansible-lint via pipx..."; \
		pipx install ansible-lint; \
	fi

# Setup remote server (default)
setup: install-ansible
	@echo "Running playbook on remote server..."
	ansible-playbook -i inventory.ini playbooks/setup.yml

setup-remote: setup

# Setup local machine
setup-local: install-ansible
	@echo "Running playbook locally..."
	ansible-playbook -i localhost, playbooks/setup.yml --connection=local --ask-become-pass

# Run ansible-lint
lint: install-ansible-lint
	@echo "Running ansible-lint..."
	ansible-lint playbooks/setup.yml roles/*/tasks/*.yml

# Check mode (dry-run)
check: install-ansible
	@echo "Running playbook in check mode (dry-run)..."
	ansible-playbook -i inventory.ini playbooks/setup.yml --check

# Check mode for local setup (dry-run)
check-local: install-ansible
	@echo "Running playbook locally in check mode (dry-run)..."
	ansible-playbook -i localhost, playbooks/setup.yml --connection=local --ask-become-pass --check 

# Test with diff
test: install-ansible
	@echo "Running playbook in check mode with diff..."
	ansible-playbook -i inventory.ini playbooks/setup.yml --check --diff

# Show available tags
tags: install-ansible
	@echo "Available tags:"
	@ansible-playbook playbooks/setup.yml --list-tags

# Run specific role by tag
# Example: make run-role TAG=docker
run-role: install-ansible
	@if [ -z "$(TAG)" ]; then \
		echo "Error: Please specify TAG=<tag>"; \
		echo "Run 'make tags' to see available tags"; \
		exit 1; \
	fi
	ansible-playbook -i inventory.ini playbooks/setup.yml --tags $(TAG)

# Clean temporary files
clean:
	@echo "Cleaning up temporary files..."
	find . -name "*.retry" -delete
	find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.pyc" -delete
	@echo "Clean complete!"
