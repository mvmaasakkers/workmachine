# Prompt: Review and Fix Alacritty Configuration for Cross-Platform Use

## Context
This is a personal Alacritty terminal emulator configuration repository used on both Linux (Pop!_OS/Ubuntu) and macOS (Intel and Apple Silicon). The workmachine Ansible setup installs Nerd Fonts (Meslo, FiraCode, JetBrainsMono) on both platforms.

## Current Configuration
```yaml
font:
  size: 10.0
  normal:
    family: "JetBrains Mono"
    style: "Regular"
```

## Issues Identified

1. **Font Family - Missing Nerd Font Variant**
   - Currently: `"JetBrains Mono"`
   - Problem: Won't include powerline glyphs and icons
   - Solution: Should use `"JetBrainsMono Nerd Font"` (note: no space in "JetBrainsMono")

2. **Font Size - Too Small for macOS**
   - Currently: `10.0`
   - Problem: Retina displays on macOS need larger sizes
   - Solution: Consider 12.0-14.0 for macOS, or make it platform-specific

3. **Missing Configuration Options**
   - No window configuration
   - No color scheme defined
   - No platform-specific optimizations
   - No key bindings customization

## Available Nerd Fonts

The workmachine Ansible setup installs these Nerd Fonts to the system:
- **MesloLGS Nerd Font** - Variant of Menlo with powerline glyphs
- **FiraCode Nerd Font** - Popular font with ligatures  
- **JetBrainsMono Nerd Font** - Developer-focused font (current choice)

On Linux: Installed to `~/.local/share/fonts/NerdFonts/`
On macOS: Installed to `~/Library/Fonts/NerdFonts/`

## Tasks

### 1. Fix Font Configuration
Update font family to use proper Nerd Font variant:
- Use `"JetBrainsMono Nerd Font"` for proper glyph support
- Verify font name is correct for both platforms
- Consider adding bold, italic variants

### 2. Add Platform-Specific Font Sizes
Consider one of these approaches:

**Option A: Single size that works well on both**
```yaml
font:
  size: 12.0  # Works well on macOS Retina and Linux
```

**Option B: Platform-specific (requires Alacritty import feature)**
Create separate files:
- `alacritty-linux.toml` with size 10-11
- `alacritty-macos.toml` with size 12-14
- Main config imports the appropriate one

### 3. Add Essential Configuration
Include these recommended settings:
- **Window padding** for better aesthetics
- **Window opacity** (if desired)
- **Cursor style** configuration
- **Color scheme** (consider matching with zsh theme - you use agnoster)
- **Key bindings** for common operations

### 4. Platform-Specific Optimizations
Consider adding platform-specific settings:
- **macOS**: 
  - Use `option_as_alt: Both` for proper alt key behavior
  - Window decorations preferences
  - Native fullscreen behavior
- **Linux**:
  - X11/Wayland specific settings if needed

### 5. Test Font Rendering
Ensure Nerd Font icons render correctly:
```
# Test glyphs - should show icons:
         
# Test powerline:
  
```

## Expected Output

Please provide:

1. **Updated Configuration File(s)**
   - Modern Alacritty config (TOML or YAML format - you choose most appropriate)
   - All recommended settings
   - Clear comments explaining sections

2. **Font Testing Script**
   - Simple shell script to verify fonts are installed
   - Test Nerd Font glyph rendering

3. **Documentation**
   - Explanation of changes made
   - How to customize for personal preferences
   - Platform-specific notes

## Requirements

- Must work on Linux (Pop!_OS/Ubuntu) 
- Must work on macOS (both Intel and Apple Silicon)
- Must use Nerd Fonts for proper icon/glyph support
- Should have sensible defaults for both platforms
- Follow Alacritty best practices and current config format
- Be well-commented for future reference

## Recommended Configuration Structure

```yaml
# Alacritty Configuration
# Managed by: workmachine Ansible repository

# Import platform-specific overrides (if using separate files)
# import: [ "~/.config/alacritty/platform.yml" ]

# Font configuration
font:
  size: 12.0
  normal:
    family: "JetBrainsMono Nerd Font"
    style: Regular
  bold:
    family: "JetBrainsMono Nerd Font"
    style: Bold
  italic:
    family: "JetBrainsMono Nerd Font"
    style: Italic

# Window configuration
window:
  padding:
    x: 10
    y: 10
  opacity: 1.0

# Colors (consider Catppuccin Frappe to match tmux theme)
colors:
  # ... color scheme ...

# Platform-specific settings (if needed)
```

## Additional Context

- The Alacritty config is managed via Ansible from the workmachine repository
- Config is cloned to `~/.config/alacritty/`
- You also use tmux with Catppuccin Frappe theme - consider matching colors
- You use agnoster zsh theme which requires powerline fonts

## Testing Checklist

After making changes, verify:
- [ ] Nerd Font icons display correctly
- [ ] Font size is readable on both platforms
- [ ] Colors look good in both light and dark environments
- [ ] No errors when starting Alacritty
- [ ] Works well with tmux + nvim inside
- [ ] Powerline symbols in zsh prompt display correctly

---

**Note:** If you want to keep it simple, just fix the font family to use Nerd Font variant and adjust size to 12.0. Everything else is optional enhancements.
