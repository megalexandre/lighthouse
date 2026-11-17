#!/usr/bin/env bash
# Runs a command holding the Linux build lock:
#
#   tool/with_build_lock.sh flutter build linux --release
#
# Every Flutter Linux build (release, profile, the debug one the
# integration tests make) copies its engine into one shared place,
# linux/flutter/ephemeral/. Two at once mix them up: a release bundle can
# end up with the debug engine and not start ("Not running in AOT mode").
# Builds that take this lock wait for each other instead.
#
# A script can take it for its whole run instead: source this file with no
# arguments (see tool/build_appimage.sh).
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$root/build"
exec 9>"$root/build/.linux-build.lock"
if ! flock -n 9; then
  echo "Waiting for another Flutter Linux build (tests, AppImage) to finish..." >&2
  flock 9
fi
# Sourced: the caller keeps the lock until it exits. Run: run the command.
if [[ "${BASH_SOURCE[0]}" == "$0" ]] && (($#)); then
  "$@"
fi
