#!/usr/bin/env bash
# Runs the behaviour scenarios (docs/PLAN.md: "Cenários de comportamento"):
# makes the tests from the .feature files first, so an edited scenario
# always runs as written.
#
# test/**/*.feature run against fakes; integration_test/**/*.feature run the
# real app on Linux under Xvfb, against the test server.
#
#   tool/scenarios.sh                    every feature
#   tool/scenarios.sh DIR                every feature in DIR and below it,
#                                        e.g. integration_test/features
#   tool/scenarios.sh FILE               one feature: the .feature, or its
#                                        generated _test.dart, or a file in
#                                        its step/ or hook/ folder
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
  mapfile -t tests < <(find test integration_test -name '*.feature' | sed 's/\.feature$/_test.dart/' | sort)
  if ((${#tests[@]} == 0)); then
    echo "No .feature files under test/ or integration_test/." >&2
    exit 1
  fi
else
  # Relative to lighthouse/, whatever VS Code passes.
  file="${file#"$PWD/"}"
  file="${file%/}"
  if [[ -d "$file" ]]; then
    mapfile -t tests < <(find "$file" -name '*.feature' | sed 's/\.feature$/_test.dart/' | sort)
    if ((${#tests[@]} == 0)); then
      echo "No .feature files under $file." >&2
      exit 1
    fi
  else
    case "$file" in
      *.feature) test="${file%.feature}_test.dart" ;;
      *_test.dart) test="$file" ;;
      */step/*.dart | */hook/*.dart)
        # A step or a hook: the features in the folder above it.
        dir="${file%/*/*}"
        mapfile -t found < <(find "$dir" -maxdepth 1 -name '*.feature' | sort)
        if ((${#found[@]} == 0)); then
          echo "No .feature beside $(dirname "$file")." >&2
          exit 1
        fi
        tests=("${found[@]/%.feature/_test.dart}")
        ;;
      *)
        echo "Not a scenario file: $file (open a .feature, its _test.dart, a step or a hook)." >&2
        exit 1
        ;;
    esac
    [[ -n "${test:-}" ]] && tests=("$test")
    if [[ ! -f "${tests[0]}" ]]; then
      echo "${tests[0]} was not made: is ${tests[0]%_test.dart}.feature valid Gherkin?" >&2
      exit 1
    fi
  fi
fi

fakes=() app=()
for t in "${tests[@]}"; do
  case "$t" in
    integration_test/*) app+=("$t") ;;
    *) fakes+=("$t") ;;
  esac
done
by_name=(${name:+--plain-name "$name"})

if ((${#fakes[@]})); then
  step "Scenarios: ${fakes[*]}${name:+ (named like \"$name\")}"
  flutter test "${fakes[@]}" "${by_name[@]}"
fi

if ((${#app[@]})); then
  step "Scenarios on the real app: ${app[*]}${name:+ (named like \"$name\")}"
  curl -fsS --max-time 5 "${JELLYFIN_TEST_URL:?is not set; rebuild the dev container}/System/Info/Public" >/dev/null \
    || { echo "Test server is not answering. Rebuild the dev container (it starts 'jellyfin-test')." >&2; exit 1; }
  # Builds the Linux app: not while another Linux build runs.
  source tool/with_build_lock.sh
  xvfb-run -a flutter test "${app[@]}" -d linux "${by_name[@]}"
fi
