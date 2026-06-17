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
# COMMON HELPERS
# ==============================================================================

# require a command to be available in PATH
_require_cmd() {
    local error_prefix="$1"
    local command_name="$2"

    command -v "$command_name" >/dev/null 2>&1 || {
        printf '%s missing dependency: %s\n' "$error_prefix" "$command_name" >&2
        return 1
    }
}

# return first available command from list
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
            _require_cmd "[extract]" tar || return 1
            tar -xzf "../$archive_path"
            status=$?
            ;;

        *.tar.bz2|*.tbz2)
            _require_cmd "[extract]" tar || return 1
            tar -xjf "../$archive_path"
            status=$?
            ;;

        *.tar.xz)
            _require_cmd "[extract]" tar || return 1
            tar -xJf "../$archive_path"
            status=$?
            ;;

        *.tar.zst|*.tzst)
            _require_cmd "[extract]" tar || return 1
            tar --zstd -xf "../$archive_path"
            status=$?
            ;;

        *.tar)
            _require_cmd "[extract]" tar || return 1
            tar -xf "../$archive_path"
            status=$?
            ;;

        *.zip)
            _require_cmd "[extract]" unzip || return 1
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
            _require_cmd "[extract]" 7z || return 1
            7z x -bd -y "../$archive_path" >/dev/null
            status=$?
            ;;

        *.gz)
            _require_cmd "[extract]" gunzip || return 1
            gunzip -k "../$archive_path"
            status=$?
            ;;

        *.bz2)
            _require_cmd "[extract]" bunzip2 || return 1
            bunzip2 -k "../$archive_path"
            status=$?
            ;;

        *.xz)
            _require_cmd "[extract]" unxz || return 1
            unxz -k "../$archive_path"
            status=$?
            ;;

        *.zst)
            _require_cmd "[extract]" unzstd || return 1
            unzstd -k "../$archive_path"
            status=$?
            ;;

        *)
            case "$mime_type" in
                application/zip)
                    _require_cmd "[extract]" unzip || return 1
                    unzip -qq -o "../$archive_path"
                    status=$?
                    ;;

                application/x-tar)
                    _require_cmd "[extract]" tar || return 1
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

# render a mermaid diagram (.mmd, or stdin via "-") to svg/png via docker
render-mermaid() {
    local input_file="${1:-}"
    local image="felixlohmeier/mermaid"
    local input_dir
    local input_name
    local tmp_dir=""
    local caller_dir="$PWD"
    local status

    # --------------------------------------------------------------------------
    # Validation
    # --------------------------------------------------------------------------
    if [[ -z "$input_file" ]]; then
        echo "[render-mermaid] usage: render-mermaid <file.mmd|-> [mermaid-cli-args...]" >&2
        return 1
    fi

    if [[ "$input_file" != "-" && ! -f "$input_file" ]]; then
        echo "[render-mermaid] file does not exist: $input_file" >&2
        return 1
    fi

    _require_cmd "[render-mermaid]" docker || return 1

    # --------------------------------------------------------------------------
    # Pull image if missing locally (commented out to avoid unnecessary network calls)
    # --------------------------------------------------------------------------
    # if ! docker image inspect -- "$image" >/dev/null 2>&1; then
    #     echo "[render-mermaid] image not found locally, pulling $image..." >&2
    #     if ! docker pull -- "$image"; then
    #         echo "[render-mermaid] failed to pull image: $image" >&2
    #         return 1
    #     fi
    # fi

    # --------------------------------------------------------------------------
    # Resolve input: "-" reads stdin into a temp dir, otherwise use the file as-is
    # --------------------------------------------------------------------------
    if [[ "$input_file" == "-" ]]; then
        tmp_dir="$(mktemp -d)" || {
            echo "[render-mermaid] failed to create temp directory" >&2
            return 1
        }
        input_dir="$tmp_dir"
        input_name="stdin.mmd"
        if ! cat > "$input_dir/$input_name"; then
            echo "[render-mermaid] failed to read stdin" >&2
            rm -rf "$tmp_dir"
            return 1
        fi
    else
        input_dir="$(dirname -- "$input_file")"
        input_name="$(basename -- "$input_file")"
    fi

    shift

    pushd "$input_dir" >/dev/null || {
        echo "[render-mermaid] failed to enter directory: $input_dir" >&2
        [[ -n "$tmp_dir" ]] && rm -rf "$tmp_dir"
        return 1
    }

    # --------------------------------------------------------------------------
    # Render (mounts the input's directory as /data)
    # --------------------------------------------------------------------------
    docker run --rm -v "$PWD":/data:z "$image" -s -p "$@" "$input_name"
    status=$?

    popd >/dev/null || true

    # --------------------------------------------------------------------------
    # When using stdin, move rendered output back to the caller's directory
    # --------------------------------------------------------------------------
    if [[ -n "$tmp_dir" ]]; then
        local base="${input_name%.*}"
        local f
        for f in "$tmp_dir/$base".*; do
            [[ -f "$f" && "$f" != "$tmp_dir/$input_name" ]] && mv -- "$f" "$caller_dir/"
        done
        rm -rf "$tmp_dir"
    fi

    if [[ $status -ne 0 ]]; then
        echo "[render-mermaid] render failed: $input_file" >&2
        return "$status"
    fi

    return 0
}

# ==============================================================================
# DOCKER HELPERS
# ==============================================================================

# stream a local image to a remote host over ssh (gzip-compressed)
docker-push-host() {
    local image="${1:-}"
    local host="${2:-}"
    local compress_cmd
    local status

    # --------------------------------------------------------------------------
    # Optional progress stream (uses pv when available)
    # --------------------------------------------------------------------------
    _progress_pipe() {
        local tar_size
    
        if ! command -v pv >/dev/null 2>&1; then
            cat
            return 0
        fi
    
        # docker save produces a tar archive that is larger than the raw image
        # size reported by inspect; measure the actual stream size up front so
        # that the progress bar never exceeds 100 %.
        tar_size="$(docker save -- "$image" 2>/dev/null | wc -c)"
        if [[ "$tar_size" =~ ^[0-9]+$ && "$tar_size" -gt 0 ]]; then
            pv -p -f -s "$tar_size" -N "push $image"
        else
            pv -p -f -N "push $image"
        fi
    }

    # --------------------------------------------------------------------------
    # Validation
    # --------------------------------------------------------------------------
    if [[ -z "$image" || -z "$host" ]]; then
        echo "[docker-push-host] usage: docker-push-host <image> <host>" >&2
        return 1
    fi

    _require_cmd "[docker-push-host]" docker || return 1
    _require_cmd "[docker-push-host]" ssh || return 1
    compress_cmd="$(_require_any_cmd "[docker-push-host]" gzip gz)" || return 1

    if ! docker image inspect -- "$image" >/dev/null 2>&1; then
        echo "[docker-push-host] image not found locally: $image" >&2
        return 1
    fi

    # --------------------------------------------------------------------------
    # Push pipeline: save | [pv] | compress | ssh | decompress | load
    # --------------------------------------------------------------------------
    if ! (
        set -o pipefail
        docker save -- "$image" \
            | _progress_pipe \
            | "$compress_cmd" -c \
            | ssh -C "$host" 'gzip -dc | docker load'
    ); then
        status=$?
        echo "[docker-push-host] failed to push image: $image -> $host" >&2
        return "$status"
    fi

    return 0
}

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
# NETWORK HELPERS
# ==============================================================================

# print resolved hostname from ssh config for a host alias
ssh-hostname() {
    local host="${1:-}"

    if [[ -z "$host" ]]; then
        echo "Usage: ssh-hostname <host>"
        return 1
    fi

    ssh -G "$host" | awk '/^hostname / {print $2}'
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
