# ==============================================================================
# CORE SYSTEM ALIASES
# ==============================================================================

# ls family (readable defaults)
alias ls='ls --color=auto'
alias ll='ls -lh'          # long + human-readable sizes
alias la='ls -A'           # include hidden (except . ..)
alias l='ls -CF'           # column view + type indicators

# navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# color support
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'


# ==============================================================================
# OS COMPATIBILITY
# ==============================================================================

alias cls='clear'          # Windows-style clear

# ==============================================================================
# TERMINAL / UX
# ==============================================================================

alias blank='sleep 1; xset dpms force off'

# Persian keyboard mistakes
alias زمس='clear'
alias زمثشق='clear'

# sudo last command
alias please='sudo $(fc -ln -1)'

# ==============================================================================
# DEVELOPMENT
# ==============================================================================

# VSCode
alias codehere='code -a .'

# ==============================================================================
# DOCKER
# ==============================================================================

# kill all containers ⚠️
alias dockill='docker kill $(docker ps -q)'

# cleanup stopped containers
alias dclean='docker container prune -f'

# ==============================================================================
# NETWORK / DEBUG
# ==============================================================================

alias myip='curl -s ifconfig.me'
alias ports='ss -tulpen'
alias pingg='ping google.com'

# ==============================================================================
# FILE MANAGEMENT
# ==============================================================================

alias rmf='rm -rf'
alias mkdirp='mkdir -p'

# safer defaults
alias cp='cp -i'
alias mv='mv -i'

# ==============================================================================
# SEARCH
# ==============================================================================

alias grep='grep --color=auto -n'
alias f='find . -name'

# ==============================================================================
# SYSTEM MONITORING
# ==============================================================================

alias mem='free -h'
alias disk='df -h'

# ==============================================================================
# QUICK NAVIGATION TO DEV SUBDIRS (English Keys)
# ==============================================================================

alias pers='cd ~/dev/personal'
alias wrk='cd ~/dev/work'
alias dots='cd ~/dev/personal/dot-files'

# ==============================================================================
# END
# ==============================================================================
