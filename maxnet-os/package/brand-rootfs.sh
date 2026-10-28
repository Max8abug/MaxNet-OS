#!/usr/bin/env bash
set -euo pipefail

ROOTFS="${1:?Usage: brand-rootfs.sh ROOTFS}"
PACKAGE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$PACKAGE_ROOT/VERSION")"
PLYMOUTH_DIR="$ROOTFS/usr/share/plymouth/themes/mint-logo"
BRANDING_DIR="$PACKAGE_ROOT/share/branding"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
logo_data_uri="data:image/png;base64,$(base64 -w 0 "$PACKAGE_ROOT/share/branding/maxnet-user-logo.png")"

for command_name in magick python3; do
  command -v "$command_name" >/dev/null 2>&1 || {
    printf 'Required branding tool not found: %s\n' "$command_name" >&2
    exit 1
  }
done

test -d "$ROOTFS"
test -d "$PLYMOUTH_DIR"

magick -background none -density 144 "$BRANDING_DIR/maxos-boot.svg" \
  -resize 560x192 "$WORK/maxos-boot-base.png"
magick "$BRANDING_DIR/boot-icon.png" -trim +repage -resize 50x50 \
  -background none -gravity center -extent 50x50 "$WORK/boot-icon.png"
magick "$BRANDING_DIR/boot-icon.png" -trim +repage -resize 88x88 \
  -background none -gravity center -extent 100x100 "$WORK/maxos-throbber.png"
magick "$WORK/maxos-boot-base.png" "$WORK/boot-icon.png" \
  -gravity northwest -geometry +26+54 -compose over -composite \
  "$WORK/maxos-boot.png"
sed -e "s|@MAXNET_LOGO_DATA_URI@|$logo_data_uri|g" \
  "$PACKAGE_ROOT/share/backgrounds/maxnet-os.svg.in" > "$WORK/maxnet-os.svg"
magick "$WORK/maxnet-os.svg" -quality 88 "$WORK/maxos-login.jpg"

install -Dm644 "$WORK/maxos-boot.png" "$PLYMOUTH_DIR/animation-0001.png"
for frame in $(seq -w 2 36); do
  install -m644 "$WORK/maxos-boot.png" "$PLYMOUTH_DIR/animation-00${frame}.png"
done
for frame in $(seq -w 1 30); do
  install -m644 "$WORK/maxos-throbber.png" "$PLYMOUTH_DIR/throbber-00${frame}.png"
done
install -m644 "$WORK/maxos-boot.png" "$PLYMOUTH_DIR/bgrt-fallback.png"
install -Dm644 "$WORK/maxos-login.jpg" \
  "$ROOTFS/usr/share/backgrounds/maxos-login.jpg"
sed -e "s|@MAXNET_LOGO_DATA_URI@|$logo_data_uri|g" \
  "$PACKAGE_ROOT/share/icons/maxnet.svg.in" > "$WORK/maxnet.svg"
install -Dm644 "$WORK/maxnet.svg" \
  "$ROOTFS/usr/share/icons/hicolor/scalable/apps/maxos.svg"

python3 - "$ROOTFS" "$VERSION" <<'PY'
from pathlib import Path
import sys

root = Path(sys.argv[1])
version = sys.argv[2]

def set_values(relative, values):
    path = root / relative
    lines = path.read_text().splitlines()
    for key, value in values.items():
        prefix = key + "="
        matches = [index for index, line in enumerate(lines) if line.startswith(prefix)]
        replacement = prefix + value
        if matches:
            lines[matches[0]] = replacement
            for index in reversed(matches[1:]):
                del lines[index]
        else:
            lines.append(replacement)
    path.write_text("\n".join(lines) + "\n")

set_values("etc/os-release", {
    "NAME": '"MaxOS"',
    "VERSION": f'"{version}"',
    "PRETTY_NAME": f'"MaxOS {version}"',
    "LOGO": "maxos",
})
set_values("etc/lsb-release", {
    "DISTRIB_ID": "MaxOS",
    "DISTRIB_DESCRIPTION": f'"MaxOS {version}"',
})
set_values("etc/linuxmint/info", {
    "DESCRIPTION": f'"MaxOS {version}"',
    "GRUB_TITLE": f'"MaxOS {version} Cinnamon"',
})

(root / "etc/issue").write_text(f"MaxOS {version} \\n \\l\n")
(root / "etc/issue.net").write_text(f"MaxOS {version}\n")

greeter = root / "etc/lightdm/lightdm-gtk-greeter.conf.d/99_linuxmint.conf"
greeter_text = greeter.read_text()
greeter_text = greeter_text.replace(
    "background=/usr/share/backgrounds/linuxmint/default_background.jpg",
    "background=/usr/share/backgrounds/maxos-login.jpg",
)
greeter.write_text(greeter_text)

plymouth = root / "usr/share/plymouth/themes/mint-logo/mint-logo.plymouth"
plymouth_text = plymouth.read_text()
def set_config_values(text, values):
    lines = text.splitlines()
    for key, value in values.items():
        prefix = key + "="
        matches = [index for index, line in enumerate(lines) if line.startswith(prefix)]
        replacement = prefix + value
        if matches:
            lines[matches[0]] = replacement
            for index in reversed(matches[1:]):
                del lines[index]
        else:
            lines.append(replacement)
    return "\n".join(lines) + "\n"

plymouth_text = set_config_values(plymouth_text, {
    "Name": "MaxOS",
    "Description": "MaxOS startup screen in the MaxNet classic desktop style",
    "BackgroundStartColor": "0x087f7e",
    "BackgroundEndColor": "0x004f57",
    "ProgressBarForegroundColor": "0xf4bd59",
})
plymouth.write_text(plymouth_text)

def replace_in(relative, replacements):
    path = root / relative
    if not path.exists():
        return
    text = path.read_text()
    for old, new in replacements.items():
        text = text.replace(old, new)
    path.write_text(text)

replace_in("etc/xdg/autostart/mintwelcome.desktop", {
    "Comment=Linux Mint Welcome Screen": "Comment=MaxOS welcome is shown at first login",
})
welcome_autostart = root / "etc/xdg/autostart/mintwelcome.desktop"
if welcome_autostart.exists() and "Hidden=true" not in welcome_autostart.read_text():
    with welcome_autostart.open("a") as stream:
        stream.write("Hidden=true\n")

welcome_menu = root / "usr/share/applications/mintwelcome.desktop"
if welcome_menu.exists():
    text = welcome_menu.read_text()
    if "NoDisplay=true" not in text:
        text += "\nNoDisplay=true\n"
    welcome_menu.write_text(text)

for relative in (
    "etc/xdg/autostart/mintupdate.desktop",
    "usr/share/applications/mintupdate.desktop",
):
    replace_in(relative, {"Linux Mint Update Manager": "MaxOS Update Manager"})

replace_in("usr/share/applications/ubiquity.desktop", {
    "Icon=mintubiquity": "Icon=maxnet",
    "Comment[bg]=Инсталиране Linux Mint трайно на твърдия диск": (
        "Comment[bg]=Инсталиране MaxOS трайно на твърдия диск"
    ),
})
replace_in("etc/init/ubiquity.conf", {
    "Linux Mint live CD installer": "MaxOS live installer",
    "Installs Linux Mint from a live CD.": "Installs MaxOS from a live image.",
})

misc = root / "usr/lib/ubiquity/ubiquity/misc.py"
if misc.exists():
    text = misc.read_text()
    text = text.replace(
        "get_release.release_info = ReleaseInfo(name='Linux Mint', version='')",
        "get_release.release_info = ReleaseInfo(name='MaxOS', version='')",
    )
    text = text.replace(
        "get_release_name.release_name = 'Linux Mint'",
        "get_release_name.release_name = 'MaxOS'",
    )
    old_release_line = (
        '                    get_release.release_info = ReleaseInfo(name=" ".join(line[0:2]), version=line[2])'
    )
    if old_release_line in text and 'if line[0] == "MaxOS":' not in text:
        text = text.replace(
            old_release_line,
            '                    if line[0] == "MaxOS":\n'
            '                        get_release.release_info = ReleaseInfo(name="MaxOS", version=line[1] if len(line) > 1 else "")\n'
            '                    else:\n'
            + "    "
            + old_release_line,
        )
    text = text.replace(
        "                    if line[2] == 'LTS':",
        "                    if line[0] == 'MaxOS':\n"
        "                        get_release_name.release_name = 'MaxOS'\n"
        "                    elif line[2] == 'LTS':",
    )
    misc.write_text(text)

ui_replacements = {
    "Linux Mint": "MaxOS",
    "MaxOS 11.04": "MaxOS",
    "MaxOS to 11.10": "MaxOS to the current version",
}
for path in (root / "usr/share/ubiquity/gtk").glob("*.ui"):
    text = path.read_text()
    for old, new in ui_replacements.items():
        text = text.replace(old, new)
    path.write_text(text)

slides = root / "usr/share/ubiquity-slideshow/slides"
if slides.exists():
    for path in slides.rglob("*.html"):
        text = path.read_text()
        path.write_text(text.replace("Linux Mint", "MaxOS"))
PY

printf 'Applied MaxOS user-facing branding to %s\n' "$ROOTFS"
