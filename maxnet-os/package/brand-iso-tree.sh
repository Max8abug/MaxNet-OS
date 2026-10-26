#!/usr/bin/env bash
set -euo pipefail

ISO_TREE="${1:?Usage: brand-iso-tree.sh ISO_TREE VERSION}"
VERSION="${2:?Usage: brand-iso-tree.sh ISO_TREE VERSION}"
PACKAGE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 - "$ISO_TREE" "$VERSION" <<'PY'
from pathlib import Path
import stat
import sys

tree = Path(sys.argv[1])
version = sys.argv[2]

def replace_required(relative, replacements):
    path = tree / relative
    if not path.is_file():
        raise SystemExit(f"ISO boot file is missing: {relative}")
    text = path.read_text()
    for old, new in replacements.items():
        if old not in text:
            raise SystemExit(f"Expected branding text not found in {relative}: {old}")
        text = text.replace(old, new)
    path.chmod(path.stat().st_mode | stat.S_IWUSR)
    path.write_text(text)

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
SPLASH640="$ISO_TREE/isolinux/splash.png"
SPLASH800="$ISO_TREE/isolinux/splash800x600.png"
if [[ ! -f "$SPLASH640" ]]; then
  printf 'ISO boot splash image is missing: %s\n' "$SPLASH640" >&2
  exit 1
fi
chmod u+w "$SPLASH640"
magick -background none "$PACKAGE_ROOT/share/branding/maxos-iso-splash.svg" \
  -resize 640x480! -alpha off -depth 8 -define png:color-type=2 "$SPLASH640"
magick -background none "$PACKAGE_ROOT/share/branding/maxos-iso-splash.svg" \
  -resize 800x600! -alpha off -depth 8 -define png:color-type=2 "$SPLASH800"

printf 'Applied MaxOS ISO labels under %s\n' "$ISO_TREE"
