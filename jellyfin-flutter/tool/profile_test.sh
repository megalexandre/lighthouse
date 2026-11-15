#!/usr/bin/env bash
# Runs every integration test on an AOT-compiled app (profile mode).
#
# Release builds cannot be driven: they have no VM service for the test
# to talk through. Profile is compiled the same way (AOT, tree-shaken,
# no asserts) and keeps that channel, so it is what checks that the
# release-style build behaves; tool/build_appimage.sh smoke-tests the
# actual release build.
set -euo pipefail
cd "$(dirname "$0")/.."

failed=()
for test in integration_test/*_test.dart; do
  printf '\n\033[1;35m== %s (profile)\033[0m\n' "$test"
  if ! xvfb-run -a flutter drive --profile -d linux \
      --driver test_driver/integration_test.dart --target "$test"; then
    failed+=("$test")
  fi
done

if ((${#failed[@]})); then
  printf '\nFailed in profile mode:\n' >&2
  printf '  %s\n' "${failed[@]}" >&2
  exit 1
fi
printf '\n\033[1;35m== OK (profile)\033[0m\n'
