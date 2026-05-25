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

# Funny aliases
alias cmatrix='cmatrix -C black'

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

# ==============================================================================
# NETWORK / DEBUG
# ==============================================================================

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
# MATRIX SYNAPSE ADMIN
# ==============================================================================

# User Management
alias mx-create-user='ssh hotdog "~/matrix-deploy/scripts/create_user.sh"'
alias mx-delete-user='ssh hotdog "~/matrix-deploy/scripts/delete_user.sh"'
alias mx-list-users='ssh hotdog "~/matrix-deploy/scripts/list_users.sh"'
alias mx-modify-user='ssh hotdog "~/matrix-deploy/scripts/modify_user.sh"'
alias mx-user-info='ssh hotdog "~/matrix-deploy/scripts/user_info.sh"'
alias mx-wipe-sessions='ssh hotdog "~/matrix-deploy/scripts/wipe_user_sessions.sh"'

# Monitoring & Stats
alias mx-health='ssh hotdog "~/matrix-deploy/scripts/matrix_healthcheck.sh"'
alias mx-logs='ssh hotdog "~/matrix-deploy/scripts/matrix_logs.sh"'
alias mx-stats='ssh hotdog "~/matrix-deploy/scripts/matrix_stats.sh"'
alias mx-status='ssh hotdog "~/matrix-deploy/scripts/matrix_status.sh"'
alias mx-msg-count='ssh hotdog "~/matrix-deploy/scripts/user_message_count.sh"'

# ==============================================================================
# END
# ==============================================================================
