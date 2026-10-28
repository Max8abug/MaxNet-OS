#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
package="${1:?Usage: test-branding-assets.sh PACKAGE.deb}"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
dpkg-deb -x "$package" "$tmp_dir/package"

python3 - "$repo_root" "$tmp_dir/package" <<'PY'
from base64 import b64decode
from pathlib import Path
import sys
import xml.etree.ElementTree as ET

repo = Path(sys.argv[1])
package = Path(sys.argv[2])
logo = (repo / "maxnet-os/share/branding/maxnet-user-logo.png").read_bytes()
svg_ns = "{http://www.w3.org/2000/svg}"
xlink_href = "{http://www.w3.org/1999/xlink}href"

def verify_embedded_logo(path: Path) -> None:
    root = ET.parse(path).getroot()
    images = root.findall(f".//{svg_ns}image")
    if not images:
        raise SystemExit(f"SVG does not contain an embedded logo: {path}")
    for image in images:
        uri = image.attrib.get("href") or image.attrib.get(xlink_href, "")
        prefix = "data:image/png;base64,"
        if not uri.startswith(prefix):
            raise SystemExit(f"SVG has a non-embedded logo reference: {path}")
        if b64decode(uri[len(prefix):], validate=True) != logo:
            raise SystemExit(f"SVG logo differs from the supplied MaxNet artwork: {path}")

icon = package / "usr/share/icons/hicolor/scalable/apps/maxnet.svg"
background = package / "usr/share/backgrounds/maxnet-os.svg"
verify_embedded_logo(icon)
verify_embedded_logo(background)

theme_backgrounds = sorted(
    (package / "usr/share/backgrounds").glob("maxnet-os-*.svg")
)
if len(theme_backgrounds) != 8:
    raise SystemExit(f"Expected 8 themed wallpapers, found {len(theme_backgrounds)}")
for wallpaper in theme_backgrounds:
    verify_embedded_logo(wallpaper)

installed_logo = package / "usr/share/maxnet-os/maxnet-user-logo.png"
if installed_logo.read_bytes() != logo:
    raise SystemExit("Packaged MaxNet logo asset does not match the repository source")

fallback_icon = package / "usr/share/icons/hicolor/128x128/apps/maxnet-os-start.png"
if fallback_icon.read_bytes() != logo:
    raise SystemExit("Packaged Start-menu fallback icon does not match the supplied MaxNet logo")

for relative in (
    "maxnet-os/share/icons/maxnet.svg.in",
    "maxnet-os/share/backgrounds/maxnet-os.svg.in",
    "maxnet-os/share/themes/templates/wallpaper.svg.in",
    "maxnet-os/share/branding/maxos-iso-splash.svg.in",
):
    template = (repo / relative).read_text()
    if "@MAXNET_LOGO_DATA_URI@" not in template:
        raise SystemExit(f"Logo placeholder is missing from template: {relative}")

splash_template = repo / "maxnet-os/share/branding/maxos-iso-splash.svg.in"
splash_root = ET.parse(splash_template).getroot()
splash_images = splash_root.findall(f".//{svg_ns}image")
if not any(
    image.attrib.get("href") == "@MAXNET_LOGO_DATA_URI@"
    or image.attrib.get(xlink_href) == "@MAXNET_LOGO_DATA_URI@"
    for image in splash_images
):
    raise SystemExit("ISO splash does not use the supplied MaxNet logo")

print("PASS: MaxNet logo is embedded in the OS icon, default wallpaper, and all 8 theme wallpapers.")
PY
