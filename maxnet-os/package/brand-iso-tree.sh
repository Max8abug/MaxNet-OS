#!/usr/bin/env bash
set -euo pipefail

ISO_TREE="${1:?Usage: brand-iso-tree.sh ISO_TREE VERSION}"
VERSION="${2:?Usage: brand-iso-tree.sh ISO_TREE VERSION}"
PACKAGE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
logo_data_uri="data:image/png;base64,$(base64 -w 0 "$PACKAGE_ROOT/share/branding/maxnet-user-logo.png")"
sed -e "s|@MAXNET_LOGO_DATA_URI@|$logo_data_uri|g" \
  "$PACKAGE_ROOT/share/branding/maxos-iso-splash.svg.in" \
  > "$WORK/maxos-iso-splash.svg"

python3 - "$ISO_TREE" "$VERSION" <<'PY'
from pathlib import Path
import stat
import re
import sys

tree = Path(sys.argv[1])
version = sys.argv[2]

def replace_required(relative, replacements):
    path = tree / relative
    if not path.is_file():
        raise SystemExit(f"ISO boot file is missing: {relative}")
    text = path.read_text()
    for old, new in replacements.items():
        if old in text:
            text = text.replace(old, new)
        elif new not in text:
            raise SystemExit(f"Expected branding text not found in {relative}: {old}")
    path.chmod(path.stat().st_mode | stat.S_IWUSR)
    path.write_text(text)

def replace_versioned(relative, replacements):
    path = tree / relative
    if not path.is_file():
        raise SystemExit(f"ISO boot file is missing: {relative}")
    text = path.read_text()
    for pattern, replacement in replacements:
        text = re.sub(pattern, replacement, text)
    path.chmod(path.stat().st_mode | stat.S_IWUSR)
    path.write_text(text)

replace_versioned("boot/grub/grub.cfg", [
    (r"Start MaxOS [0-9.]+ Cinnamon 64-bit", f"Start MaxOS {version} Cinnamon 64-bit"),
])
replace_versioned("isolinux/live.cfg", [
    (r"menu title Welcome to MaxOS [0-9.]+ 64-bit", f"menu title Welcome to MaxOS {version} 64-bit"),
])

replace_required("boot/grub/grub.cfg", {
    "Start Linux Mint 22.3 Cinnamon 64-bit (compatibility mode)": (
        f"Start MaxOS {version} Cinnamon 64-bit (compatibility mode)"
    ),
    "Start Linux Mint 22.3 Cinnamon 64-bit": f"Start MaxOS {version} Cinnamon 64-bit",
})
replace_required("isolinux/live.cfg", {
    "Welcome to Linux Mint 22.3 64-bit": f"Welcome to MaxOS {version} 64-bit",
    "Start Linux Mint in compatibility mode": "Start MaxOS in compatibility mode",
    "Start Linux Mint": "Start MaxOS",
})
replace_required("isolinux/menu.cfg", {
    "menu title Boot menu": "menu title MaxOS boot menu",
})

disk_info = tree / ".disk/info"
if not disk_info.is_file():
    raise SystemExit("ISO metadata file is missing: .disk/info")
disk_info.chmod(disk_info.stat().st_mode | stat.S_IWUSR)
disk_info.write_text(f"MaxOS {version} Cinnamon 64-bit\n")
PY

command -v magick >/dev/null 2>&1 || {
  printf 'Required branding tool not found: magick\n' >&2
  exit 1
}
if [[ ! -f "$PACKAGE_ROOT/share/branding/boot-icon.png" ]]; then
  printf 'MaxOS boot icon is missing: %s\n' "$PACKAGE_ROOT/share/branding/boot-icon.png" >&2
  exit 1
fi
SPLASH640="$ISO_TREE/isolinux/splash.png"
SPLASH800="$ISO_TREE/isolinux/splash800x600.png"
if [[ ! -f "$SPLASH640" ]]; then
  printf 'ISO boot splash image is missing: %s\n' "$SPLASH640" >&2
  exit 1
fi
chmod u+w "$SPLASH640"
if [[ -f "$SPLASH800" ]]; then
  chmod u+w "$SPLASH800"
fi

render_splash() {
  local output="$1"
  local dimensions="$2"
  local icon_size="$3"
  local icon_x="$4"
  local icon_y="$5"

  magick -background none "$WORK/maxos-iso-splash.svg" \
    -resize "${dimensions}!" -alpha off -depth 8 -define png:color-type=2 \
    "$WORK/splash-base.png"
  magick "$PACKAGE_ROOT/share/branding/boot-icon.png" -trim +repage \
    -resize "${icon_size}x${icon_size}" -background none -gravity center \
    -extent "${icon_size}x${icon_size}" "$WORK/boot-icon.png"
  magick "$WORK/splash-base.png" "$WORK/boot-icon.png" \
    -gravity northwest -geometry "+${icon_x}+${icon_y}" -compose over -composite \
    -alpha off -depth 8 -define png:color-type=2 "$output"
}

render_splash "$SPLASH640" 640x480 70 278 163
if [[ -f "$SPLASH800" ]]; then
  render_splash "$SPLASH800" 800x600 88 348 204
fi

printf 'Applied MaxOS ISO labels under %s\n' "$ISO_TREE"
