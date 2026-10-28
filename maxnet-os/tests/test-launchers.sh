#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
launcher="$repo_root/maxnet-os/bin/maxnet-os"
feature_table="$repo_root/maxnet-os/share/applications/features.tsv"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

start_icon_name="maxnet-os-start-0-4-11"
fallback_icon_name="$(python3 "$repo_root/maxnet-os/bin/maxnet-os-sync-logo")"
[[ "$fallback_icon_name" == "$start_icon_name" ]] \
  || fail "Offline Start icon fallback was '$fallback_icon_name'"
for icon_size in 24x24 48x48 96x96; do
  icon_path="$repo_root/maxnet-os/share/icons/hicolor/$icon_size/apps/$start_icon_name.png"
  [[ -s "$icon_path" ]] || fail "Missing $icon_size Start icon asset"
  file "$icon_path" | grep -Fq 'PNG image data' \
    || fail "Start icon at $icon_size is not a PNG"
done

contains_arg() {
  local expected="$1"
  shift
  local actual
  for actual in "$@"; do
    [[ "$actual" == "$expected" ]] && return 0
  done
  return 1
}

make_test_path() {
  local name="$1"
  local browser="$2"
  local path_dir="$tmp_dir/path-$name"
  mkdir -p "$path_dir"

  local tool target
  for tool in python3 install date dirname chmod; do
    target="$(command -v "$tool")" || fail "Required test utility not found: $tool"
    ln -s "$target" "$path_dir/$tool"
  done

  if [[ -n "$browser" ]]; then
    ln -s "$tmp_dir/mock-browser" "$path_dir/$browser"
  fi
  printf '%s\n' "$path_dir"
}

cat > "$tmp_dir/mock-browser" <<'MOCK'
#!/bin/sh
printf '%s\0' "$@" > "${MAXOS_TEST_ARGS:?}"
MOCK
chmod +x "$tmp_dir/mock-browser"

cat > "$tmp_dir/mock-xdg-open" <<'MOCK'
#!/bin/sh
printf '%s\0' "$@" > "${MAXOS_TEST_XDG_ARGS:?}"
MOCK
chmod +x "$tmp_dir/mock-xdg-open"

cat > "$tmp_dir/mock-mpv" <<'MOCK'
#!/bin/sh
printf 'intro\n' >> "${MAXOS_TEST_EVENTS:?}"
printf '%s\0' "$@" > "${MAXOS_TEST_MPV_ARGS:?}"
MOCK
chmod +x "$tmp_dir/mock-mpv"

cat > "$tmp_dir/mock-celluloid" <<'MOCK'
#!/bin/sh
printf 'celluloid-intro\n' >> "${MAXOS_TEST_EVENTS:?}"
printf '%s\0' "$@" > "${MAXOS_TEST_CELLULOID_ARGS:?}"
MOCK
chmod +x "$tmp_dir/mock-celluloid"

cat > "$tmp_dir/mock-zenity" <<'MOCK'
#!/bin/sh
case "$1" in
  --question)
    printf 'setup-prompt\n' >> "${MAXOS_TEST_EVENTS:?}"
    exit 1
    ;;
  --list)
    printf 'theme-picker\n' >> "${MAXOS_TEST_EVENTS:?}"
    exit 0
    ;;
esac
exit 0
MOCK
chmod +x "$tmp_dir/mock-zenity"

chromium_path="$(make_test_path chromium chromium)"
firefox_path="$(make_test_path firefox firefox)"
no_browser_path="$(make_test_path no-browser "")"
ln -s "$tmp_dir/mock-xdg-open" "$no_browser_path/xdg-open"
intro_path="$(make_test_path intro "")"
ln -s "$tmp_dir/mock-mpv" "$intro_path/mpv"
ln -s "$tmp_dir/mock-zenity" "$intro_path/zenity"
celluloid_path="$(make_test_path intro-celluloid "")"
ln -s "$tmp_dir/mock-celluloid" "$celluloid_path/celluloid"
ln -s "$(command -v timeout)" "$celluloid_path/timeout"
ln -s "$tmp_dir/mock-zenity" "$celluloid_path/zenity"

features=()
while IFS='|' read -r feature _rest; do
  [[ -n "$feature" && "$feature" != \#* ]] || continue
  features+=("$feature")
done < "$feature_table"
(( ${#features[@]} > 0 )) || fail "No launchers found in features.tsv"

run_and_check() {
  local browser="$1"
  local path_dir="$2"
  local feature="$3"
  local result_file="$tmp_dir/args-$browser-$feature"
  local config_dir="$tmp_dir/config-$browser-$feature"
  local data_dir="$tmp_dir/data-$browser-$feature"
  local -a args=()
  local url

  MAXOS_TEST_ARGS="$result_file" \
    MAXNET_URL="https://moonbat.ddns.net" \
    XDG_CONFIG_HOME="$config_dir" \
    XDG_DATA_HOME="$data_dir" \
    PATH="$path_dir" \
    "$BASH" "$launcher" --feature "$feature" \
    || fail "$browser failed to launch feature '$feature'"

  [[ -s "$result_file" ]] || fail "$browser did not receive launch arguments for '$feature'"
  mapfile -d '' -t args < "$result_file"

  if [[ "$browser" == "chromium" ]]; then
    [[ "${args[0]:-}" == --app=https://moonbat.ddns.net/* ]] \
      || fail "Chromium did not receive an app-mode URL for '$feature'"
    contains_arg "--new-window" "${args[@]}" || fail "Chromium omitted --new-window for '$feature'"
    contains_arg "--user-data-dir=$data_dir/maxnet-os/chromium" "${args[@]}" \
      || fail "Chromium did not use the persistent MaxOS profile for '$feature'"
    if [[ "$feature" == "home" ]]; then
      contains_arg "--class=maxnet-os" "${args[@]}" \
        || fail "Chromium window class was wrong for Home"
      contains_arg "--name=MaxOS" "${args[@]}" \
        || fail "Chromium window title was wrong for Home"
    else
      contains_arg "--class=maxnet-$feature" "${args[@]}" \
        || fail "Chromium window class was wrong for '$feature'"
      contains_arg "--name=MaxNet - $feature" "${args[@]}" \
        || fail "Chromium window title was wrong for '$feature'"
    fi
    url="${args[0]#--app=}"
  else
    [[ "${args[0]:-}" == "--kiosk" ]] || fail "Firefox omitted kiosk mode for '$feature'"
    contains_arg "--new-window" "${args[@]}" || fail "Firefox omitted --new-window for '$feature'"
    contains_arg "--profile" "${args[@]}" || fail "Firefox omitted its persistent profile for '$feature'"
    [[ "${args[3]:-}" == "$data_dir/maxnet-os/firefox" ]] \
      || fail "Firefox profile path was wrong for '$feature'"
    url="${args[4]:-}"
  fi

  if [[ "$feature" == "home" ]]; then
    [[ "$url" == "https://moonbat.ddns.net/?maxnet-os=1"* ]] \
      || fail "Home URL was wrong for $browser"
    [[ "$url" != *"maxnet-feature="* ]] || fail "Home unexpectedly had an app feature ID"
  else
    [[ "$url" == *"maxnet-feature=$feature"* ]] \
      || fail "$browser URL omitted the '$feature' route"
    [[ "$url" == *"maxnet-view=app"* ]] \
      || fail "$browser URL omitted app-only mode for '$feature'"
    [[ "$url" == *"maxnet-launch-id="* ]] \
      || fail "$browser URL omitted the launch ID for '$feature'"
  fi
}

for feature in "${features[@]}"; do
  run_and_check chromium "$chromium_path" "$feature"
  run_and_check firefox "$firefox_path" "$feature"
done
run_and_check chromium "$chromium_path" home
run_and_check firefox "$firefox_path" home

invalid_output="$tmp_dir/invalid-feature.out"
if MAXNET_URL="https://moonbat.ddns.net" \
  XDG_CONFIG_HOME="$tmp_dir/config-invalid" \
  XDG_DATA_HOME="$tmp_dir/data-invalid" \
  PATH="$chromium_path" \
  "$BASH" "$launcher" --feature not-a-maxnet-app >"$invalid_output" 2>&1; then
  fail "An unknown app feature unexpectedly launched"
fi
grep -Fq "Unknown MaxNet feature: not-a-maxnet-app" "$invalid_output" \
  || fail "An unknown feature did not produce a useful error"

no_browser_output="$tmp_dir/no-browser.out"
if MAXOS_TEST_XDG_ARGS="$tmp_dir/xdg-args" \
  MAXNET_URL="https://moonbat.ddns.net" \
  XDG_CONFIG_HOME="$tmp_dir/config-no-browser" \
  XDG_DATA_HOME="$tmp_dir/data-no-browser" \
  PATH="$no_browser_path" \
  "$BASH" "$launcher" --feature chat >"$no_browser_output" 2>&1; then
  fail "A MaxNet app unexpectedly launched without Chromium or Firefox"
fi
[[ ! -e "$tmp_dir/xdg-args" ]] \
  || fail "An app launcher fell back to a tabbed xdg-open browser"
grep -Fq "without browser controls" "$no_browser_output" \
  || fail "Missing-browser error did not explain the supported app browsers"

intro_video="$tmp_dir/intro.mp4"
intro_events="$tmp_dir/intro-events"
intro_args="$tmp_dir/intro-args"
: > "$intro_video"
MAXOS_TEST_EVENTS="$intro_events" \
  MAXOS_TEST_MPV_ARGS="$intro_args" \
  MAXNET_OS_INTRO_VIDEO="$intro_video" \
  XDG_CONFIG_HOME="$tmp_dir/config-first-run" \
  XDG_DATA_HOME="$tmp_dir/data-first-run" \
  PATH="$intro_path" \
  "$BASH" "$launcher" --first-run
mapfile -t intro_sequence < "$intro_events"
[[ "${intro_sequence[0]:-}" == "intro" && "${intro_sequence[1]:-}" == "setup-prompt" ]] \
  || fail "Unexpected first-run event order: ${intro_sequence[*]:-none}"
mapfile -d '' -t intro_player_args < "$intro_args"
contains_arg "--fullscreen" "${intro_player_args[@]}" \
  || fail "The intro video was not launched full-screen"
[[ -e "$tmp_dir/config-first-run/maxnet-os/setup-prompt-complete" ]] \
  || fail "First-run setup did not complete after the intro"

celluloid_events="$tmp_dir/celluloid-events"
celluloid_args="$tmp_dir/celluloid-args"
MAXOS_TEST_EVENTS="$celluloid_events" \
  MAXOS_TEST_CELLULOID_ARGS="$celluloid_args" \
  MAXNET_OS_INTRO_VIDEO="$intro_video" \
  XDG_CONFIG_HOME="$tmp_dir/config-celluloid-first-run" \
  XDG_DATA_HOME="$tmp_dir/data-celluloid-first-run" \
  PATH="$celluloid_path" \
  "$BASH" "$launcher" --first-run
mapfile -t celluloid_sequence < "$celluloid_events"
[[ "${celluloid_sequence[0]:-}" == "celluloid-intro" &&
   "${celluloid_sequence[1]:-}" == "setup-prompt" ]] \
  || fail "Celluloid fallback did not play before the setup prompt"
mapfile -d '' -t celluloid_player_args < "$celluloid_args"
contains_arg "--mpv-fullscreen=yes" "${celluloid_player_args[@]}" \
  || fail "Celluloid fallback was not launched full-screen"
contains_arg "$intro_video" "${celluloid_player_args[@]}" \
  || fail "Celluloid fallback did not receive the intro video"

: > "$intro_events"
rm -f "$intro_args"
MAXOS_TEST_EVENTS="$intro_events" \
  MAXOS_TEST_MPV_ARGS="$intro_args" \
  MAXNET_OS_INTRO_VIDEO="$intro_video" \
  XDG_CONFIG_HOME="$tmp_dir/config-first-run" \
  XDG_DATA_HOME="$tmp_dir/data-first-run" \
  PATH="$intro_path" \
  "$BASH" "$launcher" --first-run
if grep -Fq "intro" "$intro_events" || [[ -e "$intro_args" ]]; then
  fail "The intro video replayed after first-run setup was complete"
fi

printf 'PASS: %d MaxNet menu launchers plus Home work in Chromium app mode and Firefox kiosk mode.\n' \
  "${#features[@]}"
printf 'PASS: unknown features and unsupported browsers fail safely.\n'
printf 'PASS: first-run intro uses mpv or Celluloid before setup, once only.\n'
