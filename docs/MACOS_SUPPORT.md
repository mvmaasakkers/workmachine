# macOS Support

The workmachine repository now fully supports macOS (both Intel and Apple Silicon) in addition to Linux (Ubuntu/Debian/Pop!_OS).

## Quick Start (macOS)

### Prerequisites

1. **Install Homebrew** (required):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Install Ansible**:
   ```bash
   brew install ansible
   ```

3. **Clone this repository**:
   ```bash
   git clone git@github.com:mvmaasakkers/workmachine.git
   cd workmachine
   ```

### Run the Setup

```bash
make setup-local
```

You'll be prompted for your sudo password.

## What Gets Installed on macOS

### Shell & Terminal
- ✅ **zsh** with oh-my-zsh
- ✅ **Nerd Fonts** (Hack, Meslo, FiraCode, JetBrainsMono) → `~/Library/Fonts/`
- ✅ **Alacritty** terminal emulator

### Development Tools
- ✅ **git**, **curl**, **wget**, **unzip**
- ✅ **btop**, **tmux**, **fzf**, **ripgrep**, **fd**
- ✅ **lazygit** (Git TUI)
- ✅ **jq**, **make**

### Editors
- ✅ **Neovim** with LazyVim configuration

### Programming Languages
- ✅ **Go** 1.25.6
- ✅ **Node.js** 24 (+ npm, yarn, pnpm, TypeScript, Bun)
- ✅ **Python** 3.13 (+ pipx, poetry, pipenv)
- ✅ **PHP** 8.4 (+ Composer)

### Containers
- ✅ **Colima** (lightweight Docker runtime)
- ✅ **Docker CLI** (works with Colima)
- ✅ **docker-compose**

### AI Tools
- ✅ **Claude Code CLI**
- ✅ **OpenCode CLI**

### Other Tools
- ✅ **GitHub CLI** (gh)
- ✅ **DevPod CLI**

## Platform Differences

### Package Management
- **Linux**: apt, PPA repositories
- **macOS**: Homebrew, Homebrew Cask

### Paths

| Purpose | Linux | macOS |
|---------|-------|-------|
| Fonts | `~/.local/share/fonts/` | `~/Library/Fonts/` |
| Homebrew prefix (Intel) | N/A | `/usr/local` |
| Homebrew prefix (Apple Silicon) | N/A | `/opt/homebrew` |
| zsh binary | `/usr/bin/zsh` | `/bin/zsh` or Homebrew zsh |

### Docker
- **Linux**: docker-ce (native daemon)
- **macOS**: Colima (VM-based, lightweight alternative to Docker Desktop)

### Font Management
- **Linux**: Uses fontconfig (`fc-cache`)
- **macOS**: Fonts auto-register when added to `~/Library/Fonts/`

## Architecture Support

Both Intel and Apple Silicon Macs are supported:

- **Intel (x86_64)**: Uses `amd64` binaries
- **Apple Silicon (arm64)**: Uses `arm64` binaries

The playbook automatically detects your architecture and downloads the correct binaries.

## Configuration Repositories

Your personal configuration repositories work on both platforms:

| Repository | macOS Status | Notes |
|------------|--------------|-------|
| **zsh** | ⚠️ Needs review | See `docs/config-repo-prompts/zsh-config-review.md` |
| **alacritty** | ⚠️ Needs review | See `docs/config-repo-prompts/alacritty-config-review.md` |
| **nvim** | ✅ Should work | LazyVim is cross-platform |
| **tmux** | ✅ Should work | Pure tmux config |

**Action Required:** Review and update your config repositories using the prompts in `docs/config-repo-prompts/`. See that directory's README for instructions.

## Known Limitations

### 1. Docker on macOS
- Uses **Colima** instead of Docker Desktop
- Colima runs Docker in a lightweight VM
- Slightly different from native Linux Docker daemon
- Docker Desktop is also supported but requires manual installation

### 2. System-Wide Settings
- `/etc/environment` edits are Linux-only
- macOS doesn't use `/etc/environment` for environment variables
- Editor settings are configured in zsh config instead

### 3. update-alternatives
- Linux-only command
- macOS doesn't have a direct equivalent
- Not needed on macOS (Homebrew manages linking)

## Troubleshooting

### Homebrew Not Found

If you get "Homebrew is not installed":
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After installation, add Homebrew to your PATH:
```bash
# For Apple Silicon
eval "$(/opt/homebrew/bin/brew shellenv)"

# For Intel
eval "$(/usr/local/bin/brew shellenv)"
```

### Colima Won't Start

```bash
# Check Colima status
colima status

# Restart Colima
colima stop
colima start

# Check Docker works
docker ps
```

### SSH Keys for Config Repos

The setup tries to clone your config repositories via SSH. Ensure your SSH keys are set up:

```bash
# Generate SSH key if needed
ssh-keygen -t ed25519 -C "your_email@example.com"

# Add to ssh-agent
ssh-add ~/.ssh/id_ed25519

# Add public key to GitHub
cat ~/.ssh/id_ed25519.pub
# Copy and add to https://github.com/settings/keys
```

### Font Issues

If Nerd Font icons don't show:
1. Check fonts are installed: `ls ~/Library/Fonts/NerdFonts/`
2. Restart your terminal (Alacritty)
3. Update your Alacritty config to use the Nerd Font variant

## Testing Your Setup

After installation, verify everything works:

```bash
# Shell and tools
zsh --version
tmux -V
nvim --version
alacritty --version

# Languages
go version
node --version
python3 --version
php --version

# Docker
docker --version
colima status
docker ps

# CLI tools
gh --version
lazygit --version
```

## Differences from Linux Setup

### What's the Same
- All configuration repositories (zsh, nvim, tmux, alacritty)
- Most CLI tools and utilities
- Programming language versions
- Development workflow

### What's Different
- Package manager (Homebrew instead of apt)
- Docker runtime (Colima instead of docker-ce)
- Font directory location
- No system-wide environment variable edits
- No update-alternatives for editor selection

## Platform Detection in Roles

All roles use `ansible_os_family` for platform detection:

```yaml
when: ansible_os_family == "Darwin"  # macOS
when: ansible_os_family == "Debian"  # Linux
```

Variables in `vars.yml` help with cross-platform support:
- `is_macos`: Boolean for macOS detection
- `is_linux`: Boolean for Linux detection
- `arch_map`: Architecture mapping (x86_64 → amd64, arm64 → arm64)
- `font_dir`: Platform-specific font directory

## Contributing

If you find issues with macOS support:
1. Check this document first
2. Review role-specific tasks in `roles/*/tasks/main.yml`
3. Check platform conditionals
4. Open an issue or submit a PR

## Future Improvements

Potential enhancements for macOS support:
- [ ] Optional Docker Desktop installation (instead of Colima)
- [ ] macOS-specific tool installations (e.g., iTerm2)
- [ ] Homebrew bundle file support
- [ ] macOS system preferences automation
- [ ] Better font management (Font Book integration)

## References

- [Homebrew Documentation](https://docs.brew.sh/)
- [Colima GitHub](https://github.com/abiosoft/colima)
- [Ansible macOS Guide](https://docs.ansible.com/ansible/latest/os_guide/intro_macos.html)
