#!/usr/bin/env zsh

# ------------------------------------------------------------------------------
# Workmachine theme - based on refined/Pure
# Shows user@host prominently so you always know where you are.
# ------------------------------------------------------------------------------

setopt prompt_subst

autoload -Uz vcs_info

zstyle ':vcs_info:*' enable hg bzr git
zstyle ':vcs_info:*:*' unstagedstr '!'
zstyle ':vcs_info:*:*' stagedstr '+'
zstyle ':vcs_info:*:*' formats "$FX[bold]%r$FX[no-bold]/%S" "%s:%b" "%%u%c"
zstyle ':vcs_info:*:*' actionformats "$FX[bold]%r$FX[no-bold]/%S" "%s:%b" "%u%c (%a)"
zstyle ':vcs_info:*:*' nvcsformats "%~" "" ""

git_dirty() {
    command git rev-parse --is-inside-work-tree &>/dev/null || return
    command git diff --quiet --ignore-submodules HEAD &>/dev/null; [ $? -eq 1 ] && echo "*"
}

repo_information() {
    echo "%F{blue}${vcs_info_msg_0_%%/.} %F{8}$vcs_info_msg_1_`git_dirty` $vcs_info_msg_2_%f"
}

cmd_exec_time() {
    local stop=`date +%s`
    local start=${cmd_timestamp:-$stop}
    let local elapsed=$stop-$start
    [ $elapsed -gt 5 ] && echo ${elapsed}s
}

preexec() {
    cmd_timestamp=`date +%s`
}

precmd() {
    setopt localoptions nopromptsubst
    vcs_info
    print -P "\n%F{green}%B%n@%m%b%f $(repo_information) %F{yellow}$(cmd_exec_time)%f"
    unset cmd_timestamp
}

PROMPT="%(?.%F{magenta}.%F{red})❯%f "
RPROMPT=""
