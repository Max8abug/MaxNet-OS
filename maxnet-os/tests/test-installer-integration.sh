#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

python3 - "$repo_root" <<'PY'
from pathlib import Path
import ast
import sys
import xml.etree.ElementTree as ET

root = Path(sys.argv[1])
plugin_path = root / "maxnet-os/share/ubiquity/plugins/maxos-account.py"
plugin_text = plugin_path.read_text(encoding="utf-8")
plugin_tree = ast.parse(plugin_text)
constants = {
    node.targets[0].id: ast.literal_eval(node.value)
    for node in plugin_tree.body
    if isinstance(node, ast.Assign)
    and len(node.targets) == 1
    and isinstance(node.targets[0], ast.Name)
}
if constants.get("NAME") != "maxos_account" or constants.get("AFTER") != "network":
    raise SystemExit("The MaxOS account page is not ordered after Mint's final network step")
if constants.get("WEIGHT") != 100:
    raise SystemExit("The MaxOS account page priority changed unexpectedly")
if "plugin_is_install = True" not in plugin_text:
    raise SystemExit("Ubiquity will not present its install action on the final MaxOS step")
if "misc.launch_uri(maxnet_url())" not in plugin_text:
    raise SystemExit("The MaxNet sign-in action is not connected")

ui_path = root / "maxnet-os/share/ubiquity/gtk/stepMaxosAccount.ui"
ui_root = ET.parse(ui_path).getroot()
object_ids = {
    obj.attrib["id"]
    for obj in ui_root.iter("object")
    if "id" in obj.attrib
}
for required in ("stepMaxosAccount", "maxnet_sign_in_button", "maxnet_account_offline_note"):
    if required not in object_ids:
        raise SystemExit(f"Ubiquity installer page is missing widget {required}")
if "maxnet</property>" not in ui_path.read_text(encoding="utf-8"):
    raise SystemExit("The MaxOS account page is missing the MaxNet logo")

preview = (root / "maxnet-os/bin/maxos-installer-preview").read_text(encoding="utf-8")
if "is_local_admin" not in preview or "sudo" not in preview or "wheel" not in preview:
    raise SystemExit("The installer preview is not restricted to local administrators")
if "Simulation only" not in preview or "No changes will be made" not in preview:
    raise SystemExit("The installer preview does not clearly identify its non-destructive mode")
if "maxos-intro.mp4" not in preview or "maxnet-feature" not in preview:
    raise SystemExit("The installer preview is missing its video or account test action")
launcher = (root / "maxnet-os/share/applications/maxnet-os-installer-preview.desktop").read_text()
if "Categories=X-MaxOS-System;" not in launcher or "Exec=maxos-installer-preview" not in launcher:
    raise SystemExit("The preview launcher is not available in the MaxOS System menu")
print("PASS: Ubiquity plugin, final-step UI, admin preview, account action, and video test are present.")
PY

bash -n "$repo_root/maxnet-os/package/brand-iso-tree.sh"
PYTHONPYCACHEPREFIX="$tmp_dir/pycache" python3 -m py_compile \
  "$repo_root/maxnet-os/share/ubiquity/plugins/maxos-account.py" \
  "$repo_root/maxnet-os/bin/maxos-installer-preview"

fixture="$tmp_dir/iso-tree"
mkdir -p "$fixture/boot/grub" "$fixture/isolinux" "$fixture/.disk"
cat > "$fixture/boot/grub/grub.cfg" <<'GRUB'
menuentry "Start Linux Mint 22.3 Cinnamon 64-bit" --class linuxmint {
    linux /casper/vmlinuz boot=casper username=mint quiet splash --
    initrd /casper/initrd.lz
}
menuentry "Start Linux Mint 22.3 Cinnamon 64-bit (compatibility mode)" {
    linux /casper/vmlinuz boot=casper nomodeset --
    initrd /casper/initrd.lz
}
menuentry "OEM install (for manufacturers)" {
    linux /casper/vmlinuz oem-config/enable=true only-ubiquity boot=casper --
    initrd /casper/initrd.lz
}
GRUB
cat > "$fixture/isolinux/live.cfg" <<'SYSLINUX'
menu title Welcome to Linux Mint 22.3 64-bit
label live
    menu label Start Linux Mint
    menu default
    kernel /casper/vmlinuz
    append boot=casper initrd=/casper/initrd.lz username=mint quiet splash --
label compat
    menu label Start Linux Mint in compatibility mode
    linux /casper/vmlinuz
    append boot=casper nomodeset --
SYSLINUX
printf 'menu title Boot menu\ninclude stdmenu.cfg\n' > "$fixture/isolinux/menu.cfg"
printf 'source ISO metadata\n' > "$fixture/.disk/info"
printf 'source splash\n' > "$fixture/isolinux/splash.png"

mkdir -p "$tmp_dir/mock-bin"
cat > "$tmp_dir/mock-bin/magick" <<'MAGICK'
#!/bin/sh
for output do :; done
printf 'test image\n' > "$output"
MAGICK
chmod +x "$tmp_dir/mock-bin/magick"

PATH="$tmp_dir/mock-bin:$PATH" \
  "$repo_root/maxnet-os/package/brand-iso-tree.sh" "$fixture" 0.4.15 >/dev/null

python3 - "$fixture" <<'PY'
from pathlib import Path
import sys

root = Path(sys.argv[1])
grub = (root / "boot/grub/grub.cfg").read_text()
grub_install = grub.split('menuentry "Install MaxOS', 1)[1].split("\n}", 1)[0]
grub_compat = grub.split('menuentry "Try MaxOS desktop', 1)[1].split("\n}", 1)[0]
if "only-ubiquity" not in grub_install:
    raise SystemExit("GRUB default does not boot directly into the installer")
if "only-ubiquity" in grub_compat:
    raise SystemExit("GRUB compatibility entry no longer provides a live desktop")

syslinux = (root / "isolinux/live.cfg").read_text()
live_block = syslinux.split("label live", 1)[1].split("\nlabel ", 1)[0]
compat_block = syslinux.split("label compat", 1)[1]
if "only-ubiquity" not in live_block:
    raise SystemExit("Syslinux default does not boot directly into the installer")
if "only-ubiquity" in compat_block:
    raise SystemExit("Syslinux compatibility entry no longer provides a live desktop")
print("PASS: GRUB and Syslinux boot to the installer by default and preserve a live desktop fallback.")
PY
