# Dev container

A reproducible environment for the Flutter rewrite of Jellyfin Desktop.
You need Docker and VS Code with the Dev Containers extension. 
Everything else (Flutter, libmpv, a Jellyfin server) lives in containers.

## How it fits together

```
 HOST (your Linux machine)
 ┌──────────────────────────────────────────────────────────────┐
 │  Display server (Wayland / X11)    GPU (/dev/dri)    Audio   │
 │        ▲  socket                     ▲ device        ▲ socket│
 └────────┼─────────────────────────────┼───────────────┼───────┘
          │                             │               │
 ┌────────┴─────────────────────────────┴───────────────┴──────┐
 │ container "app"  (Flutter SDK, libmpv, user "dev")          │
 │   /workspace/lighthouse         ← the Flutter client        │
 │   /workspace/related-repos/     ← jellyfin, jellyfin-desktop│
 │                                                             │
 │   flutter run -d linux ──── HTTP ────┐                      │
 └──────────────────────────────────────┼──────────────────────┘
                                        ▼
 ┌─────────────────────────────────────────────────────────────┐
 │ container "jellyfin"  (official image 12.4)                 │
 │   http://jellyfin:8096   (host: http://localhost:8096)      │
 │   /media  ← lighthouse/fixtures/media (read-only)     │
 └─────────────────────────────────────────────────────────────┘
 ┌─────────────────────────────────────────────────────────────┐
 │ container "jellyfin-test"  (same image, settings in memory) │
 │   http://jellyfin-test:8096   (not reachable from the host) │
 │   /media  ← lighthouse/fixtures/media (read-only)     │
 └─────────────────────────────────────────────────────────────┘
```

- **Host**: lends three things to the app container. The display socket,
  so the app window opens on your screen. The GPU device, for hardware
  video decoding. The audio socket.
- **app**: where you edit, build and run the Flutter code. The whole
  workspace is mounted at `/workspace` with the same layout as on the host;
  the server source is mounted read-only on top of it.
- **jellyfin**: a real server for the app to talk to. Inside the compose
  network its hostname is `jellyfin`; from the host it is `localhost:8096`.
  Its library is the generated fixtures in `lighthouse/fixtures/media`
  (two movies, a three-episode show, an album), the same as the test server.
- **jellyfin-test**: a second server, only for the automated tests. It
  keeps nothing between restarts; the tests run its setup wizard and
  create its libraries. Don't use it by hand: see
  [../lighthouse/README.md](../lighthouse/README.md#tests).

## What each file does

| File | Runs | Purpose |
| --- | --- | --- |
| `devcontainer.json` | read by VS Code | Entry point: which compose service to attach to, which hooks to run, which extensions to install. |
| `initialize.sh` | on the host, before build | Writes `.env` with your user/group ids and the GPU group id. |
| `.env` | read by Compose | Generated, git-ignored. Fills the `${...}` values in the compose file. |
| `docker-compose.yml` | on `up` | Defines the two containers, their mounts and the network between them. |
| `Dockerfile` | on image build | Builds the app image: system packages, Flutter SDK, Android SDK, user `dev`. |
| `postCreate.sh` | in the container, once | `flutter doctor`, `flutter pub get` in `lighthouse/`, first-run hints. |
| `keyring.sh` | in the container, every start | D-Bus session and keyring for the app's secure storage. |
| `related_repos.sh` | in the container, every start | Clones `related-repos/jellyfin` and `related-repos/jellyfin-desktop` over HTTPS, or fetches and fast-forwards them (a clean branch with an upstream only; local work is left alone). Offline, it warns and goes on. |

## First run

1. Open the workspace root (the folder holding `lighthouse/`) in VS Code
   and choose **Reopen in Container**. The first build downloads Flutter
   and takes a few minutes; the first start clones the reference
   repositories into `related-repos/`.
2. In the container terminal, set up the dev server:
   `bash lighthouse/tool/dev_server.sh`. It finishes the setup wizard
   (user `dev`, password `dev`) and creates the Movies, Shows and Music
   libraries. The launch config "Lighthouse (dev server)" runs it too.
   You can also do it by hand at <http://localhost:8096>.
3. To start the dev server from scratch (new libraries, no users), on the
   host: `docker compose -p jellyfin-dev down`, then
   `docker volume rm jellyfin-dev_jellyfin-config jellyfin-dev_jellyfin-cache`,
   then **Rebuild Container**.

## Building from the command line

VS Code builds the image for you. To build it yourself (to read the
full log, or to check a Dockerfile change quickly), run from the
workspace root:

```sh
bash .devcontainer/initialize.sh
docker compose -f .devcontainer/docker-compose.yml build --progress plain app
```

`--progress plain` prints every line each step writes. Without it, the
output folds into a progress bar, and a long step (downloading Flutter,
exporting the image) looks the same as a stuck one.

Rebuilds are fast when only late steps change: Docker reuses every
cached step before the first one you changed. See the comment at the
top of the `Dockerfile` for the order of the steps.

## Claude Code

The Claude Code extension is installed in the container. Sign in once;
the login, settings and session history are kept in the `claude-config`
volume (mounted at `/home/dev/.claude`, with `CLAUDE_CONFIG_DIR` pointing
there), so they survive **Rebuild Container**. To log out everywhere and
start fresh: `docker volume rm jellyfin-dev_claude-config`.

Skills installed for every project in the container live in the same
volume, under `~/.claude/skills/`:

- `security-audit` (Cloudflare,
  [security-audit-skill](https://github.com/cloudflare/security-audit-skill),
  MIT): security reviews and, when asked explicitly, a full multi-phase
  audit. Its validators run with Node.js, installed by the Dockerfile.
  The pinned commit is in `~/.claude/skills/security-audit/SOURCE.txt`;
  to update, download a newer commit, read it, and replace the folder.
  It executes audited code only inside an OS-enforced sandbox, which this
  container does not provide: here its audits are source-only, and what
  would need running is reported as `needs_validation`.
- `open-code-review` and `open-code-review-delegate` (Alibaba,
  [open-code-review](https://github.com/alibaba/open-code-review),
  Apache-2.0): code review of Git changes (workspace, a commit, a branch
  range) with line-level comments. Both drive the `ocr` CLI, which the
  Dockerfile installs as a native binary at a pinned version (not through
  npm, whose launcher auto-updates itself).
  - *delegate* needs nothing else: `ocr` only picks the files and rules,
    and Claude does the review.
  - *open-code-review* has `ocr` call an LLM itself: configure a provider
    and API key first (`ocr config provider`, kept in
    `~/.opencodereview/config.json`; your code goes to that provider).
  Fixes are applied only when asked ("review and fix"). Commits are in
  each skill's `SOURCE.txt`.

## Android

The image has what `flutter build apk` needs: Java 17, the Android SDK in
`/opt/android-sdk` (`ANDROID_HOME`) with the platform, build-tools, NDK and
CMake that Flutter 3.50 asks for, and `adb`. The versions are pinned in the
`Dockerfile`, in the `android` stage. Gradle's cache lives in the
`gradle-cache` volume, so the ~1 GB of the first build is downloaded once.

The emulator does not run in here: it needs `/dev/kvm` and a screen. Run it
on the host (Android Studio's Device Manager), and let the container's `adb`
use the host's adb server, which sees it:

```sh
# on the host, once per session (after starting the emulator)
adb kill-server && adb -a nodaemon server start
```

Then, in the container terminal where you use the emulator:

```sh
export ADB_SERVER_SOCKET=tcp:host.docker.internal:5037
```

Now `adb devices` and `flutter devices` list the emulator, and
`flutter run -d emulator-5554` installs the app with hot reload. Keep the
host's adb close to the container's version (the latest platform-tools):
very different versions refuse to talk.

The variable is not set for the whole container on purpose: while the
host's adb server is down, adb fails, and Flutter's device discovery fails
with it, Linux included (`flutter run -d linux`, the integration tests).

- **`-a` listens on every interface**, so anyone on your network could use
  adb on your emulator. Block port 5037 from outside on the host's firewall,
  or stop the server (`adb kill-server`) when you are done.
- **From the emulator**, the host is `10.0.2.2`: the dev server is
  `http://10.0.2.2:8096`. The test server has no port on the host, so the
  emulator cannot reach it.
- **To use adb on its own** (a phone over Wi-Fi, say), don't set the
  variable: adb starts its own server in the container.

## Limits and common problems

- **Hardware decoding, audio passthrough and refresh rate switching** depend
  on your GPU, sound card and compositor. The container is good for building,
  testing and UI work. If one of these misbehaves, compare with running the
  app directly on the host before blaming the code.
- **The window does not open (X11-only session)**: allow local containers to
  use your display with `xhost +local:` on the host.
- **No GPU / no `/dev/dri`**: remove the `devices` and `group_add` blocks
  from `docker-compose.yml`. Video will decode in software.
- **"port 8096 is already allocated"**: something else on the host uses it,
  often an older copy of these containers. Check with `docker ps`, then stop
  it, or change the left side of `"8096:8096"` (e.g. `"8097:8096"`).
- **Files owned by the wrong user**: delete `.env`, then
  **Rebuild Container** so `initialize.sh` writes your ids again.
- **`flutter devices` or `flutter run -d linux` fails with "Unable to run
  adb"**: `ADB_SERVER_SOCKET` is set but the host's adb server is down.
  `unset ADB_SERVER_SOCKET`, or start the server on the host.
- **`adb devices` says "cannot connect to daemon"**: the host's adb server
  is not running with `-a` (see [Android](#android)). With Podman, if
  `host.docker.internal` does not resolve, use `host.containers.internal`
  in `ADB_SERVER_SOCKET`, which Podman always defines.

## Keyring (app login storage)

The app keeps its login in the system keyring (libsecret). The host's
session bus is mounted in, but Docker's AppArmor profile blocks containers
from using it, so the container runs its own: `keyring.sh` starts a D-Bus
session bus and an unlocked gnome-keyring on every container start
(`postStartCommand`), and `DBUS_SESSION_BUS_ADDRESS` in docker-compose.yml
points everything in the container at it.

- The keyring lives in the container, so a rebuild empties it: sign in to
  the app again. Its password is `dev`.
- `secret-tool` is installed to inspect it; `gdb` too, for backtraces of
  native crashes (a `core` file in lighthouse/).
- If the app says it could not save the login, run `bash .devcontainer/keyring.sh`.
