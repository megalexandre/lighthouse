#!/usr/bin/env bash
# Runs once, inside the "app" container, right after it is created.
set -euo pipefail

# Versioned git hooks: .githooks/pre-commit analyzes the staged Dart files,
# .githooks/pre-push the whole project.
git config core.hooksPath .githooks

# Show what Flutter sees. The "Linux toolchain" and "Android toolchain"
# lines should be green.
flutter doctor -v || true

# The Flutter project lives in lighthouse/.
# Fetch its packages once it exists.
flutter_dir=lighthouse
if [ -f "$flutter_dir/pubspec.yaml" ]; then
  (cd "$flutter_dir" && flutter pub get)
else
  echo "$flutter_dir/pubspec.yaml not found yet: skipping 'flutter pub get'."
fi

cat <<EOF

Test server: ${JELLYFIN_URL} (from the host: http://localhost:8096)
First run: lighthouse/tool/dev_server.sh finishes its setup
(user dev / dev); the "Lighthouse (dev server)" launch config runs it
for you. Or do the setup wizard yourself in a browser.

Test server (wiped on every restart, set up by the tests themselves):
${JELLYFIN_TEST_URL}
Run all checks: cd lighthouse && tool/check.sh
EOF
