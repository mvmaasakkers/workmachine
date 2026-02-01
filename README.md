# Development Environment Setup with Ansible

Automated configuration for Ubuntu/Debian/Pop!_OS servers using Ansible. This repository provides a complete, idempotent setup for a full-featured development environment.

This assumes an already installed barebone server, with a user that has SSH access setup and has full NOPASSWD sudo rights. If that's the case just add an entry to the inventory.ini (see inventory.ini.example for an example) and run make setup.

## Features

This setup installs and configures:

- **Shell**: zsh with oh-my-zsh
- **Version Control**: git
- **Containers**: Docker + Docker Compose
- **Editor**: Neovim with plugins and custom config
- **Languages**:
  - PHP 8.4 (CLI + Composer)
  - Go 1.25.6
  - Node.js 24 (+ npm, yarn, pnpm)
  - Python 3.13 (+ pip, virtualenv, poetry)
- **CLI Tools**: curl, wget, unzip, btop, tmux, lazygit, fzf, ripgrep, fd
- **AI Tools**: Claude Code CLI, OpenCode CLI
- **DevOps**: DevPod CLI

## Quick Start

### Prerequisites

- A fresh Ubuntu, Debian, or Pop!_OS server (local or remote)
- SSH access to the target server (for remote setup)
- SSH key-based authentication configured (for remote setup)
- Python 3 installed on the target
- Sudo privileges on the target machine
  - **Remote setup**: User with NOPASSWD sudo rights (recommended)
  - **Local setup**: Any user with sudo access

### Installation

1. **Clone this repository**:
   ```bash
   git clone <your-repo-url>
   cd workmachine
   ```

2. **Configure target server** (skip for local setup):
   Copy the example inventory file and update it with your server details:
   ```bash
   cp inventory.ini.example inventory.ini
   ```

   Edit `inventory.ini` and update the IP address and username:
   ```ini
   [devserver]
   192.168.x.x ansible_user=YOUR_USERNAME
   ```

3. **Run the setup**:

   **For remote server**:
   ```bash
   make setup
   ```

   **For local machine**:
   ```bash
   make setup-local
   ```

   You'll be prompted for the sudo password.

## Usage

### Makefile Targets

```bash
make help              # Show all available commands
make setup             # Run full setup on remote server
make setup-local       # Run full setup on local machine
make lint              # Run ansible-lint
make check             # Dry-run (no changes made)
make check-local       # Dry-run on local machine (no changes made)
make test              # Dry-run with diff output
make tags              # Show available tags
make clean             # Clean up temporary files
```

### Running Specific Roles

You can run individual roles using tags:

```bash
# Install only Docker
make run-role TAG=docker

# Install only PHP
make run-role TAG=php

# Install all languages
make run-role TAG=languages
```

Available tags:
- `common`, `base` - Basic tools
- `zsh`, `shell` - Shell setup
- `docker`, `containers` - Docker setup
- `nvim`, `editor` - Neovim setup
- `php`, `go`, `golang`, `nodejs`, `node`, `python`, `languages` - Programming languages
- `claude-code`, `claude`, `opencode`, `ai`, `tools` - AI coding assistants

### Customizing Versions

Edit `vars.yml` to customize versions:

```yaml
go_version: "1.25.6"
nodejs_version: "24"
php_version: "8.4"
python_version: "3.13"
```

Then re-run the setup:
```bash
make setup
```

## Project Structure

```
workmachine/
├── playbooks/
│   └── setup.yml               # Main playbook
├── roles/
│   ├── common/                 # Basic CLI tools
│   ├── zsh/                    # Zsh + oh-my-zsh
│   ├── docker/                 # Docker setup
│   ├── nvim/                   # Neovim + config
│   ├── php/                    # PHP + Composer
│   ├── go/                     # Go language
│   ├── nodejs/                 # Node.js + npm
│   ├── python/                 # Python + pip
│   ├── claude-code/            # Claude Code CLI
│   └── opencode/               # OpenCode CLI
├── ansible.cfg                 # Ansible configuration
├── inventory.ini               # Server inventory
├── vars.yml                    # Version configuration
├── Makefile                    # Automation commands
├── .ansible-lint               # Linting configuration
└── README.md                   # This file
```

## Post-Installation

After the setup completes:

1. **Log out and back in** for group changes (Docker) to take effect
2. **Start a new zsh session**:
   ```bash
   exec zsh
   ```
3. **Verify installations**:
   ```bash
   docker --version
   go version
   node --version
   php --version
   python3 --version
   nvim --version
   claude --version
   opencode --version
   ```
4. **Authenticate AI tools**:
   ```bash
   claude login        # Claude Code CLI
   opencode            # OpenCode CLI (interactive setup)
   ```

## Configuration Files

Configuration files are managed via external Git repositories (private):

- **Neovim**: [git@github.com:mvmaasakkers/nvim.git](https://github.com/mvmaasakkers/nvim) → `~/.config/nvim/`
- **tmux**: [git@github.com:mvmaasakkers/tmux.git](https://github.com/mvmaasakkers/tmux) → `~/.config/tmux/`
- **zsh**: [git@github.com:mvmaasakkers/zsh.git](https://github.com/mvmaasakkers/zsh) → `~/.config/zsh/` (symlinked to `~/.zshrc`)

### Customizing Configs

To modify the configurations:

1. Edit the config files in the respective Git repositories
2. Push changes to the repository
3. Re-run the setup to pull updates:
   ```bash
   make setup
   ```

**Note**: The setup removes any existing `~/.tmux.conf` file and uses the new XDG-compliant location `~/.config/tmux/` for tmux configuration.

## Neovim Configuration

Neovim configuration is managed via a separate Git repository: [mvmaasakkers/nvim](https://github.com/mvmaasakkers/nvim)

The setup clones this repository to `~/.config/nvim/` and runs `Lazy! sync` to install plugins.

## tmux Configuration

tmux configuration is managed via a separate Git repository: [mvmaasakkers/tmux](https://github.com/mvmaasakkers/tmux)

The setup:
1. Removes any existing `~/.tmux.conf` file
2. Clones the repository to `~/.config/tmux/`

tmux 3.1+ supports XDG-compliant config locations, automatically loading from `~/.config/tmux/tmux.conf`.

## zsh Configuration

zsh configuration is managed via a separate Git repository: [mvmaasakkers/zsh](https://github.com/mvmaasakkers/zsh)

The setup:
1. Installs zsh and oh-my-zsh
2. Clones the repository to `~/.config/zsh/`
3. Creates a symlink from `~/.zshrc` to `~/.config/zsh/.zshrc`

Your zsh repo should contain a `.zshrc` file that sources oh-my-zsh and includes your customizations.

## Sudo Password Configuration

### Remote Server Setup

This setup assumes the remote user has **NOPASSWD sudo rights**. To configure this on your remote server:

```bash
# On the remote server, add this line to /etc/sudoers
echo "YOUR_USERNAME ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/YOUR_USERNAME
sudo chmod 0440 /etc/sudoers.d/YOUR_USERNAME
```

If you cannot configure NOPASSWD sudo, use one of the methods below.

### Alternative Methods for Sudo Password

#### Method 1: Interactive Prompt (Most Secure)
**Status**: Already configured for local setup in Makefile

For local setup:
```bash
make setup-local  # Prompts for password
```

For remote setup, modify the Makefile:
```bash
ansible-playbook -i inventory.ini playbooks/setup.yml --ask-become-pass
```

#### Method 2: Environment Variable (Convenient)
Set the password as an environment variable:

```bash
export ANSIBLE_BECOME_PASSWORD='your_sudo_password'
make setup-local
```

Or run directly:
```bash
ANSIBLE_BECOME_PASSWORD='your_sudo_password' ansible-playbook -i localhost, playbooks/setup.yml --connection=local
```

#### Method 3: Ansible Vault (Secure + Automated)
Store the password encrypted in a vault file:

1. **Create a vault file**:
   ```bash
   ansible-vault create vault.yml
   ```
   
   Add this content:
   ```yaml
   ansible_become_password: your_sudo_password
   ```

2. **Update inventory.ini** to use the vault:
   ```ini
   [devserver]
   192.168.x.x ansible_user=YOUR_USERNAME
   
   [devserver:vars]
   @vault.yml
   ```

3. **Run with vault password**:
   ```bash
   ansible-playbook -i inventory.ini playbooks/setup.yml --ask-vault-pass
   ```

4. **Or use a vault password file**:
   ```bash
   echo "your_vault_password" > .vault_pass
   chmod 600 .vault_pass
   echo ".vault_pass" >> .gitignore
   
   ansible-playbook -i inventory.ini playbooks/setup.yml --vault-password-file .vault_pass
   ```

#### Method 4: Inventory Variable (Least Secure - Not Recommended)
Add directly to inventory.ini (⚠️ **NOT recommended** - stores password in plaintext):

```ini
[devserver]
192.168.x.x ansible_user=YOUR_USERNAME ansible_become_password=your_password
```

### Recommendation

- **Remote servers**: Configure NOPASSWD sudo (most convenient)
- **Local machine**: Use `--ask-become-pass` (default in `make setup-local`)
- **CI/CD pipelines**: Use Ansible Vault with vault password file
- **Never commit plaintext passwords** to version control

## Troubleshooting

### Ansible not found
```bash
make install-ansible
```

### Permission denied for Docker
Log out and back in, or run:
```bash
newgrp docker
```

### SSH connection issues
Ensure you can connect manually:
```bash
ssh YOUR_USERNAME@YOUR_SERVER_IP
```

If you get a host key verification error, add the server to your known_hosts:
```bash
ssh-keyscan -H YOUR_SERVER_IP >> ~/.ssh/known_hosts
```

For SSH key setup (recommended):
```bash
# Generate SSH key if you don't have one
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy your public key to the server
ssh-copy-id YOUR_USERNAME@YOUR_SERVER_IP
```

### Check mode (dry-run)
To see what would change without making changes:
```bash
make check          # For remote servers
make check-local    # For local machine
```

### Pop!_OS Support
Pop!_OS is fully supported! The setup automatically:
- Uses Ubuntu package repositories for Docker and other tools
- Handles Pop!_OS distribution detection correctly
- Works with Pop!_OS 22.04+ (based on Ubuntu 22.04+)

## Idempotency

This setup is fully idempotent - you can run it multiple times safely. It will:
- Skip installations if already present
- Update configurations if changed
- Only make necessary changes

## Requirements

- Ubuntu 20.04+ or Debian 11+ or Pop!_OS 22.04+
- Python 3.6+
- SSH access (for remote setup)
- Sudo privileges

## Contributing

Feel free to customize roles and add new ones. Each role is independent and reusable.

To add a new role:
1. Create role directory: `mkdir -p roles/newrole/tasks`
2. Add tasks: `roles/newrole/tasks/main.yml`
3. Include in playbook: Edit `playbooks/setup.yml`

## License

MIT

## Support

For issues or questions, refer to the Ansible documentation:
- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
