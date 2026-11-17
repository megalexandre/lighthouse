#!/usr/bin/env bash
# Runs the behaviour scenarios (test/**/*.feature, docs/PLAN.md: "Cenários
# de comportamento"): makes the tests from the .feature files first, so an
# edited scenario always runs as written.
#
#   tool/scenarios.sh                    every feature
#   tool/scenarios.sh FILE               one feature: the .feature, or its
#                                        generated _test.dart, or a step
#                                        file in its step/ folder
#   tool/scenarios.sh FILE "NAME"        only the scenarios whose name has
#                                        NAME in it
set -euo pipefail
cd "$(dirname "$0")/.."

file="${1:-}"
name="${2:-}"

step() { printf '\n\033[1;35m== %s\033[0m\n' "$*"; }

step "Tests from the .feature files"
dart run build_runner build --delete-conflicting-outputs

if [[ -z "$file" ]]; then
  mapfile -t tests < <(find test -name '*.feature' | sed 's/\.feature$/_test.dart/' | sort)
  if ((${#tests[@]} == 0)); then
    echo "No .feature files under test/." >&2
    exit 1
  fi
else
  # Relative to jellyfin-flutter/, whatever VS Code passes.
  file="${file#"$PWD/"}"
  case "$file" in
    *.feature) test="${file%.feature}_test.dart" ;;
    *_test.dart) test="$file" ;;
    */step/*.dart)
      # A step: the features in the folder above it.
      dir="${file%/step/*}"
      mapfile -t found < <(find "$dir" -maxdepth 1 -name '*.feature' | sort)
      if ((${#found[@]} == 0)); then
        echo "No .feature beside $(dirname "$file")." >&2
        exit 1
      fi
      tests=("${found[@]/%.feature/_test.dart}")
      ;;
    *)
      echo "Not a scenario file: $file (open a .feature, its _test.dart or a step)." >&2
      exit 1
      ;;
  esac
  [[ -n "${test:-}" ]] && tests=("$test")
  if [[ ! -f "${tests[0]}" ]]; then
    echo "${tests[0]} was not made: is ${tests[0]%_test.dart}.feature valid Gherkin?" >&2
    exit 1
  fi
fi

step "Scenarios: ${tests[*]}${name:+ (named like \"$name\")}"
if [[ -n "$name" ]]; then
  flutter test "${tests[@]}" --plain-name "$name"
else
  flutter test "${tests[@]}"
fi
