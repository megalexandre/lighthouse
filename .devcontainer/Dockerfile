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
# Layers are ordered from "changes least" to "changes most":
# apt packages -> user -> Flutter SDK -> Flutter config. Changing a step
# rebuilds it and every step after it, but reuses the cached steps before it.

# Ubuntu's Docker image deletes downloaded .deb files after each install.
# Turn that off so the apt cache below can keep them between builds.
RUN rm -f /etc/apt/apt.conf.d/docker-clean \
    && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

# The two cache mounts keep the package lists and the .deb files outside
# the image, on the build machine. Adding one package to this list later
# downloads only that package, not all of them again.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
        # Basic tools (Flutter itself is fetched with curl and managed by git)
        bash ca-certificates curl git unzip xz-utils zip sudo \
        # Toolchain required by `flutter build linux`
        clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev \
        # media_kit_libs_linux builds mimalloc with a nested "Unix Makefiles" CMake
        make \
        # Video playback: libmpv is what media_kit uses under the hood;
        # mpv (the command-line player) lets you compare playback with the app;
        # the VAAPI libraries and vainfo are for hardware decoding
        libmpv-dev mpv libva-drm2 libva-x11-2 vainfo \
        # Desktop integration: secure token storage, D-Bus, MPRIS checks
        libsecret-1-dev libdbus-1-dev dbus-x11 playerctl pulseaudio-utils \
        # A keyring inside the container (keyring.sh); secret-tool to inspect it
        gnome-keyring libsecret-tools \
        # Backtraces of native crashes (core dumps)
        gdb \
        # Headless testing: run integration tests without a real screen
        xvfb xauth x11-utils \
        # Generates the test media in jellyfin-flutter/fixtures (tool/gen_fixtures.sh)
        ffmpeg \
        # AppImage packing (jellyfin-flutter/tool/build_appimage.sh):
        # appimagetool calls `file`
        file \
        # Runs the validators of the security-audit Claude Code skill
        # (installed in ~/.claude/skills, see .devcontainer/README.md)
        nodejs

# --- OpenCodeReview CLI (`ocr`) -----------------------------------------------
# Used by the open-code-review Claude Code skills (in ~/.claude/skills, see
# README.md). Only the native binary, from its npm platform package, at a
# pinned version checked against the tarball's SHA-512. Not through npm:
# the npm launcher (bin/ocr.js) auto-updates itself in the background
# (`npm i -g ...@latest`), which would undo the pin.
ARG OCR_VERSION=1.13.10
ARG OCR_SHA512=5dd864f8a4ed71f2eabff5a998612e7c41ebbc21fadce56d3572cb791132ca357f4eda97e55e7b30c060b73cf975eac82ef7e5838df629bcbed490f6f770730d
RUN curl -fsSL -o /tmp/ocr.tgz \
        "https://registry.npmjs.org/@alibaba-group/ocr-linux-x64/-/ocr-linux-x64-${OCR_VERSION}.tgz" \
    && echo "${OCR_SHA512}  /tmp/ocr.tgz" | sha512sum --check --quiet \
    && tar -xzf /tmp/ocr.tgz -C /tmp package/bin/opencodereview \
    && install -m 0755 /tmp/package/bin/opencodereview /usr/local/bin/ocr \
    && rm -rf /tmp/ocr.tgz /tmp/package

# --- Non-root user "dev" ----------------------------------------------------
# ubuntu:24.04 ships a user "ubuntu" with uid/gid 1000. Remove it first so
# its ids never clash with yours, then create "dev" with your host ids.
RUN userdel --remove ubuntu \
    && groupadd --gid "${USER_GID}" dev \
    && useradd --uid "${USER_UID}" --gid "${USER_GID}" --create-home --shell /bin/bash dev \
    && echo "dev ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/dev \
    && chmod 0440 /etc/sudoers.d/dev \
    # Empty folder for the SDK, owned by dev (filled in the next step).
    && install -d -o dev -g dev /opt/flutter \
    # Mount points for the named volumes in docker-compose.yml. A new volume
    # copies the owner of the folder it mounts over; without these folders
    # it would be owned by root and dev could not write to it.
    && install -d -o dev -g dev /home/dev/.pub-cache /home/dev/.claude

USER dev
WORKDIR /workspace

# --- Flutter SDK ------------------------------------------------------------
# Downloaded as "dev", so the files are owned by dev from the start.
# Why it matters: each RUN is saved as an image layer. Changing the owner
# later (chown -R) would store a second full copy of the SDK (~2.7 GB).
RUN curl -fsSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
        | tar -xJ -C /opt

# Configure Flutter once, at build time, and pre-download the Linux desktop
# artifacts so the first `flutter run` does not have to.
RUN flutter config --no-analytics --enable-linux-desktop --no-enable-web \
    && flutter precache --linux

CMD ["sleep", "infinity"]
