#!/usr/bin/env bash
# Builds the release app and packs it as an AppImage:
#   build/JellyfinFlutter-<version>-x86_64.AppImage
#
# One file that runs on most x86_64 Linux desktops: it carries the Flutter
# bundle and the libraries it needs that a desktop may lack (libmpv and
# its ffmpeg, among others). linuxdeploy decides which: glibc, the GPU
# drivers and other parts that must come from the host are left out.
#
#   tool/build_appimage.sh            build, pack, smoke-test
#   tool/build_appimage.sh --no-build pack the existing release bundle
#
# linuxdeploy is downloaded once (pinned version, checked against its
# SHA-256) into ${XDG_CACHE_HOME:-~/.cache}/jellyfin-flutter/tools.
set -euo pipefail
cd "$(dirname "$0")/.."

LINUXDEPLOY_VERSION=1-alpha-20251107-1
# Recorded when the version was pinned; upstream publishes no checksums.
LINUXDEPLOY_SHA256=c20cd71e3a4e3b80c3483cef793cda3f4e990aca14014d23c544ca3ce1270b4d

app_id=org.jellyfin.jellyfin_flutter
binary=jellyfin_flutter
version=$(sed -n 's/^version: *\([^+]*\).*/\1/p' pubspec.yaml)
bundle=build/linux/x64/release/bundle
appdir=build/appimage/AppDir
output=build/JellyfinFlutter-$version-x86_64.AppImage
tools="${XDG_CACHE_HOME:-$HOME/.cache}/jellyfin-flutter/tools"

step() { printf '\n\033[1;35m== %s\033[0m\n' "$*"; }

if [[ "${1:-}" != "--no-build" ]]; then
  step "Release build"
  flutter build linux --release
fi
[[ -x "$bundle/$binary" ]] || { echo "No release bundle at $bundle." >&2; exit 1; }

step "linuxdeploy $LINUXDEPLOY_VERSION"
linuxdeploy="$tools/linuxdeploy-$LINUXDEPLOY_VERSION-x86_64.AppImage"
if [[ ! -x "$linuxdeploy" ]]; then
  mkdir -p "$tools"
  curl -fSL --retry 3 -o "$linuxdeploy.part" \
    "https://github.com/linuxdeploy/linuxdeploy/releases/download/$LINUXDEPLOY_VERSION/linuxdeploy-x86_64.AppImage"
  echo "$LINUXDEPLOY_SHA256  $linuxdeploy.part" | sha256sum --check --quiet
  chmod +x "$linuxdeploy.part"
  mv "$linuxdeploy.part" "$linuxdeploy"
fi
# No FUSE in containers and CI: AppImages run extracted.
export APPIMAGE_EXTRACT_AND_RUN=1

step "AppDir"
rm -rf "$appdir"
mkdir -p "$appdir/usr/bin"
# The Flutter bundle keeps its layout (lib/, data/ next to the binary):
# the engine finds libapp.so and the assets relative to the executable.
cp -a "$bundle/." "$appdir/usr/bin/"

libraries=()
for lib in "$appdir"/usr/bin/lib/*.so; do libraries+=(--library "$lib"); done

step "AppImage"
rm -f "$output"
LDAI_OUTPUT="$output" "$linuxdeploy" \
  --appdir "$appdir" \
  --executable "$appdir/usr/bin/$binary" \
  "${libraries[@]}" \
  --desktop-file "linux/packaging/$app_id.desktop" \
  --icon-file "linux/packaging/$app_id.png" \
  --output appimage

step "Smoke test: the AppImage starts"
# It must get as far as writing its log: Dart code running, plugins and
# libmpv loaded. A missing library would stop it before that.
logs=$(mktemp -d)
trap 'rm -rf "$logs"' EXIT
XDG_DATA_HOME="$logs" timeout 20 xvfb-run -a "$output" >/dev/null 2>&1 || true
if ! grep -q 'starting' "$logs/jellyfin-flutter/logs/app.log" 2>/dev/null; then
  echo "The AppImage did not start (no log written)." >&2
  exit 1
fi
grep -m1 'starting' "$logs/jellyfin-flutter/logs/app.log"

step "OK: $output ($(du -h "$output" | cut -f1))"
