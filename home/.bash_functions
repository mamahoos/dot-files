# ==============================================================================
# COMMON HELPERS
# ==============================================================================

# Require a command to be available in PATH.
_require_cmd() {
    local error_prefix="$1"
    local command_name="$2"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        printf '%s missing dependency: %s\n' "$error_prefix" "$command_name" >&2
        return 1
    fi
}

# Print the first available command from a list.
_require_any_cmd() {
    local error_prefix="$1"
    local command_name

    shift

    for command_name in "$@"; do
        if command -v "$command_name" >/dev/null 2>&1; then
            printf '%s\n' "$command_name"
            return 0
        fi
    done

    printf '%s missing dependency: %s\n' "$error_prefix" "$*" >&2
    return 1
}

# Print a consistently prefixed error message.
_log_error() {
    printf '[%s] %s\n' "$1" "$2" >&2
}


# ==============================================================================
# DIRECTORY HELPERS
# ==============================================================================

# Create a directory and change into it.
mkcd() {
    local dir="${1:-}"

    if [[ -z "$dir" ]]; then
        printf 'Usage: mkcd <directory>\n' >&2
        return 1
    fi

    mkdir -p -- "$dir" && cd -- "$dir"
}


# ==============================================================================
# GIT
# ==============================================================================

# Clone a repository and change into it.
# Usage: gclone <repo-url> [target-dir]
gclone() {
    local repo_url="${1:-}"
    local target_dir

    if [[ -z "$repo_url" ]]; then
        printf 'Usage: gclone <repo-url> [target-dir]\n' >&2
        return 1
    fi

    _require_cmd '[gclone]' git || return 1

    target_dir="${2:-$(basename -- "${repo_url%/}" .git)}"

    git clone -- "$repo_url" "$target_dir" &&
        cd -- "$target_dir"
}


# ==============================================================================
# GENERAL UTILITIES
# ==============================================================================

# Repeat the previous command with sudo.
please() {
    local previous_command

    previous_command="$(history -p '!!')" || return 1
    [[ -n "$previous_command" ]] || return 1

    sudo bash -c "$previous_command"
}

# Quick reference from cheat.sh, with a local cache for offline use.
cheat() {
    local topic="${1:-}"
    local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/cheat"
    local cache_file
    local url

    if [[ -z "$topic" ]]; then
        printf 'Usage: cheat <topic>\n' >&2
        return 1
    fi

    mkdir -p -- "$cache_dir" || {
        _log_error cheat "failed to create cache directory: $cache_dir"
        return 1
    }

    # Keep cache filenames predictable and safe.
    cache_file="$cache_dir/${topic//[^a-zA-Z0-9._\/-]/_}.txt"

    if command -v curl >/dev/null 2>&1; then
        url="https://cheat.sh/$(printf '%s' "$topic" | sed 's/ /+/g')"

        if curl -fsS --max-time 8 "$url" -o "$cache_file.tmp" 2>/dev/null &&
            [[ -s "$cache_file.tmp" ]]; then
            mv -f -- "$cache_file.tmp" "$cache_file" || return 1
            cat -- "$cache_file"
            return
        fi

        rm -f -- "$cache_file.tmp"
    fi

    if [[ -f "$cache_file" ]]; then
        _log_error cheat "offline; showing cached result for: $topic"
        cat -- "$cache_file"
        return
    fi

    _log_error cheat "no network connection and no cached result for: $topic"
    return 1
}

# Extract common archive formats.
# Usage: extract <archive> [output-dir]
extract() {
    local archive_path="${1:-}"
    local output_dir="${2:-}"
    local archive_name
    local archive_dir
    local mime_type=''
    local extractor=''
    local status=0
    local output_dir_created=false
    local -a extract_args=()

    if [[ -z "$archive_path" ]]; then
        _log_error extract 'Usage: extract <archive> [output-dir]'
        return 1
    fi

    if [[ ! -e "$archive_path" ]]; then
        _log_error extract "file does not exist: $archive_path"
        return 1
    fi

    if [[ ! -f "$archive_path" ]]; then
        _log_error extract "not a regular file: $archive_path"
        return 1
    fi

    if [[ ! -r "$archive_path" ]]; then
        _log_error extract "file is not readable: $archive_path"
        return 1
    fi

    # Resolve the archive path before changing directories. This avoids
    # fragile ../ path handling when output-dir is nested or absolute.
    archive_dir="$(cd -- "$(dirname -- "$archive_path")" && pwd -P)" || {
        _log_error extract "cannot resolve archive directory: $archive_path"
        return 1
    }
    archive_path="$archive_dir/$(basename -- "$archive_path")"
    archive_name="$(basename -- "$archive_path")"

    if [[ -z "$output_dir" ]]; then
        output_dir="${archive_name%.*}"
        output_dir="${output_dir%.tar}"
        [[ -n "$output_dir" ]] || output_dir='.'
    fi

    if [[ ! -d "$output_dir" ]]; then
        mkdir -p -- "$output_dir" || {
            _log_error extract "failed to create output directory: $output_dir"
            return 1
        }
        output_dir_created=true
    fi

    # Select the extractor and its arguments once, then execute it below.
    case "$archive_name" in
        *.tar.gz|*.tgz)
            extractor=tar
            extract_args=(-xzf "$archive_path")
            ;;
        *.tar.bz2|*.tbz2)
            extractor=tar
            extract_args=(-xjf "$archive_path")
            ;;
        *.tar.xz)
            extractor=tar
            extract_args=(-xJf "$archive_path")
            ;;
        *.tar.zst|*.tzst)
            extractor=tar
            extract_args=(--zstd -xf "$archive_path")
            ;;
        *.tar)
            extractor=tar
            extract_args=(-xf "$archive_path")
            ;;
        *.zip)
            extractor=unzip
            extract_args=(-qq -o "$archive_path")
            ;;
        *.rar)
            extractor="$(_require_any_cmd '[extract]' unrar rar)" || {
                [[ "$output_dir_created" == true ]] && rmdir -- "$output_dir" 2>/dev/null
                return 1
            }
            extract_args=(x -idq -o+ "$archive_path")
            ;;
        *.7z)
            extractor=7z
            extract_args=(x -bd -y "$archive_path")
            ;;
        *.gz)
            extractor=gunzip
            extract_args=(-k "$archive_path")
            ;;
        *.bz2)
            extractor=bunzip2
            extract_args=(-k "$archive_path")
            ;;
        *.xz)
            extractor=unxz
            extract_args=(-k "$archive_path")
            ;;
        *.zst)
            extractor=unzstd
            extract_args=(-k "$archive_path")
            ;;
        *)
            if command -v file >/dev/null 2>&1; then
                mime_type="$(file --brief --mime-type -- "$archive_path" 2>/dev/null)"
            fi

            case "$mime_type" in
                application/zip)
                    extractor=unzip
                    extract_args=(-qq -o "$archive_path")
                    ;;
                application/x-tar)
                    extractor=tar
                    extract_args=(-xf "$archive_path")
                    ;;
                *)
                    _log_error extract "unsupported archive format: $archive_path"
                    [[ "$output_dir_created" == true ]] && rmdir -- "$output_dir" 2>/dev/null
                    return 1
                    ;;
            esac
            ;;
    esac

    _require_cmd '[extract]' "$extractor" || {
        [[ "$output_dir_created" == true ]] && rmdir -- "$output_dir" 2>/dev/null
        return 1
    }

    if ! pushd "$output_dir" >/dev/null; then
        _log_error extract "failed to enter output directory: $output_dir"
        [[ "$output_dir_created" == true ]] && rmdir -- "$output_dir" 2>/dev/null
        return 1
    fi

    "${extractor}" "${extract_args[@]}"
    status=$?

    popd >/dev/null || return 1

    if ((status != 0)); then
        _log_error extract "extraction failed: $archive_path (exit status: $status)"
        if [[ "$output_dir_created" == true ]]; then
            rmdir -- "$output_dir" 2>/dev/null || true
        fi
        return "$status"
    fi
}

# Cut a video without re-encoding.
# Usage: ffcut <input> <start> <end> <output>
ffcut() {
    if (($# != 4)); then
        printf 'Usage: ffcut <input> <start> <end> <output>\n' >&2
        return 1
    fi

    _require_cmd '[ffcut]' ffmpeg || return 1
    ffmpeg -ss "$2" -to "$3" -i "$1" -c copy "$4"
}


# ==============================================================================
# DOCKER HELPERS
# ==============================================================================

# Stream a local Docker image to a remote host over SSH.
# Usage: docker-push-host <image> <user@host>
docker-push-host() {
    local image="${1:-}"
    local host="${2:-}"
    local compress_cmd
    local status

    if [[ -z "$image" || -z "$host" ]]; then
        printf 'Usage: docker-push-host <image> <host>\n' >&2
        return 1
    fi

    _require_cmd '[docker-push-host]' docker || return 1
    _require_cmd '[docker-push-host]' ssh || return 1
    compress_cmd="$(_require_any_cmd '[docker-push-host]' gzip gz)" || return 1

    if ! docker image inspect -- "$image" >/dev/null 2>&1; then
        _log_error docker-push-host "image not found locally: $image"
        return 1
    fi

    # pipefail ensures failures from docker save/compression are not hidden
    # by a successful final command in the pipeline.
    if (
        set -o pipefail

        if command -v pv >/dev/null 2>&1; then
            docker save -- "$image" |
                pv -p -f -N "push $image" |
                "$compress_cmd" -c |
                ssh -C "$host" 'gzip -dc | docker load'
        else
            docker save -- "$image" |
                "$compress_cmd" -c |
                ssh -C "$host" 'gzip -dc | docker load'
        fi
    ); then
        return 0
    else
        status=$?
    fi

    _log_error docker-push-host "failed to push image: $image -> $host"
    return "$status"
}

# Kill all running containers.
dockill() {
    local -a containers=()

    _require_cmd '[dockill]' docker || return 1

    mapfile -t containers < <(docker ps -q)
    if ((${#containers[@]} == 0)); then
        printf '[dockill] no running containers\n'
        return 0
    fi

    docker kill "${containers[@]}"
}

# Remove common unused Docker resources.
docker-clean() {
    local status=0

    _require_cmd '[docker-clean]' docker || return 1

    printf 'Removing stopped containers...\n'
    docker container prune -f || status=$?

    printf 'Removing dangling images...\n'
    docker image prune -f || status=$?

    printf 'Removing unused networks...\n'
    docker network prune -f || status=$?

    if ((status == 0)); then
        printf 'Docker cleanup complete.\n'
    else
        _log_error docker-clean 'one or more cleanup operations failed'
    fi

    return "$status"
}


# ==============================================================================
# NETWORK HELPERS
# ==============================================================================

# Print the resolved hostname for an SSH config alias.
ssh-hostname() {
    local host="${1:-}"

    if [[ -z "$host" ]]; then
        printf 'Usage: ssh-hostname <host>\n' >&2
        return 1
    fi

    _require_cmd '[ssh-hostname]' ssh || return 1
    ssh -G "$host" | awk '$1 == "hostname" { print $2; exit }'
}


# ==============================================================================
# SHELL HELPERS
# ==============================================================================

# Validate .bashrc syntax before reloading it.
rebash() {
    local bashrc="$HOME/.bashrc"

    if [[ ! -r "$bashrc" ]]; then
        _log_error rebash "cannot read $bashrc"
        return 1
    fi

    if bash -n "$bashrc"; then
        # shellcheck disable=SC1090
        source "$bashrc"
    else
        _log_error rebash '.bashrc has syntax errors; reload aborted'
        return 1
    fi
}


# ==============================================================================
# END
# ==============================================================================

