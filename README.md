# Development Environment Setup with Ansible

Automated configuration for Ubuntu/Debian servers using Ansible. This repository provides a complete, idempotent setup for a full-featured development environment.

This assumes an already installed barebone server, with a user that has SSH access setup and has full NOPASSWD sudo rights. If that's the case just add an entry to the inventory.ini (see inventory.ini.example for an example) and run make setup.

## Features

This setup installs and configures:

- **Shell**: zsh with oh-my-zsh
- **Version Control**: git
- **Containers**: Docker + Docker Compose
- **Editor**: Neovim with plugins and custom config
- **Languages**:
  - PHP 8.4 (CLI + Composer)
  - Go 1.25.3
  - Node.js 22 (+ npm, yarn, pnpm)
  - Python 3 (+ pip, virtualenv, poetry)
- **CLI Tools**: curl, wget, unzip, btop, tmux, lazygit, fzf, ripgrep, fd
- **AI Tools**: Claude Code CLI, OpenCode CLI

## Quick Start

### Prerequisites

- A fresh Ubuntu or Debian server (local or remote)
- SSH access to the target server (for remote setup)
- SSH key-based authentication configured (for remote setup)
- Python 3 installed on the target
- Sudo privileges on the target machine

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
go_version: "1.25.3"
nodejs_version: "22"
php_version: "8.4"
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
make check
```

## Idempotency

This setup is fully idempotent - you can run it multiple times safely. It will:
- Skip installations if already present
- Update configurations if changed
- Only make necessary changes

## Requirements

- Ubuntu 20.04+ or Debian 11+
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
