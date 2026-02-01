# Prompt: Review and Fix zsh Configuration for macOS Compatibility

## Context
This is a personal zsh configuration repository used on both Linux (Pop!_OS/Ubuntu) and macOS (Intel and Apple Silicon). The configuration uses oh-my-zsh and needs to work seamlessly on all platforms.

## Current Issues Identified

1. **PATH Configuration** - Missing macOS Homebrew paths
   - Line 5: Only adds `$HOME/.local/bin` to PATH
   - macOS needs Homebrew bin directories:
     - Apple Silicon: `/opt/homebrew/bin`
     - Intel Mac: `/usr/local/bin`
   - Linux is fine as-is

2. **Go Environment Variables** (Lines 40-44)
   - Hardcoded to `/usr/local/go`
   - Should detect platform and adjust accordingly
   - macOS Homebrew installs Go to different locations

3. **virtualenvwrapper Plugin**
   - Currently assumes `virtualenvwrapper.sh` is in PATH
   - May need platform-specific sourcing

## Tasks

### 1. Add Platform Detection
Add robust platform detection at the beginning of `.zshrc` that:
- Detects if running on macOS vs Linux
- Detects if macOS is Apple Silicon (arm64) vs Intel (x86_64)
- Sets up appropriate environment variables

### 2. Fix PATH Configuration
Update PATH setup to:
- On macOS: Properly initialize Homebrew environment using `brew shellenv`
- On Linux: Keep current behavior
- Ensure `$HOME/.local/bin` is still in PATH on all platforms
- Maintain correct PATH priority (Homebrew before system, local before Homebrew)

### 3. Make Go Paths Flexible
Update Go configuration block to:
- Detect where Go is actually installed
- Support both `/usr/local/go` (Linux) and Homebrew Go locations
- Only export GOROOT/GOPATH if Go is actually installed
- Consider using `go env GOPATH` to detect GOPATH

### 4. Review Plugin Compatibility
Check if all oh-my-zsh plugins work on macOS:
- git ✓
- docker ✓
- docker-compose ✓
- golang ✓
- npm ✓
- pip ✓
- python ✓
- virtualenvwrapper - Verify this works on macOS

### 5. Additional Improvements
Consider adding:
- Conditional loading of platform-specific aliases
- macOS-specific settings (e.g., iTerm2 integration if available)
- Better error handling if commands/paths don't exist

## Expected Output

Please provide:
1. **Updated .zshrc file** with all fixes applied
2. **Explanation** of what changed and why
3. **Platform-specific sections** clearly marked with comments
4. **Testing recommendations** - what to test on each platform

## Requirements

- Must work on Linux (Pop!_OS/Ubuntu) without breaking existing functionality
- Must work on macOS (both Intel and Apple Silicon)
- Should be idempotent (safe to source multiple times)
- Should fail gracefully if tools are not installed
- Keep the existing oh-my-zsh theme and plugins
- Maintain existing aliases and editor settings

## Example Pattern to Follow

```bash
# Platform detection
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS-specific configuration
  if [[ $(uname -m) == "arm64" ]]; then
    # Apple Silicon specific
  else
    # Intel Mac specific
  fi
else
  # Linux-specific configuration
fi
```

---

**Note:** This configuration is managed via Ansible from the workmachine repository, which clones this repo to `~/.config/zsh/` and symlinks to `~/.zshrc`. Keep this in mind when testing.
