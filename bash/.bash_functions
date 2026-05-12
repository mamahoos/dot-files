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

# extract an archive
extract() {
    local archive_path="${1:-}"
    local output_dir="${2:-}"
    local archive_name
    local mime_type
    local status

    # --------------------------------------------------------------------------
    # Error logger
    # --------------------------------------------------------------------------
    _extract_error() {
        printf '[extract] %s\n' "$*" >&2
    }

    # --------------------------------------------------------------------------
    # Validation
    # --------------------------------------------------------------------------
    if [[ -z "$archive_path" ]]; then
        _extract_error "usage: extract <archive> [output_dir]"
        return 1
    fi

    if [[ ! -e "$archive_path" ]]; then
        _extract_error "file does not exist: $archive_path"
        return 1
    fi

    if [[ ! -f "$archive_path" ]]; then
        _extract_error "not a regular file: $archive_path"
        return 1
    fi

    if [[ ! -r "$archive_path" ]]; then
        _extract_error "file is not readable: $archive_path"
        return 1
    fi

    archive_name="$(basename -- "$archive_path")"

    # --------------------------------------------------------------------------
    # Auto output directory
    # --------------------------------------------------------------------------
    if [[ -z "$output_dir" ]]; then
        output_dir="${archive_name%.*}"
        output_dir="${output_dir%.tar}"
    fi

    mkdir -p -- "$output_dir" || {
        _extract_error "failed to create output directory: $output_dir"
        return 1
    }

    # --------------------------------------------------------------------------
    # MIME fallback
    # --------------------------------------------------------------------------
    mime_type="$(file --brief --mime-type -- "$archive_path" 2>/dev/null)"

    # --------------------------------------------------------------------------
    # Dependency checker
    # --------------------------------------------------------------------------
    _require() {
        command -v "$1" >/dev/null 2>&1 || {
            _extract_error "missing dependency: $1"
            return 1
        }
    }

    # --------------------------------------------------------------------------
    # Extract inside target dir
    # --------------------------------------------------------------------------
    pushd "$output_dir" >/dev/null || {
        _extract_error "failed to enter directory: $output_dir"
        return 1
    }

    # Supported archive formats:
    # - .tar.gz, .tgz
    # - .tar.bz2, .tbz2
    # - .tar.xz
    # - .tar.zst, .tzst
    # - .tar
    # - .zip
    # - .rar
    # - .7z
    # - .gz
    # - .bz2
    # - .xz
    # - .zst

    case "$archive_path" in
        *.tar.gz|*.tgz)
            _require tar || return 1
            tar -xzf "../$archive_path"
            status=$?
            ;;

        *.tar.bz2|*.tbz2)
            _require tar || return 1
            tar -xjf "../$archive_path"
            status=$?
            ;;

        *.tar.xz)
            _require tar || return 1
            tar -xJf "../$archive_path"
            status=$?
            ;;

        *.tar.zst|*.tzst)
            _require tar || return 1
            tar --zstd -xf "../$archive_path"
            status=$?
            ;;

        *.tar)
            _require tar || return 1
            tar -xf "../$archive_path"
            status=$?
            ;;

        *.zip)
            _require unzip || return 1
            unzip -qq -o "../$archive_path"
            status=$?
            ;;

        *.rar)
            if command -v unrar >/dev/null 2>&1; then
                unrar x -idq -o+ "../$archive_path"
                status=$?
            elif command -v rar >/dev/null 2>&1; then
                rar x -idq -o+ "../$archive_path"
                status=$?
            else
                _extract_error "missing dependency: unrar or rar"
                popd >/dev/null || true
                return 1
            fi
            ;;

        *.7z)
            _require 7z || return 1
            7z x -bd -y "../$archive_path" >/dev/null
            status=$?
            ;;

        *.gz)
            _require gunzip || return 1
            gunzip -k "../$archive_path"
            status=$?
            ;;

        *.bz2)
            _require bunzip2 || return 1
            bunzip2 -k "../$archive_path"
            status=$?
            ;;

        *.xz)
            _require unxz || return 1
            unxz -k "../$archive_path"
            status=$?
            ;;

        *.zst)
            _require unzstd || return 1
            unzstd -k "../$archive_path"
            status=$?
            ;;

        *)
            case "$mime_type" in
                application/zip)
                    _require unzip || return 1
                    unzip -qq -o "../$archive_path"
                    status=$?
                    ;;

                application/x-tar)
                    _require tar || return 1
                    tar -xf "../$archive_path"
                    status=$?
                    ;;

                *)
                    _extract_error "unsupported archive format: $archive_path"
                    popd >/dev/null || true
                    return 1
                    ;;
            esac
            ;;
    esac

    popd >/dev/null || true

    # --------------------------------------------------------------------------
    # Cleanup on failure
    # --------------------------------------------------------------------------
    if [[ $status -ne 0 ]]; then
        if [[ -d "$output_dir" && -z "$(ls -A "$output_dir" 2>/dev/null)" ]]; then
            rmdir "$output_dir" 2>/dev/null
        fi

        _extract_error "extraction failed: $archive_path"
        return "$status"
    fi

    return 0
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
