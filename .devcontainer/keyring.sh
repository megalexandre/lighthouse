#!/usr/bin/env bash
# Starts a D-Bus session bus and an unlocked keyring (gnome-keyring) inside
# the container, for the app's secure storage (libsecret). Runs on every
# container start (postStartCommand); safe to run again by hand.
#
# Why: the host's session bus is mounted in (/run/user/<uid>/bus) but
# Docker's AppArmor profile denies the container access to it, so the app
# cannot reach the desktop keyring. DBUS_SESSION_BUS_ADDRESS (set in
# docker-compose.yml) points every process in the container at this bus
# instead.
#
# The keyring lives in the container (~/.local/share/keyrings): a rebuild
# empties it and you sign in to the app again. Its password is "dev"; it
# only ever holds development logins.
set -euo pipefail

dir=/tmp/jellyfin-dev-dbus
export DBUS_SESSION_BUS_ADDRESS="unix:path=$dir/bus"

bus_call() { # METHOD [ARG] -> succeeds when the bus answers
  dbus-send --session --print-reply --dest=org.freedesktop.DBus \
    /org/freedesktop/DBus "org.freedesktop.DBus.$1" ${2:+"$2"} 2>/dev/null
}

if ! bus_call GetId >/dev/null; then
  mkdir -p "$dir"
  chmod 700 "$dir"
  rm -f "$dir/bus"
  dbus-daemon --session --address="$DBUS_SESSION_BUS_ADDRESS" --fork --nopidfile
fi

if ! bus_call NameHasOwner string:org.freedesktop.secrets | grep -q 'boolean true'; then
  # Its control socket goes to $XDG_RUNTIME_DIR/keyring. That directory is
  # the host's (mounted in) and holds the desktop's own keyring socket, so
  # give the daemon a private one.
  printf 'dev' | XDG_RUNTIME_DIR="$dir" \
    gnome-keyring-daemon --daemonize --unlock --components=secrets >/dev/null
fi

echo "Keyring ready on $DBUS_SESSION_BUS_ADDRESS"
