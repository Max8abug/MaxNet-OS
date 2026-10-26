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
install -Dm644 "$ROOT/share/backgrounds/maxnet-os.svg" \
  "$STAGE/usr/share/backgrounds/maxnet-os.svg"

while IFS='|' read -r theme_id label bg fg accent surface border accent_fg; do
  [[ -n "$theme_id" && "$theme_id" != \#* ]] || continue
  theme_name="MaxNet-$theme_id"
  theme_dir="$STAGE/usr/share/themes/$theme_name"
  install -d "$theme_dir/cinnamon" "$theme_dir/gtk-3.0" "$theme_dir/gtk-4.0"
  cat > "$theme_dir/index.theme" <<EOF
[Desktop Entry]
Name=$theme_name
Comment=MaxNet $label desktop theme
Type=X-GNOME-Metatheme
Encoding=UTF-8
GtkTheme=$theme_name
EOF
  for template in cinnamon/cinnamon.css gtk-3.0/gtk.css gtk-4.0/gtk.css; do
    sed \
      -e "s|@BG@|$bg|g" \
      -e "s|@FG@|$fg|g" \
      -e "s|@ACCENT@|$accent|g" \
      -e "s|@SURFACE@|$surface|g" \
      -e "s|@BORDER@|$border|g" \
      -e "s|@ACCENT_FG@|$accent_fg|g" \
      "$ROOT/share/themes/templates/${template##*/}.in" > "$theme_dir/$template"
  done
  sed \
    -e "s|@BG@|$bg|g" \
    -e "s|@FG@|$fg|g" \
    -e "s|@ACCENT@|$accent|g" \
    -e "s|@SURFACE@|$surface|g" \
    -e "s|@BORDER@|$border|g" \
    -e "s|@ACCENT_FG@|$accent_fg|g" \
    "$ROOT/share/themes/templates/wallpaper.svg.in" \
    > "$STAGE/usr/share/backgrounds/maxnet-os-$theme_id.svg"
done < "$ROOT/share/themes/palette.tsv"

while IFS= read -r -d '' file; do
  install -Dm644 "$file" "$STAGE/usr/share/icons/hicolor/scalable/apps/$(basename "$file")"
done < <(find "$ROOT/share/icons" -type f -name '*.svg' -print0)

while IFS= read -r -d '' file; do
  install -Dm644 "$file" "$STAGE/usr/share/applications/$(basename "$file")"
done < <(find "$ROOT/share/applications" -type f -name '*.desktop' -print0)

while IFS='|' read -r feature label icon category comment; do
  [[ -n "$feature" && "$feature" != \#* ]] || continue
  desktop_id="maxnet-${feature}.desktop"
  cat > "$STAGE/usr/share/applications/$desktop_id" <<EOF
[Desktop Entry]
Type=Application
Name=$label
Comment=$comment
Exec=maxnet-os --feature $feature
Icon=$icon
Terminal=false
Categories=$category;
StartupNotify=true
EOF
done < "$ROOT/share/applications/features.tsv"

install -Dm644 "$ROOT/share/maxnet-os/settings.conf" \
  "$STAGE/etc/maxnet-os/settings.conf"

mkdir -p "$ROOT/dist"
dpkg-deb --root-owner-group --build "$STAGE" \
  "$ROOT/dist/maxnet-os_${VERSION}_${ARCH}.deb"
printf 'Built %s\n' "$ROOT/dist/maxnet-os_${VERSION}_${ARCH}.deb"
