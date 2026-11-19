#!/usr/bin/env bash
# Keeps the reference repositories in related-repos/ (git-ignored) current.
# Runs on every container start (postStartCommand); safe to run again by hand.
#
#   related-repos/jellyfin           the server source (REST API, profiles)
#   related-repos/jellyfin-desktop   the current Qt client (player, keys)
#
# A missing repository is cloned; an existing one is fetched and, when it is
# on a clean branch with an upstream, fast-forwarded. Local work (changes, a
# detached HEAD, a diverged branch) is left alone with a warning. Nothing here
# fails the container start: offline, the repositories just stay as they are.
set -uo pipefail

workspace=$(cd "$(dirname "$0")/.." && pwd)
dest="$workspace/related-repos"

# HTTPS, not SSH: the container has no ssh client, and both are public.
declare -A repos=(
  [jellyfin]=https://github.com/jellyfin/jellyfin.git
  [jellyfin-desktop]=https://github.com/jellyfin/jellyfin-desktop.git
)

warn() { echo "related-repos: $*" >&2; }

# Before related-repos/ the repositories sat at the workspace root. Move such
# a copy instead of downloading it again (and losing any local branches).
migrate() {
  local name=$1 old="$workspace/$1"
  [ -d "$old/.git" ] || return 0
  if [ -e "$dest/$name" ]; then
    warn "$old is an old copy of related-repos/$name; delete it when you no longer need it."
  elif mountpoint -q "$old"; then
    warn "$old is still mounted by an older container; rebuild the container to move it."
    return 1
  else
    mv "$old" "$dest/$name" && echo "related-repos: moved $old to related-repos/$name"
  fi
}

update() {
  local name=$1 url=$2 dir="$dest/$1"
  if [ ! -d "$dir/.git" ]; then
    echo "related-repos: cloning $name"
    git clone --quiet "$url" "$dir" || warn "could not clone $url"
    return
  fi

  case "$(git -C "$dir" remote get-url origin 2>/dev/null)" in
    git@github.com:* | ssh://*) git -C "$dir" remote set-url origin "$url" ;;
  esac

  if ! git -C "$dir" fetch --quiet --prune origin; then
    warn "could not fetch $name (offline?); keeping it as it is."
    return
  fi

  local branch
  if ! branch=$(git -C "$dir" symbolic-ref --short -q HEAD); then
    warn "$name has a detached HEAD; fetched only."
    return
  fi
  if [ -n "$(git -C "$dir" status --porcelain --untracked-files=no)" ]; then
    warn "$name has local changes on $branch; fetched only."
    return
  fi
  if git -C "$dir" merge --quiet --ff-only '@{upstream}' 2>/dev/null; then
    echo "related-repos: $name ($branch) at $(git -C "$dir" log -1 --format='%h %cs')"
  else
    warn "$name: $branch has no upstream or has diverged from it; fetched only."
  fi
}

mkdir -p "$dest"
for name in "${!repos[@]}"; do
  migrate "$name" && update "$name" "${repos[$name]}"
done
exit 0
