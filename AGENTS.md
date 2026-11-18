# AGENTS.md

Guidance for AI coding agents working in this repository.

## What this is

A Jellyfin desktop client with a native Flutter UI, in `jellyfin-flutter/`. It talks to the
server's REST API directly (no WebView) and plays media with media_kit (libmpv). Linux is the
target for now. Besides video and music it has a book reader (PDF, CBZ comics, EPUB) with a
page-curl animation, and themes built from design-system tokens.

- `jellyfin-flutter/README.md`: running, logs, release, code generation, test layers.
- `jellyfin-flutter/docs/PLAN.md` (Portuguese): the phased plan, the decisions behind it, what is
  done and what is next. Read it before starting a feature.
- `jellyfin-flutter/docs/THEMES.md` (Portuguese): how themes work and the token → UI table.
- `.devcontainer/README.md`: the containers and the two Jellyfin servers.

## Repository layout

This git repository tracks the shared workspace: `.devcontainer/`, `.vscode/`, `.github/` and
`jellyfin-flutter/`.

- `jellyfin/` (server source, mounted read-only) and `jellyfin-desktop/` (the current Qt client)
  are **separate repositories, ignored here, used only as reference**. Port logic from them, not
  code. Note that the server source is 13.x while the servers in the dev container run **12.4**:
  the 12.4 behaviour wins.
- Inside `jellyfin-flutter/`:

```
lib/
  api/            hand-written API client (dio), one file per area; models/ are freezed DTOs
  core/           config, logging, device id, failures, ticks, storage, window, theme/
  features/<f>/   data/ (repositories)  application/ (Riverpod providers)  presentation/ (widgets)
  widgets/        shared components (buttons, focus ring, badges, row arrows)
test/             unit + widget tests; test/server/ (tag `server`) talks to the test server
test/support/     fakes.dart (TestApp and fake repositories), fake HTTP, EPUB helpers
integration_test/ the real app on Linux under Xvfb, against the test server;
                  features/ holds its .feature scenarios
packages/jellyfin_test_server/   sets up the throwaway test server; used by tests only
fixtures/media/   generated test library (committed)
third_party/      vendored, patched media_kit_video (see its README); keep as upstream wrote it
shaders/          page_curl.frag (book page turn)
assets/themes/    built-in themes (tokens.json files); assets/fonts/ bundled fonts
tool/             check.sh, scenarios.sh, gen_fixtures.sh, gen_books.py, build_appimage.sh...
```

## Environment

Everything runs inside the dev container (Flutter SDK, libmpv, ffmpeg, Xvfb). Two Jellyfin 12.4
servers run next to it:

- `$JELLYFIN_URL` (http://jellyfin:8096): the development server, for running the app by hand.
- `$JELLYFIN_TEST_URL` (http://jellyfin-test:8096): **for the automated tests only**. Its config
  lives in tmpfs and resets on every container restart; the tests set it up themselves.

Run commands from `jellyfin-flutter/`.

## Commands

| What | Command |
| --- | --- |
| Full gate (must pass before a commit; CI runs the same) | `tool/check.sh` |
| Format, analysis and the tests that need no server | `tool/check.sh --fast` |
| Unit and widget tests | `flutter test --exclude-tags server` |
| API client against the test server | `flutter test --tags server` |
| Integration tests | `xvfb-run -a flutter test integration_test -d linux` |
| Integration tests on an AOT (profile) build | `tool/profile_test.sh` |
| Behaviour scenarios (`.feature`) | `tool/scenarios.sh [file] ["scenario name"]` |
| Code generation | `dart run build_runner build --delete-conflicting-outputs` |
| Run the app | `tool/dev_server.sh && flutter run -d linux --dart-define=JELLYFIN_SERVER=$JELLYFIN_URL` |
| Release AppImage | `tool/build_appimage.sh` |

A piece of work is done only when `tool/check.sh` is green. Integration tests and AppImage builds
both build the Linux app and must not run at the same time (`tool/with_build_lock.sh`).
`build/` after the integration tests holds the *test* app: `flutter build linux` before running
the bundle by hand.

## Conventions

- **Language:** code, comments, identifiers, commit messages, `.feature` files and UI strings in
  English (no i18n yet; pt-BR is planned). `docs/PLAN.md` and `docs/THEMES.md` are in Portuguese.
- **Style:** `dart format`, and the strict analyzer settings in `analysis_options.yaml` (strict
  casts/inference/raw types, single quotes, trailing commas, `prefer_final_locals`,
  `unawaited_futures`, no `print`). Comments say *why*, not what.
- **State and DI:** Riverpod. Tests replace real services with fakes through provider overrides
  (`test/support/fakes.dart`, `TestApp`). The app turns off Riverpod's automatic retry.
- **Dependencies:** pinned to an exact version when new or risky, with a comment saying why the
  package is there. Prefer versions with a few weeks of use.
- **Generated files** (`*.g.dart`, `*.freezed.dart`, the `x_test.dart` made from `x.feature`) are
  committed and never edited by hand; `check.sh` regenerates them first.
- **Commits:** conventional style, e.g. `feat: books L3 - contents, links, type, themes,
  bookmarks`, `fix: reader - ...`, `chore(vscode): ...`, `test: ...`. Commit only when asked.

## Rules that are easy to miss

- **API contract:** the client is hand-written. When you add an endpoint or read/send a new JSON
  field, add it to `apiContract` in `lib/api/contract.dart`; `test/server/contract_test.dart`
  checks it against the test server's OpenAPI document.
- **Fixtures:** `fixtures/media` comes from `tool/gen_fixtures.sh` / `tool/gen_books.py`. Never
  delete and recreate the folder: both servers bind-mount it. When you change it, update
  `Fixtures` in `packages/jellyfin_test_server` (it uses exact server names, e.g. 12.4 keeps the
  year: "Test Movie (2020)").
- **Test server isolation:** a test that changes server state creates its own user
  (`server.createUser()`). Users are never deleted: 12.4 reuses a deleted user's id, and the new
  user inherits its watch state.
- **Behaviour scenarios:** `.feature` files in standard Gherkin (`{...}` parameters are fine; no
  `After:` blocks), turned into `x_test.dart` beside them by build_runner. Under `test/features/<area>/`
  they run against fakes (`TestApp`); under `integration_test/features/` they run the real app
  against the test server, sharing one `step/` folder. Steps go in `step/`, one file per phrase;
  shared scenario state in `step/world.dart`; setup and cleanup in `hook/hooks.dart` (per folder).
  Run with `tool/scenarios.sh`. See "Cenários de comportamento" in `docs/PLAN.md`.
- **Themes:** Lanterna (`assets/themes/lanterna.json`) is the base every theme falls back to and
  must stay complete; Prime is the default. "Sync Lanterna" means copying the design artifact's
  `project/tokens.json` over `assets/themes/lanterna.json` unchanged.
- **Books on 12.4:** positions use the server's scale (PDF/CBZ: 10000 ticks per page; EPUB: a
  fraction of 10^7 ticks), so the server's percentage matches other clients.

## Testing gotchas

- Widget tests run on a fake clock: real async file reads never finish there (`TestApp` opens
  fixture books synchronously).
- Read a provider at tap time instead of capturing a watched value in a callback, or quick double
  taps get lost.
- `SliverToBoxAdapter` is not lazy: don't trigger paging or keep an idle spinner in it
  (`pumpAndSettle` hangs).
- Integration tests: use the helpers in `integration_test/support/app.dart` (`launch`,
  `typeInto`, `pressKey`, `settleRoute`); typing needs the field tapped and focused first, and
  route changes driven by the app need `settleRoute()` before the next tap.
- `flutter test` runs files in parallel: the test server client uses a per-process DeviceId,
  because Jellyfin revokes a token when the same user logs in again from the same device.
- mpv under Xvfb runs with hwdec off and `ao=null`; its hardware-probe errors in the log are
  harmless.
- Goldens (`test/features/reader/goldens/`) render the page-curl shader; update them with
  `flutter test --update-goldens` and check the images by eye.
