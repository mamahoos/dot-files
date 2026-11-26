# ======================================================================
# ~/.bashrc
# ----------------------------------------------------------------------
# Executed by bash(1) for non-login interactive shells
# Debian default base, cleaned and structured
# ======================================================================


# ======================================================================
# 1. Interactive shell guard
# ----------------------------------------------------------------------
# Do nothing if not running interactively
# ======================================================================

case $- in
    *i*) ;;
      *) return ;;
esac

# ==============================================================================
# 1a. Optional profile overlay
# ------------------------------------------------------------------------------
# The server branch adds ~/.bashrc.server for host-specific shell policy.
# Main remains profile-neutral when the overlay is absent.
# ==============================================================================

if [[ -f "$HOME/.bashrc.server" ]]; then
    # shellcheck source=/dev/null
    source "$HOME/.bashrc.server"
fi

# ======================================================================
# 2. Bash history behavior
# ======================================================================

# Ignore duplicates and commands starting with space
HISTCONTROL=ignoreboth

# Append to history instead of overwriting
shopt -s histappend

# History sizes
HISTSIZE=5000
HISTFILESIZE=10000

# ======================================================================
# 3. Shell behavior tweaks
# ======================================================================

# Update LINES and COLUMNS after each command
shopt -s checkwinsize

# Enable ** globbing (optional)
shopt -s globstar

# Enable extended globbing (optional)
shopt -s extglob

# Enable programmable completion (optional)
shopt -s progcomp

# Enable command history (optional)
shopt -s cmdhist

# Append to history instead of overwriting
shopt -s histappend

# Enable failglob to prevent globbing from matching no files
shopt -s failglob

# Enable dotglob to include hidden files in globbing
shopt -s dotglob

# Enable nullglob to match no files
shopt -s nullglob

# Enable complete_fullquote to complete quoted arguments
shopt -s complete_fullquote

# Vi editing (matches ~/.inputrc editing-mode)
set -o vi

# Readline Esc-v and CLI tools use $VISUAL, then $EDITOR.
export EDITOR=nvim
export VISUAL=nvim

# ======================================================================
# 4. Color support
# ======================================================================

if command -v dircolors >/dev/null 2>&1; then
    test -r ~/.dircolors \
        && eval "$(dircolors -b ~/.dircolors)" \
        || eval "$(dircolors -b)"
fi

# ======================================================================
# 5. GCC diagnostics coloring
# ======================================================================

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# ======================================================================
# 6. User aliases and functions (external files)
# ======================================================================

# Aliases
if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

# Functions
if [ -f ~/.bash_functions ]; then
    source ~/.bash_functions
fi

# ======================================================================
# 7. Prompt (PROMPT_COMMAND rebuilds PS1; see ~/.bash_prompt)
# ======================================================================

if [ -f "$HOME/.bash_prompt" ]; then
    source "$HOME/.bash_prompt"
fi

# ======================================================================
# 8. Bash completion
# ----------------------------------------------------------------------
# bash-completion loads per-command scripts lazily on the first TAB. The
# user directory is the repo-managed config/bash-completion/completions,
# symlinked to ~/.config/bash-completion, with the XDG default kept as a
# fallback. An already exported value wins.
# ======================================================================

if ! shopt -oq posix; then
    _completion_dirs="${XDG_CONFIG_HOME:-$HOME/.config}/bash-completion"
    _completion_dirs+=":${XDG_DATA_HOME:-$HOME/.local/share}/bash-completion"
    export BASH_COMPLETION_USER_DIR="${BASH_COMPLETION_USER_DIR:-$_completion_dirs}"
    unset -v _completion_dirs

    if [ -f /usr/share/bash-completion/bash_completion ]; then
        source /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        source /etc/bash_completion
    fi
fi

# ======================================================================
# 9. Optional toolchains (cargo, pyenv, nvm, …)
# ======================================================================

if [ -f "$HOME/.bashrc.tools" ]; then
    source "$HOME/.bashrc.tools"
fi

# ======================================================================
# 10. Ghostty (no-op outside Ghostty)
# ======================================================================

if [ -f "$HOME/.bashrc.ghostty" ]; then
    source "$HOME/.bashrc.ghostty"
fi

# Ghostty starts bash via GHOSTTY_BASH_INJECT (POSIX, then this file).
# Readline is already initialized with library defaults, so ~/.inputrc
# never applied: bind -v showed show-mode-in-prompt off and (cmd)/(ins).
if [ -f "$HOME/.inputrc" ]; then
    bind -f "$HOME/.inputrc"
fi

# ======================================================================
# 11. Local-only overrides (never commit secrets)
# ======================================================================

if [ -f "$HOME/.bashrc.local" ]; then
    source "$HOME/.bashrc.local"
fi

# ======================================================================
# 12. fzf configurations
# ======================================================================

export FZF_DEFAULT_OPTS="--no-mouse --height 50% -1 --reverse --multi --inline-info --preview='[[ \$(file --mime {}) =~ binary ]] && echo {} is a binary file || (batcat --style=numbers --color=always {} || cat {}) 2> /dev/null | head -300' --preview-window='right:hidden:wrap' --bind='f3:execute(bat --style=numbers {} || less -f {}),f2:toggle-preview,ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-a:select-all+accept,ctrl-y:execute-silent(echo {+} | pbcopy)'"

# ======================================================================
# End of ~/.bashrc
# ======================================================================
