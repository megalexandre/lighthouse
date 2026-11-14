#!/usr/bin/env bash
# Runs once, inside the "app" container, right after it is created.
set -euo pipefail

# Show what Flutter sees. The "Linux toolchain" line should be green.
flutter doctor -v || true

# The Flutter project lives in jellyfin-desktop/flutter/.
# Fetch its packages once it exists.
flutter_dir=jellyfin-desktop/flutter
if [ -f "$flutter_dir/pubspec.yaml" ]; then
  (cd "$flutter_dir" && flutter pub get)
else
  echo "$flutter_dir/pubspec.yaml not found yet: skipping 'flutter pub get'."
fi

cat <<EOF

Test server: ${JELLYFIN_URL} (from the host: http://localhost:8096)
First run: open it in a browser, finish the setup wizard,
and add a library pointing to /media.
EOF
