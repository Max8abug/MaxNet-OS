#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$ROOT/VERSION")"
ARCH="$(dpkg --print-architecture)"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

install -Dm644 "$ROOT/package/DEBIAN/control" "$STAGE/DEBIAN/control"
sed -i "s/^Version: .*/Version: $VERSION/" "$STAGE/DEBIAN/control"

install -Dm755 "$ROOT/bin/maxnet-os" "$STAGE/usr/bin/maxnet-os"
install -Dm755 "$ROOT/bin/patch-maxnet-source" "$STAGE/usr/bin/maxnet-os-patch-source"
install -Dm644 "$ROOT/share/backgrounds/maxnet-os.svg" \
  "$STAGE/usr/share/backgrounds/maxnet-os.svg"

while IFS= read -r -d '' file; do
  relative="${file#"$ROOT/share/themes/MaxNet/"}"
  install -Dm644 "$file" "$STAGE/usr/share/themes/MaxNet/$relative"
done < <(find "$ROOT/share/themes/MaxNet" -type f -print0)

while IFS= read -r -d '' file; do
  install -Dm644 "$file" "$STAGE/usr/share/icons/hicolor/scalable/apps/$(basename "$file")"
done < <(find "$ROOT/share/icons" -type f -name '*.svg' -print0)

while IFS= read -r -d '' file; do
  install -Dm644 "$file" "$STAGE/usr/share/applications/$(basename "$file")"
done < <(find "$ROOT/share/applications" -type f -name '*.desktop' -print0)

install -Dm644 "$ROOT/share/maxnet-os/settings.conf" \
  "$STAGE/etc/maxnet-os/settings.conf"
install -Dm644 "$ROOT/patches/maxnet-feature-intents.patch" \
  "$STAGE/usr/share/maxnet-os/patches/maxnet-feature-intents.patch"

mkdir -p "$ROOT/dist"
dpkg-deb --root-owner-group --build "$STAGE" \
  "$ROOT/dist/maxnet-os_${VERSION}_${ARCH}.deb"
printf 'Built %s\n' "$ROOT/dist/maxnet-os_${VERSION}_${ARCH}.deb"
