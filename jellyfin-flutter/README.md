# Jellyfin Flutter

Jellyfin desktop client with a native Flutter UI. It talks to the server's
REST API directly and plays media with [media_kit](https://github.com/media-kit/media-kit)
(libmpv, the same engine as `../jellyfin-desktop`). Linux first.

The plan (phases, test strategy) is in [docs/PLAN.md](docs/PLAN.md).

## Run

Inside the dev container (see [../.devcontainer/README.md](../.devcontainer/README.md)):

```sh
flutter run -d linux
```

The development server is `$JELLYFIN_URL` (http://jellyfin:8096).

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

### Test media

`fixtures/media` (~800 KB, committed) comes from `tool/gen_fixtures.sh`
(ffmpeg, byte-for-byte reproducible): a movie with two audio tracks
(eng, por) and embedded + external subtitles, a HEVC 10-bit movie, a show
with three episodes, and a two-track album. If you change it, update
`Fixtures` in `packages/jellyfin_test_server`.

## Layout

```
lib/            app (api/, core/, features/<feature>/{data,application,presentation})
test/           unit + widget tests; test/server/ talks to the test server
integration_test/   real app on Linux against the test server
packages/jellyfin_test_server/   test server setup, used by the tests only
fixtures/media/ generated test library
tool/           check.sh, gen_fixtures.sh
```
