#!/usr/bin/env bash
set -euo pipefail

echo "=== Alacritty Nerd Font Test ==="
echo ""

check_font() {
    local font_name="$1"
    if fc-list 2>/dev/null | grep -qi "$font_name"; then
        echo "[OK] $font_name"
        return 0
    elif [[ "$OSTYPE" == "darwin"* ]] && ls ~/Library/Fonts/NerdFonts/ 2>/dev/null | grep -qi "${font_name// /}"; then
        echo "[OK] $font_name (macOS)"
        return 0
    else
        echo "[MISSING] $font_name"
        return 1
    fi
}

echo "Checking installed Nerd Fonts..."
echo ""
check_font "JetBrainsMono Nerd Font" || true
check_font "FiraCode Nerd Font" || true
check_font "MesloLGS Nerd Font" || true

echo ""
echo "=== Glyph Rendering Test ==="
echo "If Nerd Fonts are working, you should see icons below:"
echo ""
echo "Powerline arrows:      "
echo "Dev icons:             "
echo "Git symbols:           "
echo "Folder icons:          "
echo "File type icons:       "
echo ""
echo "=== Powerline Prompt Test ==="
echo "These should render as solid arrows:"
echo ""
echo "normal mode    insert mode    visual mode "
echo ""

if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font"; then
    echo "Primary font (JetBrainsMono Nerd Font) is installed."
else
    echo "WARNING: JetBrainsMono Nerd Font not found!"
    echo "Install via workmachine Ansible or manually from:"
    echo "https://github.com/ryanoasis/nerd-fonts/releases"
fi
