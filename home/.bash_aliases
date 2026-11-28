# ==============================================================================
# EZA — Modern ls replacement
# ==============================================================================

# Core behavior
alias eza='command eza --icons=auto --color=auto --group-directories-first'


# ls compatibility
alias ls='eza'
alias ll='eza --long --header'
alias la='eza --all'
alias l='eza --oneline'

# Combined views
alias lla='eza --long --header --all'
alias llt='eza --long --header --tree --level=2'

# Tree
alias lt='eza --tree --level=2'
alias lT='eza --tree'


# ==============================================================================
# CORE SYSTEM ALIASES
# ==============================================================================

# find alternative
alias fd='fdfind'

# color support
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'


# ==============================================================================
# OS COMPATIBILITY
# ==============================================================================

alias cls='clear'          # Windows-style clear

# ==============================================================================
# TERMINAL / UX
# ==============================================================================

# blank the screen (no suspend)
alias blank='sleep 1; xset dpms force off'

# reload readline (~/.inputrc) in the current shell
alias reinput='bind -f ~/.inputrc'

# clipboard (xclip → Ctrl+C/V selection)
alias clipcopy='xclip -selection clipboard'
alias clippaste='xclip -selection clipboard -o'

# current date/time (YYYY-MM-DD HH:MM:SS)
alias now='date "+%Y-%m-%d %H:%M:%S"'

# Funny aliases
alias cmatrix='cmatrix -C black'
alias sl='sl -lae'

# Persian keyboard mistakes
alias زمس='clear'
alias زمثشق='clear'

# ==============================================================================
# GPG
# ==============================================================================

# Matches gpg.conf group `me`. Fingerprint: ~/.gnupg/gpg.conf default-key
export GPG_KEY=me
export GPG_KEY_FILE=$HOME/gpg-public-key.asc

# ==============================================================================
# DEVELOPMENT
# ==============================================================================

# VSCode
alias codehere='code -a .'

# ==============================================================================
# NETWORK / DEBUG
# ==============================================================================

# download w/ file name & resume
alias wget='wget --content-disposition'

alias myip='curl -s ifconfig.me'
alias ports='ss -tulpen'
alias pingg='ping google.com'
alias sniff='sudo tcpdump -i any -n'

# ==============================================================================
# NAVIGATION & FILE MANAGEMENT
# ==============================================================================

# navigate up
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# quick navigation to dev subdirs (English Keys)
alias pers='cd ~/dev/personal'
alias wrk='cd ~/dev/work'
alias dots='cd ~/dev/personal/dot-files'
alias vend='cd ~/dev/vendor'

# file management
alias rmf='rm -rf'
alias mkdirp='mkdir -p'

# safer defaults
alias cp='cp -i'
alias mv='mv -i'

# ==============================================================================
# SEARCH
# ==============================================================================

alias grep='grep --color=auto -n'
alias fgrep='fgrep --color=auto -n'
alias egrep='egrep --color=auto -n'
alias f='find . -name'

# ==============================================================================
# SYSTEM MONITORING
# ==============================================================================

alias mem='free -h'
alias disk='df -h'
alias filesize='du -sh'

# ==============================================================================
# END
# ==============================================================================
