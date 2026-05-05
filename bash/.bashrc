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
# shopt -s globstar

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
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

unset color_prompt force_color_prompt

# Set terminal title for xterm-like terminals
case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
esac


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

if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
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
# 10. User-level binaries (pipx, local installs)
# ======================================================================

# Created by `pipx`
export PATH="$HOME/.local/bin:$PATH" 	# Added poetry & posting & etc (by pipx)

# ======================================================================
# 11. Rust (cargo)
# ======================================================================

# Adds ~/.cargo/bin to PATH
. "$HOME/.cargo/env"	# Added tokei & etc (by cargo)

# ======================================================================
# 12. Python version management (pyenv)
# ======================================================================

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

# ======================================================================
# 13. Kiro env
# ======================================================================

export PATH="$PATH:/usr/sbin"

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path bash)"

# ======================================================================
# End of ~/.bashrc
# ======================================================================
