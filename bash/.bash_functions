# ==============================================================================
# DIRECTORY HELPERS
# ==============================================================================

# make and cd to a directory
mkcd() {
    local dir="$1"
    if [ -z "$dir" ]; then
        echo "Usage: mkcd <directory>"
        return 1
    fi
    mkdir -p "$dir" && cd "$dir"
}

# ==============================================================================
# DOCKER HELPERS
# ==============================================================================

# remove common Docker orphaned resources
docker-clean() {
    echo "Removing stopped containers..."
    docker container prune -f
    echo "Removing dangling images..."
    docker image prune -f
    echo "Removing unused networks..."
    docker network prune -f
    echo "Docker cleanup complete."
}

# ==============================================================================
# SHELL HELPERS
# ==============================================================================

# validate bashrc syntax, then reload it
rebash() {
    if bash -n "$HOME/.bashrc"; then
        source "$HOME/.bashrc"
    else
        echo "bashrc has syntax errors; reload aborted."
        return 1
    fi
}

# ==============================================================================
# END
# ==============================================================================
