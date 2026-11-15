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
 │   /workspace/jellyfin-desktop   ← desktop repo (read/write) │
 │   /workspace/jellyfin           ← server source (read-only) │
 │                                                             │
 │   flutter run -d linux ──── HTTP ────┐                      │
 └──────────────────────────────────────┼──────────────────────┘
                                        ▼
 ┌─────────────────────────────────────────────────────────────┐
 │ container "jellyfin"  (official image 12.4)                 │
 │   http://jellyfin:8096   (host: http://localhost:8096)      │
 │   /media  ← jellyfin-desktop/resources/testmedia (read-only)│
 └─────────────────────────────────────────────────────────────┘
 ┌─────────────────────────────────────────────────────────────┐
 │ container "jellyfin-test"  (same image, settings in memory) │
 │   http://jellyfin-test:8096   (not reachable from the host) │
 │   /media  ← jellyfin-flutter/fixtures/media (read-only)     │
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
  Its library is the test media shipped in the desktop repository.
- **jellyfin-test**: a second server, only for the automated tests. It
  keeps nothing between restarts; the tests run its setup wizard and
  create its libraries. Don't use it by hand: see
  [../jellyfin-flutter/README.md](../jellyfin-flutter/README.md#tests).

## What each file does

| File | Runs | Purpose |
| --- | --- | --- |
| `devcontainer.json` | read by VS Code | Entry point: which compose service to attach to, which hooks to run, which extensions to install. |
| `initialize.sh` | on the host, before build | Writes `.env` with your user/group ids and the GPU group id. |
| `.env` | read by Compose | Generated, git-ignored. Fills the `${...}` values in the compose file. |
| `docker-compose.yml` | on `up` | Defines the two containers, their mounts and the network between them. |
| `Dockerfile` | on image build | Builds the app image: system packages, Flutter SDK, user `dev`. |
| `postCreate.sh` | in the container, once | `flutter doctor`, `flutter pub get` in `jellyfin-flutter/`, first-run hints. |

## First run

1. Open the workspace root (the folder holding `jellyfin/` and
   `jellyfin-desktop/`) in VS Code and choose **Reopen in Container**.
   The first build downloads Flutter and takes a few minutes.
2. Open <http://localhost:8096> in your browser and finish the setup wizard.
3. Add a library pointing to `/media`.
4. In the container terminal, check the server answers:
   `curl $JELLYFIN_URL/System/Info/Public`

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
  native crashes (a `core` file in jellyfin-flutter/).
- If the app says it could not save the login, run `bash .devcontainer/keyring.sh`.
