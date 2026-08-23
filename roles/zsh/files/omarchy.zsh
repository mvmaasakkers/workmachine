# ==============================================================================
# Omarchy integration (Arch Linux + Hyprland)
# ==============================================================================
# Sourced at the end of .zshrc on machines where /usr/share/omarchy exists.
# Layers Omarchy's shell environment on top of the workmachine zsh setup:
# the POSIX/zsh-compatible parts of /usr/share/omarchy/default/bash/* are
# sourced verbatim (so they stay in sync with Omarchy updates), and the
# bash-only parts (shell, init, inputrc, completions) get zsh equivalents,
# plus zsh ports of the few functions with bashisms (tsl, hsl, ssh wrapper).
#
# Never edit anything under /usr/share/omarchy — it is package-owned.

[[ -d /usr/share/omarchy ]] || return 0

# ==============================================================================
# Environment (pure POSIX — sourced verbatim)
# ==============================================================================

# OMARCHY_PATH + PATH (mise shims, ~/.local/bin)
source /usr/share/omarchy/default/bash/env-bootstrap

# EDITOR/SUDO_EDITOR, BROWSER, BAT_THEME, bat-colored man pages, locale
# fallback. EDITOR is only set here if it is still empty — .zshrc skips its
# own EDITOR export on Omarchy so omarchy-launch-editor wins.
source "$OMARCHY_PATH/default/bash/envs"

# ==============================================================================
# zsh equivalent of default/bash/shell
# ==============================================================================

# Match bash's histappend + ignoreboth + HISTSIZE=32768
setopt inc_append_history hist_ignore_dups hist_ignore_space
HISTSIZE=32768
SAVEHIST=$HISTSIZE
# bash-completion and `set +h` (for mise) have no zsh counterpart: compinit is
# handled by oh-my-zsh, and zsh re-searches PATH on a hash miss by itself.

# ==============================================================================
# Aliases (written zsh-compatible upstream — sourced verbatim)
# ==============================================================================

# eza ls/lsa/lt/lta, ff/eff/sff, cd→zd (zoxide), open(), ..-aliases, tool and
# git shortcuts. The zd and open functions run unmodified in zsh.
source "$OMARCHY_PATH/default/bash/aliases"

# ==============================================================================
# Functions (default/bash/fns/*)
# ==============================================================================

# Everything in fns/ runs unmodified in zsh except:
#  - ssh-reconnect: declares `local argv`, which is a reserved special in zsh
#  - tsl (fns/tmux) and hsl (fns/herdr): 0-based array indexing, zsh is 1-based
# ssh-reconnect is skipped (ported below); tsl/hsl are overridden below.
#
# Parsed with alias expansion off: fns/worktrees defines ga() and gd(), and
# zsh refuses to define a function whose name is an existing alias (the
# oh-my-zsh git plugin aliases both).
setopt no_aliases
for _omarchy_fn in "$OMARCHY_PATH"/default/bash/fns/*; do
  [[ "${_omarchy_fn:t}" == "ssh-reconnect" ]] && continue
  source "$_omarchy_fn"
done
setopt aliases
unset _omarchy_fn

# Aliases take precedence over functions in zsh, so drop the oh-my-zsh git
# plugin's ga/gd aliases in favor of Omarchy's worktree functions.
unalias ga gd 2>/dev/null

# --- zsh port of tsl (fns/tmux) -----------------------------------------------
# Identical to upstream except ${panes[0]} → ${panes[1]} (zsh arrays are 1-based).

# Create a multi-pane swarm layout with the same command started in each pane (great for AI)
# Usage: tsl <pane_count> <command>
tsl() {
  [[ -z $1 || -z $2 ]] && { echo "Usage: tsl <pane_count> <command>"; return 1; }
  [[ -z $TMUX ]] && { echo "You must start tmux to use tsl."; return 1; }

  local count="$1"
  local cmd="$2"
  local current_dir="${PWD}"
  local -a panes

  tmux rename-window -t "$TMUX_PANE" "$(basename "$current_dir")"

  panes+=("$TMUX_PANE")

  while (( ${#panes[@]} < count )); do
    local new_pane
    local split_target="${panes[-1]}"
    new_pane=$(tmux split-window -h -t "$split_target" -c "$current_dir" -P -F '#{pane_id}')
    panes+=("$new_pane")
    tmux select-layout -t "${panes[1]}" tiled
  done

  local pane
  for pane in "${panes[@]}"; do
    tmux send-keys -t "$pane" "$cmd" C-m
  done

  tmux select-pane -t "${panes[1]}"
}

# --- zsh port of hsl (fns/herdr) ----------------------------------------------
# Identical to upstream except the column loop runs 1-based instead of 0-based.
# Uses _herdr_split/_herdr_ratio sourced verbatim from fns/herdr above.

# Create a multi-pane swarm layout with the same command started in each pane (great for AI)
# Usage: hsl <pane_count> <command>
hsl() {
  [[ -z $1 || -z $2 ]] && { echo "Usage: hsl <pane_count> <command>"; return 1; }
  [[ -z $HERDR_PANE_ID ]] && { echo "You must start herdr to use hsl."; return 1; }

  local count="$1"
  local cmd="$2"
  local current_dir="${PWD}"
  local -a columns panes

  herdr tab rename "$HERDR_TAB_ID" "$(basename "$current_dir")" >/dev/null

  # Tile into a grid: ceil(sqrt(count)) columns, rows spread across them
  local cols=1
  while (( cols * cols < count )); do ((cols++)); done

  # Even columns come from splitting the rightmost one off at 1/(n-k+1) each time,
  # which keeps the array in left-to-right order
  columns=("$HERDR_PANE_ID")
  local k
  for (( k = 1; k < cols; k++ )); do
    columns+=("$(_herdr_split "${columns[-1]}" right "$(_herdr_ratio 1 $((cols - k + 1)))" "$current_dir")")
  done

  # Split each column into its share of rows, again evenly and top-to-bottom
  local col index rows j last
  for (( index = 1; index <= cols; index++ )); do
    col="${columns[index]}"
    rows=$(( count / cols ))
    (( index <= count % cols )) && (( rows++ ))
    panes+=("$col")
    last="$col"
    for (( j = 1; j < rows; j++ )); do
      last=$(_herdr_split "$last" down "$(_herdr_ratio 1 $((rows - j + 1)))" "$current_dir")
      panes+=("$last")
    done
  done

  local pane
  for pane in "${panes[@]}"; do
    herdr pane run "$pane" "$cmd" >/dev/null
  done
}

# --- zsh port of fns/ssh-reconnect ---------------------------------------------
# Identical to upstream except `local argv` → `local saved_args` (argv is a
# reserved special in zsh, tied to the positional parameters) and
# ${letters:i:1} → ${letters:$i:1} (a bare `:i` is a history-style modifier
# in zsh, not an arithmetic offset).

# Wrap ssh to clean up the terminal and reconnect when a connection drops.
#
# A remote tmux, herdr, or editor arms terminal modes over the SSH pipe (mouse
# tracking, focus reporting, the alternate screen) that only it can disarm. If
# the connection dies instead of exiting cleanly, those modes stay armed on the
# local terminal, and every mouse move floods the prompt with escape junk.
ssh() {
  local rc started

  started=$SECONDS
  command ssh "$@"
  rc=$?

  [[ -t 1 ]] || return $rc
  _ssh_disarm

  # Reconnect only when an interactive session drops: ssh exits 255 for
  # transport failures, but a fast 255 with no established session is a
  # connect/auth failure, a remote command's own 255 passes through
  # indistinguishably and must not replay its side effects, and redirected
  # stdin would feed the remaining piped input to a fresh remote shell.
  if (( rc != 255 )) || [[ ! -t 0 ]] || ! _ssh_interactive "$@" ||
    (( SECONDS - started < 30 )); then
    return $rc
  fi

  # Retry in a subshell: Ctrl-C reaches the whole foreground process group,
  # so it cancels both the in-flight attempt and the loop itself. Keep
  # retrying fast failures, since a rebooting server refuses connections too.
  (
    while true; do
      echo "Connection lost. Reconnecting (Ctrl-C to stop)..."
      sleep 2
      command ssh "$@"
      rc=$?
      _ssh_disarm
      (( rc != 255 )) && exit $rc
    done
  )
}

# Disarm mouse tracking (1000/1002/1003, 1006 encoding), focus reporting
# (1004), and the alternate screen (1049), and show the cursor again.
_ssh_disarm() {
  printf '\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?1004l\e[?1049l\e[?25h'
}

# True for an interactive session: a destination and no remote command. The
# letters are the ssh(1) options that consume a value, so their arguments are
# not mistaken for the destination.
_ssh_interactive() {
  local value_opts="BbcDEeFIiJLlmOoPpQRSWw"
  local -a saved_args
  saved_args=("$@")
  local arg letters i dest="" opts_done=""

  while (($#)); do
    arg="$1"
    shift

    if [[ -z $opts_done && $arg == "--" ]]; then
      opts_done=1
    elif [[ -z $opts_done && $arg == -?* ]]; then
      letters="${arg#-}"
      for ((i = 0; i < ${#letters}; i++)); do
        if [[ $value_opts == *"${letters:$i:1}"* ]]; then
          # The value is glued to the letter (-p2222) unless the letter ends
          # the argument, in which case it consumes the next one (-p 2222).
          (( i == ${#letters} - 1 )) && shift
          break
        fi
      done
    elif [[ -z $dest ]]; then
      dest="$arg"
    else
      return 1
    fi
  done

  [[ -n $dest ]] || return 1

  # A RemoteCommand from ssh_config or -o replays on reconnect just like a
  # positional command; ssh -G resolves the effective configuration for this
  # exact invocation without connecting. Fail closed when it cannot resolve,
  # since an undetected RemoteCommand must not replay. The explicit "none"
  # cancels a configured command, and some versions emit it when unset.
  local resolved
  resolved=$(command ssh -G "${saved_args[@]}" 2>/dev/null) || return 1
  ! grep -i '^remotecommand ' <<<"$resolved" | grep -qvi '^remotecommand none$'
}

# ==============================================================================
# zsh equivalent of default/bash/init
# ==============================================================================

if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

if [[ $- == *i* ]] && [[ "${TERM:-}" != "dumb" ]] && command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

if command -v try &> /dev/null; then
  try() {
    unset -f try
    eval "$(SHELL=/bin/zsh command try init ~/Work/tries)"
    try "$@"
  }
fi

if command -v fzf &> /dev/null; then
  if [[ -f /usr/share/fzf/completion.zsh ]]; then
    source /usr/share/fzf/completion.zsh
  fi
  if [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
    source /usr/share/fzf/key-bindings.zsh
  fi
fi

# ==============================================================================
# zsh equivalents of default/bash/inputrc
# ==============================================================================
# oh-my-zsh already covers the important readline behavior: prefix history
# search on the arrow keys, case-insensitive completion, menu selection on
# Tab, and Shift-Tab cycling backwards. What remains:

# Colored, ls -F-style completion listings (colored-stats / visible-stats)
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ==============================================================================
# zsh completion for the `omarchy` command
# ==============================================================================
# Omarchy ships bash-only completion (default/bash/completions) that does not
# survive bashcompinit (shopt, 0-based COMP_WORDS, read -a). This native
# version walks the command table from `omarchy commands --json` instead of
# scanning the bin directory, with the same positional matching against each
# command's args spec.
_omarchy() {
  emulate -L zsh

  # One `omarchy commands --json` call (~250ms) per shell session
  if (( ! ${+_omarchy_command_table} )); then
    typeset -ga _omarchy_command_table
    _omarchy_command_table=(${(f)"$(command omarchy commands --json 2>/dev/null |
      jq -r '.commands[] | . as $c | (.routes[], .aliases[])
             | ltrimstr("omarchy ") + "\t" + $c.args + "\t" + $c.summary' 2>/dev/null)"})
  fi
  (( ${#_omarchy_command_table} )) || return 1

  local -a typed=("${(@)words[2,CURRENT-1]}")
  local entry route rest args summary next
  local -a route_words
  local i matched
  typeset -A subdesc            # next route word → summary ("" for groups)
  local best_args="" best_len=-1

  for entry in "${_omarchy_command_table[@]}"; do
    route="${entry%%$'\t'*}"
    rest="${entry#*$'\t'}"
    args="${rest%%$'\t'*}"
    summary="${rest#*$'\t'}"
    route_words=(${(s: :)route})

    if (( ${#route_words} > ${#typed} )); then
      # Route extends past what has been typed: offer its next word
      matched=1
      for (( i = 1; i <= ${#typed}; i++ )); do
        [[ "${route_words[i]}" == "${typed[i]}" ]] || { matched=0; break; }
      done
      if (( matched )); then
        next="${route_words[${#typed}+1]}"
        if (( ${#route_words} == ${#typed} + 1 )); then
          subdesc[$next]="$summary"
        elif [[ -z "${subdesc[$next]+x}" ]]; then
          subdesc[$next]=""
        fi
      fi
    else
      # Route fully consumed by what has been typed: remember the longest
      # match so the remaining words complete against its args spec
      matched=1
      for (( i = 1; i <= ${#route_words}; i++ )); do
        [[ "${route_words[i]}" == "${typed[i]}" ]] || { matched=0; break; }
      done
      if (( matched && ${#route_words} > best_len )); then
        best_len=${#route_words}
        best_args="$args"
      fi
    fi
  done

  # The `commands` subcommand is the dispatcher's own and not in the JSON
  local -a arg_candidates
  typeset -A seen_arg
  if (( ${#typed} == 0 )); then
    subdesc[commands]="List all omarchy commands"
  elif [[ "${typed[1]}" == "commands" ]]; then
    arg_candidates+=(--all --json --markdown --check)
  fi

  # Positional args: match consumed words against each " | "-separated
  # alternative in the spec, then offer literals and <a|b>/[a|b] values at
  # the current position (same behavior as the upstream bash completion)
  if [[ -n "$best_args" ]]; then
    local argpos=$(( ${#typed} - best_len ))
    local -a consumed=("${(@)typed[best_len+1,-1]}")
    local alt token value actual j ok
    local -a spec_words
    for alt in "${(@s: | :)best_args}"; do
      spec_words=(${(s: :)alt})
      ok=1
      for (( j = 1; j <= argpos; j++ )); do
        token="${spec_words[j]:-}"
        actual="${consumed[j]:-}"
        [[ -n "$token" ]] || { ok=0; break; }
        if [[ "$token" == \<*\> || "$token" == \[*\] ]]; then
          value="${token#<}"; value="${value#\[}"
          value="${value%>}"; value="${value%\]}"
          if [[ "$value" == *"|"* ]]; then
            [[ " ${value//|/ } " == *" $actual "* ]] || { ok=0; break; }
          fi
        elif [[ "$token" != "$actual" ]]; then
          ok=0; break
        fi
      done
      (( ok )) || continue

      token="${spec_words[argpos+1]:-}"
      [[ -n "$token" ]] || continue
      if [[ "$token" == \<*\> || "$token" == \[*\] ]]; then
        value="${token#<}"; value="${value#\[}"
        value="${value%>}"; value="${value%\]}"
        if [[ "$value" == *"|"* ]]; then
          for value in "${(@s:|:)value}"; do
            [[ -n "${seen_arg[$value]:-}" ]] && continue
            seen_arg[$value]=1
            arg_candidates+=("$value")
          done
        fi
      else
        [[ -n "${seen_arg[$token]:-}" ]] && continue
        seen_arg[$token]=1
        arg_candidates+=("$token")
      fi
    done
  fi

  local -a display
  local key
  for key in "${(@k)subdesc}"; do
    if [[ -n "${subdesc[$key]}" ]]; then
      display+=("${key}:${subdesc[$key]}")
    else
      display+=("$key")
    fi
  done

  local ret=1
  (( ${#display} )) && _describe -t omarchy-commands 'omarchy command' display && ret=0
  (( ${#arg_candidates} )) && _describe -t omarchy-args 'argument' arg_candidates && ret=0
  (( ret )) && _files
  return ret
}

if (( ${+functions[compdef]} )); then
  compdef _omarchy omarchy
fi
