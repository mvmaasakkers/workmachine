# Prompt: Review Neovim Configuration for Cross-Platform Compatibility

## Context
This is a personal Neovim configuration repository using LazyVim, used on both Linux (Pop!_OS/Ubuntu) and macOS (Intel and Apple Silicon).

## Current Setup
- **Base**: LazyVim starter configuration
- **Package Manager**: lazy.nvim
- **Entry Point**: `init.lua` which requires `config.lazy`
- **Structure**: 
  - `lua/config/` - LazyVim configuration
  - `lua/plugins/` - Custom plugins

## Task

### 1. Platform Compatibility Check
Review the entire Neovim configuration for cross-platform issues:

**Check for:**
- Hardcoded Linux paths (e.g., `/usr/bin/`, `/home/`, etc.)
- Platform-specific plugin dependencies
- External tools that might not exist on macOS
- LSP/treesitter configurations that need platform-specific setup
- Clipboard configurations (Linux uses xclip/xsel, macOS uses pbcopy)
- Terminal-specific settings

### 2. Plugin Compatibility
Review all plugins in `lua/plugins/` for:
- macOS compatibility
- Required external dependencies (binaries, libraries)
- Whether dependencies are installed by workmachine Ansible
- Alternative plugins if any are Linux-only

### 3. LSP/Treesitter Configuration  
Check Language Server and Treesitter setup:
- Are all LSP servers available on macOS?
- Are there platform-specific installation paths?
- Do all treesitter parsers compile on macOS?
- Are there any gcc/compiler dependencies?

### 4. Clipboard Integration
Verify clipboard configuration works on both:
- **Linux**: X11 clipboard (xclip/xsel/wl-clipboard)
- **macOS**: pbcopy/pbpaste

LazyVim should handle this automatically, but verify.

### 5. File/Path Handling
Check for:
- Hardcoded paths that won't work cross-platform
- File separator issues (/ vs \)
- Home directory references (`~` should work on both)

### 6. External Dependencies
List all external tools the config depends on:
- CLI tools (ripgrep, fd, etc.) 
- Language servers
- Formatters
- Linters
- Debug adapters

Verify these are installed by workmachine Ansible or document what's missing.

## Expected Output

Please provide:

### 1. Compatibility Report
A markdown report with:
- **✅ Works on both platforms** - List what's already good
- **⚠️ Needs adjustment** - Issues that need fixing
- **❌ Linux-only** - Features that won't work on macOS
- **💡 Recommendations** - Suggested improvements

### 2. Required Changes (if any)
- Specific file changes needed
- Platform-detection code snippets
- Updated plugin configurations

### 3. Missing Dependencies
A list of tools/binaries that:
- Are required by your config
- Should be installed by workmachine Ansible
- Are platform-specific

### 4. Testing Checklist
Commands to test critical functionality on each platform.

## Things to Specifically Check

### LazyVim Defaults
LazyVim is generally cross-platform, but check:
- Default key bindings work on macOS
- Terminal integration works (Alacritty on both platforms)
- File explorer (neo-tree) works correctly
- Fuzzy finder (Telescope) finds files properly

### Custom Plugins
Review each plugin in `lua/plugins/` for:
```
- Installation method (mason, lazy, external)
- External binary dependencies  
- OS-specific configuration
- Alternative plugins if needed
```

### Language Support
For each language you use (based on workmachine: Go, Node.js, Python, PHP):
- LSP server availability on macOS
- Formatter/linter availability
- Debug adapter availability

## Expected Structure of Response

```markdown
# Neovim Configuration Platform Compatibility Report

## Summary
[Brief overview of compatibility status]

## Compatibility Analysis

### ✅ Works Cross-Platform
- LazyVim base configuration
- [list other items...]

### ⚠️ Needs Adjustment  
- [Item 1: Description of issue and fix needed]
- [Item 2: Description of issue and fix needed]

### ❌ Platform-Specific Issues
- [Linux-only features, if any]
- [macOS-only features, if any]

## Required Changes

### File: lua/config/xxx.lua
[Code changes needed]

### File: lua/plugins/xxx.lua  
[Code changes needed]

## External Dependencies

### Required by Config
| Tool | Purpose | Linux Install | macOS Install | In Workmachine? |
|------|---------|---------------|---------------|-----------------|
| ripgrep | Telescope | apt | brew | ✅ Yes |
| ... | ... | ... | ... | ... |

### Missing from Workmachine
[List any tools that should be added to workmachine Ansible]

## Testing Checklist

### On Linux
- [ ] Test item 1
- [ ] Test item 2

### On macOS  
- [ ] Test item 1
- [ ] Test item 2

## Recommendations
[Any additional suggestions for improvement]
```

## Requirements

- Focus on practical compatibility issues
- Prioritize issues that break functionality
- Suggest minimal changes (don't over-engineer)
- Keep LazyVim defaults unless there's a good reason to change
- Document WHY changes are needed, not just WHAT to change

## Context from Workmachine

The workmachine Ansible setup installs:
- **Editors**: Neovim (latest from PPA on Linux, Homebrew on macOS)
- **Languages**: Go 1.25.6, Node.js 24, Python 3.13, PHP 8.4
- **Tools**: git, curl, wget, ripgrep, fd, fzf, tmux, btop, lazygit
- **Shells**: zsh with oh-my-zsh
- **Fonts**: Nerd Fonts (Meslo, FiraCode, JetBrainsMono)

Assume these are available on both platforms.

---

**Note:** This configuration is managed via Ansible from the workmachine repository, which clones this repo to `~/.config/nvim/`. LazyVim should handle most cross-platform concerns automatically, so this review is mainly to catch edge cases and custom configurations.
