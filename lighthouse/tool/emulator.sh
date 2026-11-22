#!/usr/bin/env bash
# The Android emulator, inside the dev container:
#
#   tool/emulator.sh              starts it in a window, waits until it is up
#   tool/emulator.sh --headless   the same without a window (tests, screenshots)
#   tool/emulator.sh stop         turns it off
#
# Anything else goes to the emulator as it is, e.g. `-wipe-data`, or
# `-gpu swiftshader` where the window has no GPU (or draws badly).
# The first start makes the device (kept in ~/.android, a volume).
# Then: flutter run -d emulator-5554
#
#   LIGHTHOUSE_AVD      the device's name   default: lighthouse
#   LIGHTHOUSE_DEVICE   its hardware        default: pixel_7 (a tablet:
#                       pixel_tablet; `avdmanager list device` lists them)
set -euo pipefail

avd="${LIGHTHOUSE_AVD:-lighthouse}"
device="${LIGHTHOUSE_DEVICE:-pixel_7}"
image='system-images;android-36;google_apis;x86_64' # also in the Dockerfile
port=5554
serial="emulator-$port"
boot_timeout=300
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
log="$root/build/emulator.log"

fail() {
  echo "$*" >&2
  exit 1
}

# This script's emulator lives in the container, and so must its adb server.
unset ADB_SERVER_SOCKET

if [[ "${1:-}" == stop ]]; then
  exec adb -s "$serial" emu kill
fi

command -v emulator > /dev/null ||
  fail 'No emulator in this container: run "Rebuild Container".'
[[ -e /dev/kvm ]] ||
  fail 'No /dev/kvm here. The host needs KVM, with access for your user, and then a "Rebuild Container": see .devcontainer/README.md, "Android".'
[[ -r /dev/kvm && -w /dev/kvm ]] ||
  fail '/dev/kvm is here but closed to you. On the host: sudo setfacl -m "u:$USER:rw" /dev/kvm (until the next boot).'

headless=false
extra=()
for arg in "$@"; do
  if [[ "$arg" == --headless ]]; then headless=true; else extra+=("$arg"); fi
done

if adb devices | grep -q "^$serial[[:space:]]"; then
  echo "$serial is already running."
  exit 0
fi

# Never `-gpu auto`: in this container it falls back to ANGLE over SwiftShader
# ("swangle"), and the emulator (37.3.10) dies of an illegal instruction as
# soon as Flutter draws.
if $headless; then
  args=(-no-window -no-audio -gpu swiftshader)
else
  # The emulator's Qt speaks only X11 (XWayland, on a Wayland desktop).
  xdpyinfo > /dev/null 2>&1 ||
    fail 'The X11 display refuses this container. On the host, once per session: xhost +SI:localuser:$USER (or use --headless).'
  export QT_QPA_PLATFORM=xcb
  args=(-gpu host)
fi

if ! emulator -list-avds | grep -qx "$avd"; then
  echo "Making the device \"$avd\" ($device)..."
  echo no | avdmanager --silent create avd --name "$avd" --package "$image" --device "$device"
fi
avd_dir="${ANDROID_AVD_HOME:-$HOME/.android/avd}/$avd.avd"
# The PC's keyboard types in the app.
sed -i '/^hw\.keyboard *=/d' "$avd_dir/config.ini"
echo 'hw.keyboard=yes' >> "$avd_dir/config.ini"
# Left behind when the container is stopped with the emulator on. Nothing
# else uses the device: it would be $serial, which is not running.
pgrep -f "qemu-system.*$avd" > /dev/null || rm -rf "$avd_dir"/*.lock

mkdir -p "$root/build"
echo "Starting $serial (log: $log)..."
# Its own session: closing the terminal does not turn the device off.
setsid emulator -avd "$avd" -port "$port" -memory 3072 -no-boot-anim \
  -no-snapshot "${args[@]}" "${extra[@]}" > "$log" 2>&1 < /dev/null &
pid=$!

deadline=$((SECONDS + boot_timeout))
until [[ "$(adb -s "$serial" shell getprop sys.boot_completed 2> /dev/null | tr -d '\r')" == 1 ]]; do
  kill -0 "$pid" 2> /dev/null || {
    tail -20 "$log" >&2
    fail 'The emulator closed before it was up.'
  }
  ((SECONDS < deadline)) || fail "Not up after $boot_timeout s; see $log."
  sleep 2
done

echo "Up. flutter run -d $serial"
# The service names resolve only on the compose network: the address too, in
# case the emulator's DNS does not know them.
for url in "${JELLYFIN_URL:-}" "${JELLYFIN_TEST_URL:-}"; do
  [[ -n "$url" ]] || continue
  host="${url#*://}"
  host="${host%%[:/]*}"
  ip="$(getent ahostsv4 "$host" | awk 'NR == 1 { print $1 }' || true)"
  echo "Server: $url${ip:+  (or ${url/$host/$ip})}"
done
