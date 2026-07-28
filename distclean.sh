#!/usr/bin/env bash
# distclean.sh -- rabs: make-rules library (no build outputs of its own)
#
# Removes every generated build artifact, leaving a source-only checkout.
#
#   ./distclean.sh        remove artifacts
#   ./distclean.sh -n     dry run: list what would be removed
#
# A path that is, or contains, a git-tracked file is never removed (it is
# reported as "skipped (tracked)"), so `git status` stays clean afterwards.
set -uo pipefail

DRY=0
while [ $# -gt 0 ]; do
    case "$1" in
        -n|--dry-run) DRY=1 ;;
        -h|--help)    awk 'NR>1{if (/^#/) {sub(/^# ?/,""); print} else exit}' "$0" ; exit 0 ;;
        *) echo "distclean: unknown option '$1'" >&2; exit 2 ;;
    esac
    shift
done

# Always operate on this script's own (physical) directory, not the caller's cwd.
cd "$(cd -P "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd -P)" || exit 1

_removed=0
_tracked=
has_tracked() {          # 0 if $1 is, or contains, a git-tracked file
    local p="${1#./}"
    [ -n "$_tracked" ] || _tracked="|$(git ls-files 2>/dev/null | tr '\n' '|')"
    case "$_tracked" in
        *"|$p|"*|*"|$p/"*) return 0 ;;
    esac
    return 1
}
rmrf() {                 # rmrf <path|glob>...  -- unmatched globs are skipped
    local p
    for p in "$@"; do
        [ -e "$p" ] || [ -L "$p" ] || continue
        if has_tracked "$p"; then printf '  skipped (tracked)  %s\n' "$p"; continue; fi
        if [ "$DRY" = 1 ]; then
            printf '  would remove  %s\n' "$p"
        else
            rm -rf -- "$p" || { printf '  FAILED  %s\n' "$p" >&2; continue; }
            printf '  removed  %s\n' "$p"
        fi
        _removed=$((_removed + 1))
    done
}
summary() {              # summary <label>
    if [ "$DRY" = 1 ]; then printf 'distclean(%s): %d path(s) would be removed\n' "$1" "$_removed"
    else printf 'distclean(%s): %d path(s) removed\n' "$1" "$_removed"
    fi
}

echo "distclean: rabs (app/mk)  ($PWD)"

# rabs only ships makefiles/scripts; anything below is editor/python cruft.
rmrf __pycache__ */__pycache__ script/__pycache__ .DS_store
rmrf *.log *.jou *.str

summary rabs
