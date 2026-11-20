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

step "Texts (flutter gen-l10n): every key translated"
rm -f build/untranslated_messages.json
flutter gen-l10n
# gen-l10n lists, per language, the keys of app_en.arb that a translation
# lacks; the app would show them in English.
if [[ -s build/untranslated_messages.json ]] && [[ "$(tr -d ' \n' < build/untranslated_messages.json)" != "{}" ]]; then
  echo "Keys without a translation (lib/l10n/app_pt.arb):" >&2
  cat build/untranslated_messages.json >&2
  exit 1
fi

step "Format"
# Generated files are left as the generators write them: *.g.dart,
# *.freezed.dart, and the tests bdd_widget_test makes from a .feature
# (x_test.dart beside x.feature).
find lib test integration_test packages -name '*.dart' \
  ! -name '*.g.dart' ! -name '*.freezed.dart' -print0 \
  | while IFS= read -r -d '' f; do
      [[ -f "${f%_test.dart}.feature" ]] || printf '%s\0' "$f"
    done \
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
# Only test/server/ is compiled for them (all of test/ took twice as long
# just to find the tag), so a server test elsewhere would go unrun.
if strays=$(grep -rl --include='*.dart' "@Tags(\['server'\])" test | grep -v '^test/server/'); then
  echo "Server tests outside test/server/ (move them there):" >&2
  echo "$strays" >&2
  exit 1
fi
flutter test --tags server test/server

step "Integration tests (Linux, Xvfb)"
# They build the Linux app: no other Flutter Linux build meanwhile (an
# AppImage built at the same time got this build's debug engine, and this
# run hung). See tool/with_build_lock.sh.
source tool/with_build_lock.sh
# All in one app run: `flutter test integration_test` builds and starts the
# app once per file, a third of the time. Made here, so a new test is in
# it, and gone after (by hand, `flutter test integration_test` would run
# every test twice).
all=integration_test/all_in_one_test.dart
trap 'rm -f "$all"' EXIT
{
  echo '// Made by tool/check.sh: every integration test in one app run.'
  mapfile -t tests < <(cd integration_test && find . -name '*_test.dart' ! -name all_in_one_test.dart | sed 's|^\./||' | sort)
  for i in "${!tests[@]}"; do echo "import '${tests[$i]}' as t$i;"; done
  echo 'void main() {'
  for i in "${!tests[@]}"; do echo "  t$i.main();"; done
  echo '}'
} > "$all"
xvfb-run -a flutter test "$all" -d linux

step "OK"
