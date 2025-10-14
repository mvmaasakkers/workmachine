# Development Environment Setup with Ansible

Automated configuration for Ubuntu/Debian servers using Ansible. This repository provides a complete, idempotent setup for a full-featured development environment.

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
- **CLI Tools**: curl, wget, unzip, btop, tmux

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
│   └── python/                 # Python + pip
├── configs/
│   ├── nvim/
│   │   ├── init.lua            # Neovim main config
│   │   └── lua/
│   │       ├── lazy-bootstrap.lua  # lazy.nvim bootstrap
│   │       └── plugins.lua     # Plugin definitions
│   └── tmux/
│       └── tmux.conf           # tmux configuration
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
   ```

## Configuration Files

All configuration files are stored in the [configs/](configs/) directory, organized by tool:

- **[configs/nvim/](configs/nvim/)** - Neovim configuration files
  - [init.lua](configs/nvim/init.lua) - Main Neovim configuration
  - [lua/lazy-bootstrap.lua](configs/nvim/lua/lazy-bootstrap.lua) - lazy.nvim bootstrap
  - [lua/plugins.lua](configs/nvim/lua/plugins.lua) - Plugin definitions
- **[configs/tmux/](configs/tmux/)** - tmux configuration files
  - [tmux.conf](configs/tmux/tmux.conf) - Main tmux configuration

### Customizing Configs

To modify the configurations:

1. Edit the config files in the `configs/` directory
2. Re-run the setup to deploy changes:
   ```bash
   make setup
   ```

The configurations are deployed to:
- Neovim: `~/.config/nvim/`
- tmux: `~/.tmux.conf`

## Neovim Configuration

The setup includes a modern Neovim configuration with:

- **Plugin Manager**: lazy.nvim (auto-bootstrapped)
- **File Explorer**: NERDTree
- **Status Line**: vim-airline
- **Git Integration**: vim-fugitive
- **Fuzzy Finder**: fzf
- **Color Scheme**: gruvbox
- **Language Support**: vim-polyglot

The configuration is written in Lua and uses lazy.nvim for plugin management, which automatically installs itself on first run.

### Neovim Key Bindings

Leader key: `<Space>`

- `<leader>n` - Toggle NERDTree
- `<leader>f` - Find current file in NERDTree
- `<leader>p` - Fuzzy file search
- `<leader>g` - Search in files (ripgrep)
- `<leader>b` - Buffer list
- `<leader>w` - Save file
- `<leader>q` - Quit
- `<leader>/` - Clear search highlight

## tmux Configuration

The setup includes a feature-rich tmux configuration with:

- **Prefix**: `Ctrl-a` (instead of default `Ctrl-b`)
- **Mouse support**: Enabled
- **Vi mode**: For copy mode navigation
- **256 colors**: Full color support

### tmux Key Bindings

- `Ctrl-a |` - Split pane horizontally
- `Ctrl-a -` - Split pane vertically
- `Ctrl-a h/j/k/l` - Navigate panes (vim-style)
- `Ctrl-a H/J/K/L` - Resize panes
- `Ctrl-a r` - Reload config
- `Alt-Left/Right` - Switch windows

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
