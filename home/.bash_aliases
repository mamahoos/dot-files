# ==============================================================================
# CORE SYSTEM ALIASES
# ==============================================================================

# ls family (readable defaults)
alias ls='ls --color=auto'
alias ll='ls -lh'          # long + human-readable sizes
alias la='ls -A'           # include hidden (except . ..)
alias l='ls -CF'           # column view + type indicators

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

alias blank='sleep 1; xset dpms force off'

# clipboard (xclip → Ctrl+C/V selection)
alias clipcopy='xclip -selection clipboard'
alias clippaste='xclip -selection clipboard -o'

# Funny aliases
alias cmatrix='cmatrix -C black'
alias sl='sl -lae'

# Persian keyboard mistakes
alias زمس='clear'
alias زمثشق='clear'

# ==============================================================================
# GPG
# ==============================================================================

# fingerprint as a value, not a command alias (aliases do not expand as args)
export GPG_KEY=36ECB76080BA15C0BF93CC93B083DC8105E593AE # gitleaks:allow

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

# ==============================================================================
# END
# ==============================================================================
