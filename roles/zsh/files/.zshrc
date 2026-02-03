# ==============================================================================
# Platform Detection
# ==============================================================================

# Detect OS type
case "$OSTYPE" in
  darwin*)
    _IS_MACOS=true
    _IS_LINUX=false
    # Detect architecture
    if [[ "$(uname -m)" == "arm64" ]]; then
      _IS_APPLE_SILICON=true
      _HOMEBREW_PREFIX="/opt/homebrew"
    else
      _IS_APPLE_SILICON=false
      _HOMEBREW_PREFIX="/usr/local"
    fi
    ;;
  linux*)
    _IS_MACOS=false
    _IS_LINUX=true
    _IS_APPLE_SILICON=false
    _HOMEBREW_PREFIX=""
    ;;
  *)
    _IS_MACOS=false
    _IS_LINUX=false
    _IS_APPLE_SILICON=false
    _HOMEBREW_PREFIX=""
    ;;
esac

# ==============================================================================
# PATH Configuration
# ==============================================================================

# Initialize Homebrew if on macOS (must be done early for brew commands to work)
if [[ "$_IS_MACOS" == true ]] && [[ -x "${_HOMEBREW_PREFIX}/bin/brew" ]]; then
  eval "$(${_HOMEBREW_PREFIX}/bin/brew shellenv)"
fi

# Add local bin to PATH (highest priority - user scripts override everything)
export PATH="$HOME/.local/bin:$PATH"

# ==============================================================================
# Oh My Zsh Configuration
# ==============================================================================

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme - https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"

# Plugins - https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins
# Note: virtualenvwrapper plugin requires virtualenvwrapper to be installed
plugins=(
    git
    docker
    docker-compose
    golang
    npm
    pip
    python
)

# Only load virtualenvwrapper plugin if virtualenvwrapper is available
if command -v virtualenvwrapper.sh &> /dev/null || \
   [[ -f "$HOME/.local/bin/virtualenvwrapper.sh" ]] || \
   [[ "$_IS_MACOS" == true && -f "${_HOMEBREW_PREFIX}/bin/virtualenvwrapper.sh" ]]; then
  plugins+=(virtualenvwrapper)
fi

source $ZSH/oh-my-zsh.sh

# ==============================================================================
# Shell Settings
# ==============================================================================

# Hide username@hostname when it's your own user (for agnoster theme)
DEFAULT_USER="$USER"

# 256 color support
export TERM="xterm-256color"

# Default editor (use nvim if available, fall back to vim)
if command -v nvim &> /dev/null; then
  export EDITOR="nvim"
  export VISUAL="nvim"
elif command -v vim &> /dev/null; then
  export EDITOR="vim"
  export VISUAL="vim"
fi

# ==============================================================================
# Go Configuration
# ==============================================================================

# Detect and configure Go installation
_setup_go() {
  local go_bin=""
  local go_root=""

  # Find Go binary
  if command -v go &> /dev/null; then
    go_bin="$(command -v go)"
  elif [[ -x "/usr/local/go/bin/go" ]]; then
    go_bin="/usr/local/go/bin/go"
  elif [[ "$_IS_MACOS" == true && -x "${_HOMEBREW_PREFIX}/bin/go" ]]; then
    go_bin="${_HOMEBREW_PREFIX}/bin/go"
  fi

  # If Go is found, set up environment
  if [[ -n "$go_bin" ]]; then
    # Get GOROOT from Go itself if possible
    if [[ -x "$go_bin" ]]; then
      go_root="$("$go_bin" env GOROOT 2>/dev/null)"
    fi

    # Fallback GOROOT detection
    if [[ -z "$go_root" ]]; then
      if [[ -d "/usr/local/go" ]]; then
        go_root="/usr/local/go"
      elif [[ "$_IS_MACOS" == true && -d "${_HOMEBREW_PREFIX}/opt/go/libexec" ]]; then
        go_root="${_HOMEBREW_PREFIX}/opt/go/libexec"
      fi
    fi

    # Export GOROOT if we found it
    if [[ -n "$go_root" && -d "$go_root" ]]; then
      export GOROOT="$go_root"
    fi

    # Set GOPATH (default to ~/go)
    export GOPATH="${GOPATH:-$HOME/go}"

    # Add Go binaries to PATH if not already present
    [[ -d "$GOROOT/bin" ]] && [[ ":$PATH:" != *":$GOROOT/bin:"* ]] && export PATH="$PATH:$GOROOT/bin"
    [[ -d "$GOPATH/bin" ]] && [[ ":$PATH:" != *":$GOPATH/bin:"* ]] && export PATH="$PATH:$GOPATH/bin"
  fi
}

_setup_go
unset -f _setup_go

# ==============================================================================
# Aliases
# ==============================================================================

# Editor aliases (only if nvim is available)
if command -v nvim &> /dev/null; then
  alias vi='nvim'
  alias vim='nvim'
fi

# Platform-specific aliases
if [[ "$_IS_MACOS" == true ]]; then
  # macOS-specific aliases
  alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
  
  # Use GNU coreutils if installed via Homebrew (for consistent behavior)
  if command -v gls &> /dev/null; then
    alias ls='gls --color=auto'
    alias ll='gls -lah --color=auto'
  fi
else
  # Linux-specific aliases
  alias ll='ls -lah --color=auto'
fi

# Common aliases (cross-platform)
# alias gs='git status'

# ==============================================================================
# Platform-Specific Settings
# ==============================================================================

if [[ "$_IS_MACOS" == true ]]; then
  # iTerm2 shell integration (if available)
  if [[ -e "${HOME}/.iterm2_shell_integration.zsh" ]]; then
    source "${HOME}/.iterm2_shell_integration.zsh"
  fi
  
  # Fix for macOS Catalina+ zsh compinit warning
  export ZSH_DISABLE_COMPFIX=true
fi

# ==============================================================================
# Cleanup
# ==============================================================================

# Unset platform detection variables (they served their purpose)
# Comment out if you need these variables in your shell session
# unset _IS_MACOS _IS_LINUX _IS_APPLE_SILICON _HOMEBREW_PREFIX
# BEGIN ANSIBLE MANAGED BLOCK - Go
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
# END ANSIBLE MANAGED BLOCK - Go
# BEGIN ANSIBLE MANAGED BLOCK - nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
# END ANSIBLE MANAGED BLOCK - nvm
export PATH="$HOME/.bun/bin:$PATH"
