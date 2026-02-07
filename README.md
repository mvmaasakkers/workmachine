# Development Environment Setup with Ansible

Automated configuration for **Linux** (Ubuntu/Debian/Pop!_OS) and **macOS** (Intel/Apple Silicon) using Ansible. This repository provides a complete, idempotent setup for a full-featured development environment.

## Platform Support

- ✅ **Linux**: Ubuntu 20.04+, Debian 11+, Pop!_OS 22.04+
- ✅ **macOS**: Intel and Apple Silicon (requires Homebrew)

For remote Linux servers: Assumes a barebone server with SSH access and NOPASSWD sudo rights. Add an entry to inventory.ini and run `make setup`.

For local machines (Linux or macOS): Run `make setup-local` and enter your sudo password when prompted.

## Features

This setup installs and configures:

- **Shell**: zsh with oh-my-zsh, Nerd Fonts (Hack, Meslo, FiraCode, JetBrainsMono)
- **Terminal**: Alacritty with custom config
- **Version Control**: git
- **Containers**: Docker + Docker Compose
- **Editor**: Neovim with plugins and custom config
- **Languages**:
  - PHP 8.4 (CLI + Composer)
  - Go 1.25.6
  - Node.js 24 via nvm (+ npm, yarn, pnpm, Bun)
  - Python 3.13 (+ pip, virtualenv, poetry)
- **CLI Tools**: curl, wget, unzip, btop, tmux, lazygit, fzf, ripgrep, fd
- **AI Tools**: Claude Code CLI, OpenCode CLI
- **DevOps**: DevPod CLI, Terraform, Packer, Azure CLI, Google Cloud SDK

## Quick Start

### Prerequisites

**For Linux:**
- Ubuntu 20.04+, Debian 11+, or Pop!_OS 22.04+
- Python 3 installed
- Sudo privileges
  - **Remote**: User with NOPASSWD sudo rights (recommended)
  - **Local**: Any user with sudo access

**For macOS:**
- macOS with Intel or Apple Silicon
- **Homebrew** installed (required):
  ```bash
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```
- Ansible installed via Homebrew:
  ```bash
  brew install ansible
  ```

**For Remote Setup (SSH):**
- SSH access to the target server
- SSH key-based authentication configured

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
- `alacritty`, `tmux`, `terminal` - Terminal setup
- `docker`, `containers` - Docker setup
- `nvim`, `editor` - Neovim setup
- `php`, `go`, `golang`, `nodejs`, `node`, `python`, `languages` - Programming languages
- `claude-code`, `claude`, `opencode`, `ai`, `tools` - AI coding assistants
- `terraform`, `packer`, `iac`, `devops` - Infrastructure as Code tools
- `azure-cli`, `azure`, `gcloud`, `gcp`, `cloud` - Cloud provider CLIs

### Customizing Versions

Edit `vars.yml` to customize versions:

```yaml
go_version: "1.25.6"
nodejs_version: "24"
php_version: "8.4"
python_version: "3.13"
terraform_version: "1.14.4"
packer_version: "1.15.0"
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
│   ├── common/                 # Basic CLI tools (git, tmux, lazygit, etc.)
│   ├── zsh/
│   │   ├── files/              # zsh config (.zshrc)
│   │   └── tasks/
│   ├── alacritty/
│   │   ├── files/              # Alacritty config (alacritty.toml, etc.)
│   │   └── tasks/
│   ├── tmux/
│   │   ├── files/              # tmux config (tmux.conf, plugins/)
│   │   └── tasks/
│   ├── nvim/
│   │   ├── files/              # Neovim config (init.lua, lua/)
│   │   └── tasks/
│   ├── docker/                 # Docker setup
│   ├── php/                    # PHP + Composer
│   ├── go/                     # Go language
│   ├── nodejs/                 # Node.js via nvm
│   ├── python/                 # Python + pip
│   ├── claude-code/            # Claude Code CLI
│   ├── opencode/               # OpenCode CLI
│   ├── terraform/              # HashiCorp Terraform
│   ├── packer/                 # HashiCorp Packer
│   ├── azure-cli/              # Microsoft Azure CLI
│   └── gcloud/                 # Google Cloud SDK
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
   terraform --version
   packer --version
   az --version
   gcloud --version
   ```
4. **Authenticate AI tools**:
   ```bash
   claude login        # Claude Code CLI
   opencode            # OpenCode CLI (interactive setup)
   ```
5. **Authenticate cloud CLIs**:
   ```bash
   az login            # Azure CLI
   gcloud init         # Google Cloud SDK
   ```

## Configuration Files

Configuration files are embedded directly in this repository under each role's `files/` directory:

| Config | Source | Destination |
|--------|--------|-------------|
| Neovim | `roles/nvim/files/` | `~/.config/nvim/` |
| tmux | `roles/tmux/files/` | `~/.config/tmux/` |
| zsh | `roles/zsh/files/` | `~/.config/zsh/` |
| Alacritty | `roles/alacritty/files/` | `~/.config/alacritty/` |

### Customizing Configs

Edit the files directly in this repository and re-run the setup:

```bash
# Edit config
vim roles/nvim/files/lua/config/options.lua

# Deploy changes
make setup-local
```

Changes are deployed atomically with the rest of your environment setup.

## Neovim Configuration

Located in `roles/nvim/files/`. Uses [LazyVim](https://www.lazyvim.org/) as the base configuration.

The setup copies the configuration to `~/.config/nvim/` and runs `Lazy! sync` to install plugins.

## tmux Configuration

Located in `roles/tmux/files/`. Features:
- Catppuccin theme (Frappe flavor)
- Mouse support enabled
- OSC 52 clipboard (works over SSH)
- Vi-mode copy bindings

The setup removes any existing `~/.tmux.conf` and deploys to `~/.config/tmux/` (XDG-compliant).

## zsh Configuration

Located in `roles/zsh/files/`. The setup:
1. Installs zsh and oh-my-zsh
2. Deploys config to `~/.config/zsh/`
3. Creates a symlink from `~/.zshrc` to `~/.config/zsh/.zshrc`

## Alacritty Configuration

Located in `roles/alacritty/files/`. Includes:
- `alacritty.toml` - Main configuration
- `linux.toml` - Linux-specific settings
- `macos.toml` - macOS-specific settings

The setup installs Alacritty and deploys config to `~/.config/alacritty/`.

## Node.js via nvm

Node.js is installed using [nvm](https://github.com/nvm-sh/nvm) (Node Version Manager) for consistent cross-platform behavior.

The setup:
1. Installs nvm to `~/.nvm/`
2. Installs the configured Node.js version (default: 24)
3. Sets it as the default version
4. Installs global packages: yarn, pnpm, typescript, ts-node, nodemon

To switch Node.js versions:
```bash
nvm install 22        # Install Node 22
nvm use 22            # Use Node 22 in current shell
nvm alias default 22  # Set Node 22 as default
```

To use a specific version per project, create a `.nvmrc` file:
```bash
echo "22" > .nvmrc
nvm use  # Reads from .nvmrc
```

## Nerd Fonts

The zsh role automatically installs four popular Nerd Fonts with powerline glyphs:
- **Hack Nerd Font** - Clean, monospaced font optimized for source code
- **Meslo Nerd Font** - A variant of Menlo with added glyphs
- **FiraCode Nerd Font** - Popular monospaced font with ligatures
- **JetBrainsMono Nerd Font** - Designed for developers by JetBrains

Fonts are installed to `~/.local/share/fonts/NerdFonts/` and the font cache is updated automatically.

To use these fonts in your terminal:
- **Alacritty**: Set `font.normal.family` in your config to `"Hack Nerd Font Mono"`, `"MesloLGS Nerd Font"`, `"FiraCode Nerd Font"`, or `"JetBrainsMono Nerd Font"`
- **Other terminals**: Select the Nerd Font variant in your terminal preferences

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

- **OS**: Ubuntu 20.04+, Debian 11+, Pop!_OS 22.04+, or macOS (Intel/Apple Silicon)
- **Python**: 3.6+
- **macOS Only**: Homebrew (package manager)
- **SSH**: Required for remote setup
- **Sudo**: Privileges required

## Documentation

- **[macOS Support Guide](docs/MACOS_SUPPORT.md)** - Complete macOS setup guide, troubleshooting, and platform differences
- **[Config Repository Prompts](docs/config-repo-prompts/README.md)** - AI-assisted prompts for reviewing your personal config repos for cross-platform compatibility
- **[Sudo Password Configuration](#sudo-password-configuration)** - Multiple methods for setting ansible sudo password

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
