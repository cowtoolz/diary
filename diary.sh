#!/usr/bin/env sh
DIARY_VERSION="1.0"
set -eu

log() {
    level=$1
    fmt=$2
    shift 2
    case $level in
        info)  prefix="\033[32m[INFO]\033[0m" ;;
        warn)  prefix="\033[33m[WARN]\033[0m" ;;
        fatal) prefix="\033[31m[ERR!]\033[0m" ;;
        *)     exit 1 ;;
    esac
    # shellcheck disable=SC2059
    printf "$prefix $fmt\n" "$@" >&2
    if [ "$level" = "fatal" ]; then
        exit 1
    fi
}

tildify() {
    # shellcheck disable=SC2295
    case "$1" in
        "$HOME"*) printf "%s" "~${1#$HOME}" ;;
        *)        printf "%s" "$1" ;;
    esac
}

# usage
if [ $# -gt 0 ]; then
    log warn "This program takes no positional arguments."
    log warn "See \`man diary\` for configuration information."
    log info "diary %s, copyright (c) 2026 W. Turner Abney, Licensed BSD-2-Clause." "$DIARY_VERSION"
    log info "See https://github.com/cowtoolz/diary for details."
    exit 1
fi

CURRENT_CONFIG_VERSION=${DIARY_VERSION%%.*}
DEFAULT_CONFIG=$(
    cat << 'EOF'
ENTRY_PATH="$(date '+%Y/%m/%d').md"
PREFILL="# $(date '+%A %d %B, %Y %I:%M %p')\n\n"
PREFILL_EDIT=""
USE_EDITOR=true
EOF
)

# setup journal directory
if [ "${DIARY_DIR:+x}" = "" ]; then
    # default
    DIARY_DIR="$HOME/diary"
fi
DIARY_CONF="$DIARY_DIR/diary.conf"
if [ ! -f "$DIARY_CONF" ]; then
    log warn "Initializing journal at %s" "$(tildify "$DIARY_DIR")"
    mkdir -p "$DIARY_DIR"

    # env with defaults
    cat > "$DIARY_CONF" << EOF
# diary config
# See \`man diary\` for configuration information.
CONFIG_VERSION=$CURRENT_CONFIG_VERSION

$(printf '%s\n' "$DEFAULT_CONFIG" | sed 's/^/# /')

# EDITOR=nano
# HOOK='echo done editing'
EOF

    log info "Created config %s" "$(tildify "$DIARY_CONF")"
fi

# load config
eval "$DEFAULT_CONFIG"
if [ -f "$DIARY_CONF" ]; then
    # shellcheck source=/dev/null
    . "$DIARY_CONF"
fi
if [ "${EDITOR:+x}" = "" ]; then
    if [ "$USE_EDITOR" = true ]; then
        log warn "You can set the EDITOR command in %s/diary.conf" "$(tildify "$DIARY_DIR")"
        log warn "EDITOR is unset! Set this environment variable to edit new entries"
    fi
    USE_EDITOR=false
fi

# version check, for future use
if [ "$CONFIG_VERSION" != "$CURRENT_CONFIG_VERSION" ]; then
    log fatal "Config version in %s (%s) is incompatible with installed diary version (%s)" \
    "$DIARY_CONF" "$CONFIG_VERSION" "$DIARY_VERSION"
fi

# create journal entry
cd "$DIARY_DIR" || log fatal "DIARY_DIR (%s) does not exist" "$DIARY_DIR"
ENTRY="$DIARY_DIR/$ENTRY_PATH"
ENTRY_DIR=$(dirname "$ENTRY")
mkdir -p "$ENTRY_DIR"
EDIT_MESSAGE="Created new entry %s"
if [ -f "$ENTRY_PATH" ]; then
    EDIT_MESSAGE="Edited entry %s"
    PREFILL="$PREFILL_EDIT"
fi
printf "%b" "$PREFILL" >> "$ENTRY"

# start writing
if [ "$USE_EDITOR" = true ]; then
    $EDITOR "$ENTRY" || log fatal "Failed to open entry with EDITOR! (%s %s)" "$EDITOR" "$ENTRY"
    if [ "${HOOK:+x}" != "" ]; then
        eval "$HOOK" || log fatal "Error evaluating HOOK! (%s)" "$HOOK"
    fi
fi

log info "$EDIT_MESSAGE" "$(tildify "$ENTRY")"
