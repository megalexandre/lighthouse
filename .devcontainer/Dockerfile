# Image for the "app" container: everything needed to build and run
# the Flutter rewrite of Jellyfin Desktop on Linux.
FROM ubuntu:24.04

# Pinned on purpose. Bump it deliberately, never implicitly.
ARG FLUTTER_VERSION=3.50.0

# Filled from .devcontainer/.env (see initialize.sh).
ARG USER_UID=1000
ARG USER_GID=1000

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=/opt/flutter/bin:${PATH}

# --- System packages --------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
        # Basic tools (Flutter itself is fetched with curl and managed by git)
        bash ca-certificates curl git unzip xz-utils zip sudo \
        # Toolchain required by `flutter build linux`
        clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev \
        # Video playback: libmpv is what media_kit uses under the hood;
        # the VAAPI libraries and vainfo are for hardware decoding
        libmpv-dev mpv libva-drm2 libva-x11-2 vainfo mesa-utils \
        # Desktop integration: secure token storage, D-Bus, MPRIS checks
        libsecret-1-dev libdbus-1-dev dbus-x11 playerctl pulseaudio-utils \
        # Headless testing: run integration tests without a real screen
        xvfb xauth x11-utils \
    && rm -rf /var/lib/apt/lists/*

# --- Flutter SDK ------------------------------------------------------------
RUN curl -fsSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
        | tar -xJ -C /opt \
    # The SDK is a git checkout owned by another user; tell git that is fine.
    && git config --system --add safe.directory '*'

# --- Non-root user "dev" ----------------------------------------------------
# ubuntu:24.04 ships a user "ubuntu" with uid/gid 1000. Remove it first so
# its ids never clash with yours, then create "dev" with your host ids.
RUN userdel --remove ubuntu \
    && groupadd --gid "${USER_GID}" dev \
    && useradd --uid "${USER_UID}" --gid "${USER_GID}" --create-home --shell /bin/bash dev \
    && echo "dev ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/dev \
    && chmod 0440 /etc/sudoers.d/dev \
    && chown -R dev:dev /opt/flutter

USER dev
WORKDIR /workspace

# Configure Flutter once, at build time, and pre-download the Linux desktop
# artifacts so the first `flutter run` does not have to.
RUN flutter config --no-analytics --enable-linux-desktop --no-enable-web \
    && flutter precache --linux

CMD ["sleep", "infinity"]
