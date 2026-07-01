#!/usr/bin/env bash
#
# Install claude-forge skills into ~/.claude/skills/, honoring each skill's .skillignore.
#
# Copies skills/<name>/ into the Claude skills directory, dropping any file whose
# name matches a glob in that skill's .skillignore (e.g. AGENT.md, README.md).
# The .skillignore file itself and any .plans/ scratch directories are always
# excluded -- they have no runtime purpose.
#
# Usage:
#   ./install.sh <skill> [<skill>...]   install named skills
#   ./install.sh --all                  install every skill
#   ./install.sh --list                 list available skills
# Flags:
#   --dry-run        show what would be copied/skipped, write nothing
#   --force          overwrite an already-installed skill
#   --dest <path>    destination skills dir (default: ~/.claude/skills)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
SKILLS_DIR="$REPO_ROOT/skills"

DEST="${HOME}/.claude/skills"
ALL=0
LIST=0
DRY_RUN=0
FORCE=0
NAMES=()

while [ $# -gt 0 ]; do
    case "$1" in
        --all)     ALL=1 ;;
        --list)    LIST=1 ;;
        --dry-run) DRY_RUN=1 ;;
        --force)   FORCE=1 ;;
        --dest)    shift; DEST="${1:?--dest needs a path}" ;;
        -h|--help)
            sed -n '3,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
            exit 0 ;;
        -*)        echo "unknown flag: $1" >&2; exit 2 ;;
        *)         NAMES+=("$1") ;;
    esac
    shift
done

available_skills() {
    for d in "$SKILLS_DIR"/*/; do
        [ -f "${d}SKILL.md" ] || continue
        basename "$d"
    done | sort
}

# Print a skill's .skillignore glob patterns, one per line (comments/blanks stripped).
ignore_patterns() {
    local file="$1/.skillignore"
    [ -f "$file" ] || return 0
    while IFS= read -r line || [ -n "$line" ]; do
        line="${line#"${line%%[![:space:]]*}"}"   # ltrim
        line="${line%"${line##*[![:space:]]}"}"   # rtrim
        [ -z "$line" ] && continue
        case "$line" in \#*) continue ;; esac
        printf '%s\n' "$line"
    done < "$file"
}

# Echo "1" if the file (relpath, basename) should be excluded, else "0".
is_excluded() {
    local rel="$1" name="$2"; shift 2
    case "/$rel/" in */.plans/*) echo 1; return ;; esac
    [ "$name" = ".skillignore" ] && { echo 1; return; }
    local p
    for p in "$@"; do
        # shellcheck disable=SC2254
        case "$name" in $p) echo 1; return ;; esac
    done
    echo 0
}

mapfile -t AVAILABLE < <(available_skills)

contains() { local x; for x in "${@:2}"; do [ "$x" = "$1" ] && return 0; done; return 1; }

if [ "$LIST" -eq 1 ]; then
    echo "Available skills:"
    printf '  %s\n' "${AVAILABLE[@]}"
    exit 0
fi

if [ "$ALL" -eq 1 ]; then
    TARGETS=("${AVAILABLE[@]}")
elif [ "${#NAMES[@]}" -gt 0 ]; then
    TARGETS=("${NAMES[@]}")
else
    echo "Usage: install.sh <skill> [<skill>...] | --all | --list   [--dry-run] [--force] [--dest <path>]"
    echo
    echo "Available skills:"
    printf '  %s\n' "${AVAILABLE[@]}"
    exit 0
fi

for skill in "${TARGETS[@]}"; do
    if ! contains "$skill" "${AVAILABLE[@]}"; then
        echo "skip '$skill' - no such skill under skills/ (try --list)" >&2
        continue
    fi

    src_root="$SKILLS_DIR/$skill"
    dest_root="$DEST/$skill"
    mapfile -t patterns < <(ignore_patterns "$src_root")

    copy_list=()
    skip_list=()
    while IFS= read -r f; do
        rel="${f#"$src_root/"}"
        name="$(basename "$f")"
        if [ "$(is_excluded "$rel" "$name" "${patterns[@]+"${patterns[@]}"}")" = "1" ]; then
            skip_list+=("$rel")
        else
            copy_list+=("$rel")
        fi
    done < <(find "$src_root" -type f | sort)

    if [ "$DRY_RUN" -eq 1 ]; then
        echo "[dry-run] $skill -> $dest_root"
        echo "  would copy ${#copy_list[@]} file(s)"
        if [ "${#skip_list[@]}" -gt 0 ]; then
            joined="$(printf '%s, ' "${skip_list[@]}")"
            echo "  would skip: ${joined%, }  (per .skillignore)"
        fi
        continue
    fi

    if [ -d "$dest_root" ] && [ "$FORCE" -eq 0 ]; then
        echo "skip '$skill' - already installed at $dest_root (pass --force to overwrite)" >&2
        continue
    fi

    rm -rf "$dest_root"
    for rel in "${copy_list[@]}"; do
        target="$dest_root/$rel"
        mkdir -p "$(dirname "$target")"
        cp "$src_root/$rel" "$target"
    done

    echo "installed $skill -> $dest_root  (${#copy_list[@]} files, ${#skip_list[@]} skipped)"
done
