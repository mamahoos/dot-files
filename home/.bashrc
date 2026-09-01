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

# ======================================================================
# 4. Debian chroot indicator (used in prompt)
# ======================================================================

if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot="$(cat /etc/debian_chroot)"
fi

# ======================================================================
# 5. Prompt configuration (PS1)
# ======================================================================

# Detect color support
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes ;;
esac

# Force color prompt (disabled by default)
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if command -v tput >/dev/null 2>&1 && tput setaf 1 >/dev/null 2>&1; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi

# Define prompt
prompt_prefix='${debian_chroot:+($debian_chroot)}'

if [ "$color_prompt" = yes ]; then
    PS1="${prompt_prefix}\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
else
    PS1="${prompt_prefix}\u:\w\$ "
fi

# Set terminal title for xterm-like terminals
case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${prompt_prefix}\u: \w\a\]$PS1"
        ;;
esac

unset prompt_prefix color_prompt force_color_prompt

# ======================================================================
# 6. Color support
# ======================================================================

if command -v dircolors >/dev/null 2>&1; then
    test -r ~/.dircolors \
        && eval "$(dircolors -b ~/.dircolors)" \
        || eval "$(dircolors -b)"
fi

# ======================================================================
# 7. GCC diagnostics coloring
# ======================================================================

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# ======================================================================
# 8. User aliases (external file)
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
# 9. Bash completion
# ======================================================================

if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        source /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        source /etc/bash_completion
    fi
fi

# ======================================================================
# 10. Optional toolchains (cargo, pyenv, nvm, …)
# ======================================================================

if [ -f "$HOME/.bashrc.tools" ]; then
    source "$HOME/.bashrc.tools"
fi

# ======================================================================
# 11. Ghostty (no-op outside Ghostty)
# ======================================================================

if [ -f "$HOME/.bashrc.ghostty" ]; then
    source "$HOME/.bashrc.ghostty"
fi

# ======================================================================
# 12. Local-only overrides (never commit secrets)
# ======================================================================

if [ -f "$HOME/.bashrc.local" ]; then
    source "$HOME/.bashrc.local"
fi

# ======================================================================
# End of ~/.bashrc
# ======================================================================