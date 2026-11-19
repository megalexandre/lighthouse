# Lighthouse

Jellyfin desktop client with a native Flutter UI. It talks to the server's
REST API directly and plays media with [media_kit](https://github.com/media-kit/media-kit)
(libmpv, the same engine as `../jellyfin-desktop`). Linux first.

The plan (phases, test strategy) is in [docs/PLAN.md](docs/PLAN.md).

## Run

Inside the dev container (see [../.devcontainer/README.md](../.devcontainer/README.md)):

```sh
flutter run -d linux
```

The development server is `$JELLYFIN_URL` (http://jellyfin:8096). In VS Code,
**Run and Debug → "Lighthouse (dev server)"** gets it ready and opens
the app with its address already on the connect screen. It runs
`tool/dev_server.sh` first, which waits for the server and, if its setup was
never finished, finishes it (user `dev` / `dev`, change with
`JELLYFIN_DEV_USER` / `JELLYFIN_DEV_PASSWORD`) and creates libraries over
`/media`. A server that is already set up is left alone.

Outside VS Code:

```sh
tool/dev_server.sh
flutter run -d linux --dart-define=JELLYFIN_SERVER=$JELLYFIN_URL
```

## Logs

The app logs to `~/.local/share/lighthouse/logs/app.log` (under
`$XDG_DATA_HOME` when set); the last three runs are kept as `app.1.log`...
Every request (status, time), playback decisions, mpv warnings, lost and
regained connections and uncaught errors. Tokens, `ApiKey` values in URLs
and passwords are replaced by `***` before anything is written, so a log
can be shared.

## Release

```sh
tool/profile_test.sh     # integration tests on an AOT build
tool/build_appimage.sh   # release build → build/Lighthouse-<version>-x86_64.AppImage
```

- **AppImage**: one file that runs on most x86_64 Linux desktops. It
  carries the release bundle and the libraries a desktop may lack (libmpv
  and its ffmpeg...); glibc and the GPU drivers come from the host.
  [linuxdeploy](https://github.com/linuxdeploy/linuxdeploy) does the
  packing; the script downloads a pinned version once, checks its SHA-256
  and caches it in `~/.cache/lighthouse/tools`. It ends with a smoke
  test: the AppImage must start (under Xvfb) far enough to write its log.
- **Why profile for the integration tests**: a release build cannot be
  driven by a test (it has no VM service). Profile is compiled the same
  way (AOT, no asserts, tree-shaken) and still can, so it catches what only
  breaks in a compiled build. `tool/profile_test.sh` runs each
  `integration_test/` file with `flutter drive --profile`.
- Run an AppImage without FUSE (containers): `APPIMAGE_EXTRACT_AND_RUN=1`.

After the integration tests, `build/linux/x64/debug/bundle` holds the
*test* app; `flutter build linux` before running the bundle by hand.

## Code generation

Models (`lib/api/models`, sessions) use freezed + json_serializable. After
changing one:

```sh
dart run build_runner build
```

The generated `*.freezed.dart` / `*.g.dart` files are committed;
`tool/check.sh` regenerates them first, so a stale one cannot slip through.

## Tests

Every phase is done only when `tool/check.sh` passes. It runs four layers:

| Layer | Where | Needs | Command |
| --- | --- | --- | --- |
| Unit | `test/` | nothing | `flutter test --exclude-tags server` |
| Widget | `test/` | nothing (fake API through Riverpod overrides) | same |
| API client vs real server | `test/server/` (tag `server`) | test server | `flutter test --tags server` |
| App integration | `integration_test/` | test server, Xvfb | `xvfb-run -a flutter test integration_test -d linux` |

`tool/check.sh --fast` skips the last two.

### The test server

`jellyfin-test` (http://jellyfin-test:8096, in `$JELLYFIN_TEST_URL`) is a
second Jellyfin 12.4 that only the tests use. Its settings live in memory,
so each restart starts from an empty server. The tests set it up
themselves through `packages/jellyfin_test_server`:

- `TestServer.start()` runs the setup wizard (admin / admin-password),
  creates the Movies, Shows and Music libraries over `fixtures/media`
  (no internet metadata), and waits for the scan. It is idempotent.
- `server.createUser()` gives a test its own user, so watch progress and
  played state never leak between tests. Delete it in `addTearDown`.

### API contract

The API client is hand-written (only the endpoints the app uses). Every
endpoint and the JSON fields it sends and reads are listed in
`lib/api/contract.dart`; the field lists come from the models themselves
(json_serializable's field maps). `test/server/contract_test.dart` checks
the list against the test server's `/api-docs/openapi.json`. **When you add
an API call, add it to `apiContract`.**

### Test media

`fixtures/media` (~800 KB, committed) comes from `tool/gen_fixtures.sh`
(ffmpeg, byte-for-byte reproducible): a movie with two audio tracks
(eng, por) and embedded + external subtitles, a HEVC 10-bit movie, a show
with three episodes, a two-track album, and three small books (a 5-page
PDF, a 5-page comic, a 3-chapter EPUB; `tool/gen_books.py`, Python
standard library only). If you change it, update `Fixtures` in
`packages/jellyfin_test_server`. The script empties the folder in place:
the servers bind-mount it, so it must never be deleted and recreated.

## Layout

```
lib/            app (api/, core/, features/<feature>/{data,application,presentation})
test/           unit + widget tests; test/server/ talks to the test server
integration_test/   real app on Linux against the test server
packages/jellyfin_test_server/   test server setup, used by the tests only
fixtures/media/ generated test library
tool/           check.sh, gen_fixtures.sh
```
