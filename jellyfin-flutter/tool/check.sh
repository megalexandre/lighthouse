#!/usr/bin/env bash
# Everything a change must pass before it is committed. CI runs the same.
#
#   tool/check.sh          all checks (needs the test server)
#   tool/check.sh --fast   format, analysis and the tests that need no server
set -euo pipefail
cd "$(dirname "$0")/.."

fast=false
[[ "${1:-}" == "--fast" ]] && fast=true

step() { printf '\n\033[1;35m== %s\033[0m\n' "$*"; }

step "Code generation (freezed, json_serializable)"
dart run build_runner build

step "Format"
# Generated files are left as the generators write them.
find lib test integration_test packages -name '*.dart' \
  ! -name '*.g.dart' ! -name '*.freezed.dart' -print0 \
  | xargs -0 dart format --output=none --set-exit-if-changed

step "Analyze"
flutter analyze
(cd packages/jellyfin_test_server && dart analyze --fatal-infos)

step "Unit and widget tests"
flutter test --exclude-tags server

$fast && { step "OK (fast: server and integration tests skipped)"; exit 0; }

step "Test server: ${JELLYFIN_TEST_URL:-<unset>}"
if ! curl -fsS --max-time 5 "${JELLYFIN_TEST_URL:?is not set; rebuild the dev container}/System/Info/Public" >/dev/null; then
  echo "Test server is not answering. Rebuild the dev container (it starts 'jellyfin-test')." >&2
  exit 1
fi

step "Server tests"
(cd packages/jellyfin_test_server && dart test)
flutter test --tags server

step "Integration tests (Linux, Xvfb)"
xvfb-run -a flutter test integration_test -d linux

step "OK"
