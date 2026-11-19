#!/usr/bin/env bash
# Gets the development server ($JELLYFIN_URL, the "jellyfin" service of the
# dev container) ready for the app. Run before "Lighthouse (dev server)"
# in .vscode/launch.json, or by hand.
#
#   - waits until the server answers;
#   - if its setup wizard was never finished, finishes it with the user
#     below, creates the libraries over /media, and lets short items keep
#     a resume point (the fixtures last seconds);
#   - if it is already set up, changes nothing.
#
# User and password (only used when it runs the wizard):
#   JELLYFIN_DEV_USER      default: dev
#   JELLYFIN_DEV_PASSWORD  default: dev
set -euo pipefail

url="${JELLYFIN_URL:?is not set; it comes from the dev container (http://jellyfin:8096)}"
user="${JELLYFIN_DEV_USER:-dev}"
password="${JELLYFIN_DEV_PASSWORD:-dev}"
auth='MediaBrowser Client="lighthouse-dev-setup", Device="dev container", DeviceId="lighthouse-dev-setup", Version="0.0.0"'

# api METHOD PATH [JSON_BODY] -> response body on stdout; fails on HTTP errors.
api() {
  local args=(-fsS --max-time 30 -X "$1" "$url$2" -H "Authorization: $auth${token:+, Token=\"$token\"}")
  [[ $# -ge 3 ]] && args+=(-H 'Content-Type: application/json' -d "$3")
  curl "${args[@]}"
}
# json EXPR < JSON -> prints EXPR evaluated on the parsed input (d).
json() { python3 -c "import json,sys; d=json.load(sys.stdin); print($1)"; }

token=
tmp_config=$(mktemp)
trap 'rm -f "$tmp_config"' EXIT
echo "Dev server: $url"

deadline=$((SECONDS + 90))
until info=$(curl -fsS --max-time 5 "$url/System/Info/Public" 2>/dev/null); do
  if ((SECONDS > deadline)); then
    echo "The dev server does not answer after 90 s. Is the 'jellyfin' container running?" >&2
    exit 1
  fi
  sleep 1
done

if [[ $(json 'd.get("StartupWizardCompleted")' <<<"$info") == True ]]; then
  echo "Already set up ($(json 'd["ServerName"]' <<<"$info"), $(json 'd["Version"]' <<<"$info")). Nothing to do."
  exit 0
fi

echo "Setup wizard not finished: finishing it (user \"$user\")."
api POST /Startup/Configuration \
  '{"UICulture":"en-US","MetadataCountryCode":"US","PreferredMetadataLanguage":"en"}' >/dev/null
api GET /Startup/User >/dev/null # creates the first user
api POST /Startup/User "$(python3 -c 'import json,sys; print(json.dumps({"Name":sys.argv[1],"Password":sys.argv[2]}))' "$user" "$password")" >/dev/null
api POST /Startup/RemoteAccess '{"EnableRemoteAccess":true}' >/dev/null
api POST /Startup/Complete >/dev/null

token=$(api POST /Users/AuthenticateByName \
  "$(python3 -c 'import json,sys; print(json.dumps({"Username":sys.argv[1],"Pw":sys.argv[2]}))' "$user" "$password")" |
  json 'd["AccessToken"]')

# Folders under /media decide the libraries: the fixtures layout
# (movies/, shows/, music/) gets one library each, like the test server;
# anything else gets a single library over /media.
dirs=$(api GET '/Environment/DirectoryContents?path=%2Fmedia&includeDirectories=true&includeFiles=false' |
  json '" ".join(sorted(i["Name"] for i in d))')

add_library() { # NAME TYPE PATH
  echo "  library \"$1\" ($2) over $3"
  local query
  query=$(python3 -c 'import sys,urllib.parse as u; print(u.urlencode({"name":sys.argv[1],"collectionType":sys.argv[2],"paths":sys.argv[3],"refreshLibrary":"true"}))' "$@")
  api POST "/Library/VirtualFolders?$query" '{"LibraryOptions":{}}' >/dev/null
}

found=0
for spec in "movies Movies movies" "shows Shows tvshows" "music Music music"; do
  read -r dir name type <<<"$spec"
  if [[ " $dirs " == *" $dir "* ]]; then
    add_library "$name" "$type" "/media/$dir"
    found=1
  fi
done
((found)) || add_library Media homevideos /media

# The fixture videos last seconds; by default the server keeps no resume
# point under 5 minutes, so "Resume" could never be tried.
api GET /System/Configuration |
  python3 -c 'import json,sys; c=json.load(sys.stdin); c["MinResumeDurationSeconds"]=0; print(json.dumps(c))' >"$tmp_config"
api POST /System/Configuration "$(cat "$tmp_config")" >/dev/null
echo "  resume points kept for short items too"

echo "Done. Sign in to the app as \"$user\"."
