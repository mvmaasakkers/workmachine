# Configuration Repository Review Prompts

This directory contains detailed prompts for reviewing your personal configuration repositories for cross-platform compatibility (Linux + macOS).

## Overview

The workmachine Ansible repository manages installation of tools and clones your configuration repositories. However, the **actual configuration files** in those repos may need adjustments for macOS compatibility.

These prompts help you systematically review each config repo using AI assistance (OpenCode, Claude, etc.).

## Configuration Repositories

Your dotfiles are split across these repositories:

| Repository | Purpose | Workmachine Clones To | Status |
|------------|---------|----------------------|---------|
| `mvmaasakkers/zsh` | zsh shell config | `~/.config/zsh/` → `~/.zshrc` | ⚠️ Needs review |
| `mvmaasakkers/alacritty` | Alacritty terminal config | `~/.config/alacritty/` | ⚠️ Needs review |
| `mvmaasakkers/nvim` | Neovim editor config | `~/.config/nvim/` | ✅ Likely OK |
| `mvmaasakkers/tmux` | tmux multiplexer config | `~/.config/tmux/` | ✅ Likely OK |

## How to Use These Prompts

### Option 1: Using OpenCode (Recommended)

1. **Open the config repository** you want to review:
   ```bash
   cd ~/.config/zsh  # or nvim, tmux, alacritty
   ```

2. **Start OpenCode** in that directory:
   ```bash
   opencode
   ```

3. **Copy the entire prompt** from the relevant `.md` file in this directory

4. **Paste into OpenCode** and let it analyze

5. **Review the suggestions** and apply fixes

6. **Commit changes** to your config repository:
   ```bash
   git add .
   git commit -m "feat: add macOS compatibility"
   git push
   ```

### Option 2: Using Claude Code CLI

```bash
cd ~/.config/zsh
cat /path/to/workmachine/docs/config-repo-prompts/zsh-config-review.md | claude --
```

### Option 3: Copy-Paste to Web Interface

Copy the prompt content and paste into:
- Claude.ai web interface
- ChatGPT
- Or any other AI assistant

## Prompt Files

### [`zsh-config-review.md`](./zsh-config-review.md)
**Priority:** ⚠️ HIGH - Needs fixes

**Issues:**
- PATH doesn't include Homebrew (macOS)
- Hardcoded Go paths
- Platform detection missing

**Estimated Time:** 15-20 minutes

---

### [`alacritty-config-review.md`](./alacritty-config-review.md)
**Priority:** ⚠️ MEDIUM - Needs adjustments

**Issues:**
- Font family missing "Nerd Font" suffix
- Font size too small for macOS Retina displays
- Could use more configuration

**Estimated Time:** 10-15 minutes

---

### [`nvim-config-review.md`](./nvim-config-review.md)
**Priority:** ✅ LOW - Likely works already

**Why:**
- LazyVim is cross-platform by default
- No obvious platform-specific issues
- Just verification needed

**Estimated Time:** 5-10 minutes (quick check)

---

### [`tmux-config-review.md`](./tmux-config-review.md)
**Priority:** ✅ LOW - Likely works already

**Why:**
- Pure tmux config (no platform-specific paths)
- Uses XDG-compliant paths
- Clipboard might need testing

**Estimated Time:** 5-10 minutes (verification + clipboard testing)

## Recommended Order

1. **Start with zsh** - This affects your entire shell environment
2. **Then alacritty** - Quick win, improves terminal appearance  
3. **Then nvim** - Verify it works, likely no changes needed
4. **Finally tmux** - Just verify clipboard works

## After Fixing Config Repos

Once you've updated your configuration repositories:

1. **Test locally** (if on Linux now):
   ```bash
   source ~/.zshrc  # Test zsh changes
   alacritty        # Test alacritty changes (if installed)
   ```

2. **Re-run workmachine** to pull updated configs:
   ```bash
   cd ~/Projects/personal/workmachine
   make setup-local  # or setup for remote
   ```

3. **When you get macOS access**, the configs will already be ready!

## What Workmachine Ansible Handles

The workmachine repository (this repo) handles:
- ✅ Installing software (zsh, nvim, tmux, alacritty, etc.)
- ✅ Installing Nerd Fonts
- ✅ Cloning your config repositories
- ✅ Creating symlinks (e.g., `~/.zshrc` → `~/.config/zsh/.zshrc`)
- ✅ Installing oh-my-zsh
- ✅ Setting up package managers (Homebrew on macOS)

## What You Need to Handle in Config Repos

Your configuration repositories need to:
- ⚠️ Detect which platform they're running on
- ⚠️ Use appropriate paths for each platform
- ⚠️ Load platform-specific tools correctly
- ⚠️ Handle missing dependencies gracefully

## Testing Strategy

### If You Only Have Linux Now

You can still:
1. ✅ Make the config changes based on AI review
2. ✅ Add platform detection code
3. ✅ Test that Linux still works
4. ✅ Commit and push changes
5. ⏳ Wait until you have macOS access to test
6. ✅ The configs will already be macOS-ready

### If You Have Both Platforms

Test each change on both:
```bash
# On Linux
cd ~/.config/zsh && git pull
source ~/.zshrc
# Test everything works

# On macOS  
cd ~/.config/zsh && git pull
source ~/.zshrc
# Test everything works
```

## Quick Reference: Platform Detection Patterns

### In Shell Scripts (zsh, bash)
```bash
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  if [[ $(uname -m) == "arm64" ]]; then
    # Apple Silicon
  else
    # Intel Mac
  fi
else
  # Linux
fi
```

### In Lua (Neovim)
```lua
local is_mac = vim.fn.has("macunix") == 1
local is_linux = vim.fn.has("unix") == 1 and not is_mac

if is_mac then
  -- macOS config
else
  -- Linux config
end
```

### In tmux
```tmux
run-shell "tmux setenv -g TMUX_PLATFORM $(uname -s)"

if-shell "[ $TMUX_PLATFORM = Darwin ]" \
  "set -g ... macOS ..."
  
if-shell "[ $TMUX_PLATFORM = Linux ]" \
  "set -g ... Linux ..."
```

## Need Help?

If you get stuck or want me to review the changes:
1. Make your changes in the config repo
2. Come back to workmachine repository
3. Ask me to review the changes you made

## Summary

**Your Action Items:**
1. ✅ Use these prompts with OpenCode/Claude to review each config repo
2. ✅ Apply the suggested fixes
3. ✅ Test on Linux (if possible)  
4. ✅ Commit and push changes
5. ⏳ Test on macOS when available

**My Responsibility:**
- ✅ Finish implementing macOS support in workmachine Ansible roles
- ✅ Ensure tools are installed correctly on both platforms
- ✅ Document everything

---

**Questions?** Just ask! These prompts are designed to be thorough but you can always skip optional improvements and just focus on the critical fixes.
