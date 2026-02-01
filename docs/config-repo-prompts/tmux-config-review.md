# Prompt: Review tmux Configuration for Cross-Platform Compatibility

## Context
This is a personal tmux configuration repository used on both Linux (Pop!_OS/Ubuntu) and macOS (Intel and Apple Silicon). The configuration uses the Catppuccin theme.

## Current Configuration

**File**: `~/.config/tmux/tmux.conf`

Current settings include:
- Window numbering starting at 1
- Mouse support enabled
- Status bar at top
- Catppuccin Frappe theme
- OSC 52 clipboard support (for SSH copy/paste)

## Task

### 1. Cross-Platform Compatibility Check

Review the tmux configuration for platform-specific issues:

**Check for:**
- Clipboard configuration differences (Linux vs macOS)
- Terminal type settings (Linux vs macOS terminals)
- Plugin compatibility across platforms
- Path references that might be platform-specific
- Key binding compatibility (especially with Alacritty)

### 2. Clipboard Configuration

Verify OSC 52 clipboard works correctly:
- **Linux**: Works with X11, Wayland, and over SSH
- **macOS**: Works with pbcopy/pbpaste and over SSH
- Current setting: `set -g set-clipboard on`

Check if additional configuration is needed for:
- Native clipboard integration
- Copy mode key bindings
- Paste behavior differences

### 3. Plugin Check

**Current plugins:**
- Catppuccin theme (loaded from `~/.config/tmux/plugins/catppuccin/`)

Verify:
- Plugin loading mechanism works on both platforms
- Plugin paths are correct (uses `~/.config/tmux/` - XDG compliant)
- No hardcoded Linux paths in plugin configuration
- Theme renders correctly on both platforms

### 4. Terminal Integration

Check integration with:
- **Alacritty** (primary terminal on both platforms)
- **Terminal type**: Currently sets to default
- **256 color support**: Should work on both
- **True color support**: Verify if needed

### 5. macOS-Specific Considerations

Check if these macOS quirks need addressing:
- Does `pbcopy`/`pbpaste` integration work correctly?
- Are there any differences in tmux behavior on macOS vs Linux?
- Does reattach-to-user-namespace need to be used (older macOS versions)?
- Do special key combinations work (Option key, etc.)?

### 6. Best Practices Review

Review configuration for:
- Tmux 3.x features vs older versions
- Performance optimizations
- Useful key bindings that might be missing
- Session/window management improvements

## Expected Output

Please provide:

### 1. Compatibility Report

```markdown
# tmux Configuration Platform Compatibility Report

## Summary
[Overall compatibility status]

## Compatibility Analysis

### ✅ Works Cross-Platform
- [List features that work on both]

### ⚠️ Potential Issues
- [List items that might need attention]

### 💡 Recommendations
- [Suggested improvements]

## Platform-Specific Notes

### Linux
- [Linux-specific notes]

### macOS
- [macOS-specific notes]
```

### 2. Updated Configuration (if changes needed)

Provide an updated `tmux.conf` with:
- Platform detection (if needed)
- Fixed/improved clipboard handling
- Any other recommended changes
- Clear comments explaining changes

### 3. Testing Checklist

```markdown
## Testing Checklist

### Basic Functionality
- [ ] tmux starts without errors
- [ ] Mouse support works
- [ ] Status bar displays correctly
- [ ] Catppuccin theme loads and renders properly
- [ ] Window creation/switching works

### Clipboard Testing
- [ ] Copy text in tmux (visual selection + y)
- [ ] Paste within tmux (prefix + ])
- [ ] Copy from tmux to system clipboard
- [ ] Paste from system clipboard to tmux
- [ ] OSC 52 works over SSH

### Integration Testing  
- [ ] Works correctly in Alacritty
- [ ] Neovim renders properly inside tmux
- [ ] Colors display correctly (256 color / true color)
- [ ] Special characters and glyphs render (Nerd Fonts)

### Platform-Specific
- [ ] [Linux-specific tests]
- [ ] [macOS-specific tests]
```

### 4. Additional Recommendations

Suggest any improvements for:
- Better key bindings
- Useful plugins
- Performance optimizations
- Quality of life improvements

## Specific Areas to Investigate

### 1. Clipboard Configuration

Current: `set -g set-clipboard on`

Questions:
- Is this sufficient for both platforms?
- Should we add explicit copy-mode key bindings?
- Does OSC 52 work correctly in Alacritty on both platforms?
- Any additional clipboard configuration needed?

### 2. Terminal Type

Questions:
- Should we explicitly set terminal type?
- Is `tmux-256color` needed/recommended?
- Any terminfo issues on macOS?

Example to consider:
```tmux
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",*256col*:Tc"
```

### 3. Key Bindings

Current: Using defaults (mostly)

Questions:
- Are default tmux key bindings comfortable?
- Any conflicts with Alacritty key bindings?
- macOS Option key handling okay?
- Should we add custom bindings for common operations?

### 4. Plugin Management

Current: Manual plugin in `~/.config/tmux/plugins/`

Questions:
- Should we use tpm (tmux plugin manager)?
- Current approach working well?
- Plugin update mechanism?

## Requirements

- Must work on Linux (Pop!_OS/Ubuntu)
- Must work on macOS (Intel and Apple Silicon)  
- Must work well with Alacritty terminal
- Must work well with Neovim inside tmux
- Should preserve current theme and functionality
- Should improve upon current config if possible

## Context from Setup

**Environment:**
- **Terminal**: Alacritty with JetBrainsMono Nerd Font
- **Shell**: zsh with oh-my-zsh (agnoster theme)
- **Editor**: Neovim with LazyVim
- **tmux version**: Latest from package manager (3.x)

**User workflow:**
- Uses tmux for terminal multiplexing
- Runs Neovim inside tmux
- Uses mouse for tmux interactions
- Needs clipboard to work for copy/paste
- Sometimes works over SSH

## Example Platform Detection (if needed)

If platform-specific configuration is needed:

```tmux
# Platform detection
run-shell "tmux setenv -g TMUX_PLATFORM $(uname -s)"

# macOS-specific settings
if-shell "[ $TMUX_PLATFORM = Darwin ]" \
  "set -g ... mac-specific ..."

# Linux-specific settings  
if-shell "[ $TMUX_PLATFORM = Linux ]" \
  "set -g ... linux-specific ..."
```

---

**Note:** The tmux configuration is managed via Ansible from the workmachine repository, which clones this repo to `~/.config/tmux/`. Modern tmux (3.1+) supports XDG-compliant config locations, so it automatically loads from `~/.config/tmux/tmux.conf`.

**Priority:** Focus on ensuring clipboard works correctly on both platforms, as that's often the main pain point. Everything else seems solid already.
