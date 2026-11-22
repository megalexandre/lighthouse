# Image for the "app" container: everything needed to build and run
# the Flutter rewrite of Jellyfin Desktop on Linux, and to build it for
# Android, emulator included (it needs the host's /dev/kvm: see README.md).
#
# Four stages. "flutter", "android" and "emulator" download the SDKs on their
# own, with only the few packages they need, so they never depend on the apt
# list below: adding a system package later reuses the cached SDKs (local
# copies) instead of downloading ~3 GB and ~4 GB again.

# --- Stage 1: Flutter SDK ---------------------------------------------------
FROM ubuntu:24.04 AS flutter

# Pinned on purpose. Bump it deliberately, never implicitly.
# Declared here, in this stage only: a build arg in scope is part of the cache
# key of every RUN after it, so bumping it must not re-run the apt step below.
ARG FLUTTER_VERSION=3.50.0

ENV PATH=/opt/flutter/bin:${PATH}

# What the flutter tool itself needs to unpack and precache.
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl git unzip xz-utils \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
        | tar -xJ -C /opt

# Pre-download the Linux and Android artifacts so the first `flutter run` does
# not have to. They land in /opt/flutter/bin/cache and travel with the COPY
# below. (Run as root here, hence its super-user warning; harmless.)
RUN git config --global --add safe.directory /opt/flutter \
    && flutter precache --linux --android

# --- Stage 2: Android SDK ---------------------------------------------------
FROM ubuntu:24.04 AS android

# The command-line tools (sdkmanager), pinned and checked like the Flutter SDK.
# Google's repository (repository2-3.xml) lists each version's SHA-1; this is
# the SHA-256 of that same zip. 15859902 is version 22.0.
ARG ANDROID_CMDLINE_TOOLS=15859902
ARG ANDROID_CMDLINE_TOOLS_SHA256=4e4c464f145a7512b57d088ac6c278c03c9eea610886b35a5e0804e74eedf583

# sdkmanager is Java. 17: what the Android Gradle Plugin runs on.
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl unzip openjdk-17-jdk-headless \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /tmp/tools.zip \
        "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMDLINE_TOOLS}_latest.zip" \
    && echo "${ANDROID_CMDLINE_TOOLS_SHA256}  /tmp/tools.zip" | sha256sum --check --quiet \
    && unzip -q /tmp/tools.zip -d /tmp/tools \
    && mkdir -p /opt/android-sdk/cmdline-tools \
    && mv /tmp/tools/cmdline-tools /opt/android-sdk/cmdline-tools/latest \
    && rm -rf /tmp/tools /tmp/tools.zip

# What Flutter 3.50 builds with (FlutterExtension.kt): compileSdk and
# targetSdk 36, that exact NDK (native plugins: media_kit, pdfrx). CMake 3.22.1
# is the Android Gradle Plugin's default, for pdfrx's native part. Platform 35:
# a plugin still compiles against it, and Gradle would otherwise install it
# into the image's SDK, lost on the next rebuild. Bump these with Flutter.
# platform-tools (adb) has no pinned versions: the latest.
RUN yes | /opt/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/opt/android-sdk --licenses > /dev/null \
    && /opt/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/opt/android-sdk \
        "platform-tools" \
        "platforms;android-36" \
        "platforms;android-35" \
        "build-tools;36.0.0" \
        "ndk;28.2.13676358" \
        "cmake;3.22.1"

# --- Stage 3: Android emulator ----------------------------------------------
# On its own, so a new emulator or system image does not download the SDK
# again. x86_64, the host's own architecture: KVM runs it at full speed.
# The emulator has no pinned versions: the latest. The system image's name
# is also in lighthouse/tool/emulator.sh.
FROM android AS emulator

RUN /opt/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/opt/android-sdk \
        "emulator" \
        "system-images;android-36;google_apis;x86_64"

# --- Stage 4: the dev image -------------------------------------------------
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=/opt/flutter/bin:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/emulator:${PATH}

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
        # Basic tools (Flutter itself is managed by git)
        bash ca-certificates curl git unzip xz-utils zip sudo \
        # Android builds: Gradle and the Android Gradle Plugin run on Java 17
        openjdk-17-jdk-headless \
        # ssh client for git over ssh. No keys in the image: VS Code forwards
        # the host's ssh-agent (SSH_AUTH_SOCK).
        openssh-client \
        # Toolchain required by `flutter build linux`
        clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev \
        # media_kit_libs_linux builds mimalloc with a nested "Unix Makefiles" CMake
        make \
        # Video playback: libmpv is what media_kit uses under the hood;
        # mpv (the command-line player) lets you compare playback with the app;
        # the VAAPI libraries and vainfo are for hardware decoding
        libmpv-dev mpv libva-drm2 libva-x11-2 vainfo \
        # eglinfo/glxinfo: which GPU driver the app renders with; `flutter
        # doctor` reads eglinfo for its Linux toolchain line
        mesa-utils-bin \
        # Desktop integration: secure token storage, D-Bus, MPRIS checks
        libsecret-1-dev libdbus-1-dev dbus-x11 playerctl pulseaudio-utils \
        # A keyring inside the container (keyring.sh); secret-tool to inspect it
        gnome-keyring libsecret-tools \
        # Backtraces of native crashes (core dumps)
        gdb \
        # Headless testing: run integration tests without a real screen
        xvfb xauth x11-utils \
        # Generates the test media in lighthouse/fixtures (tool/gen_fixtures.sh)
        ffmpeg \
        # AppImage packing (lighthouse/tool/build_appimage.sh):
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
# Filled from .devcontainer/.env (see initialize.sh). Declared here, not at
# the top, so they are not part of the cache key of the steps above.
ARG USER_UID=1000
ARG USER_GID=1000

# ubuntu:24.04 ships a user "ubuntu" with uid/gid 1000. Remove it first so
# its ids never clash with yours, then create "dev" with your host ids.
RUN userdel --remove ubuntu \
    && groupadd --gid "${USER_GID}" dev \
    && useradd --uid "${USER_UID}" --gid "${USER_GID}" --create-home --shell /bin/bash dev \
    && echo "dev ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/dev \
    && chmod 0440 /etc/sudoers.d/dev \
    # Mount points for the named volumes in docker-compose.yml. A new volume
    # copies the owner of the folder it mounts over; without these folders
    # it would be owned by root and dev could not write to it.
    && install -d -o dev -g dev /home/dev/.pub-cache /home/dev/.gradle /home/dev/.claude /home/dev/.android

# --- Flutter SDK ------------------------------------------------------------
# Copied from stage 1, owned by dev in the same step. Why it matters: each
# step is saved as an image layer, and changing the owner later (chown -R)
# would store a second full copy of the SDK (~3 GB).
COPY --from=flutter --chown=dev:dev /opt/flutter /opt/flutter

# --- Android SDK ------------------------------------------------------------
# Owned by dev for the same reason, and so Gradle can add what a plugin asks
# for (another build-tools or CMake) without root.
COPY --from=android --chown=dev:dev /opt/android-sdk /opt/android-sdk
# Two layers of their own, so changing them does not copy the SDK again.
COPY --from=emulator --chown=dev:dev /opt/android-sdk/emulator /opt/android-sdk/emulator
COPY --from=emulator --chown=dev:dev /opt/android-sdk/system-images /opt/android-sdk/system-images

USER dev
WORKDIR /workspace

# Per-user settings (in ~/.config/flutter), so they are made as dev.
RUN flutter config --no-analytics --enable-linux-desktop --no-enable-web \
        --android-sdk /opt/android-sdk

CMD ["sleep", "infinity"]
