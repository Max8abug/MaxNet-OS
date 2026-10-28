#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$ROOT/VERSION")"
ARCH="$(dpkg --print-architecture)"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
logo_data_uri="data:image/png;base64,$(base64 -w 0 "$ROOT/share/branding/maxnet-user-logo.png")"
mkdir -p "$STAGE/usr/share/backgrounds" "$STAGE/usr/share/icons/hicolor/scalable/apps"

install -Dm644 "$ROOT/package/DEBIAN/control" "$STAGE/DEBIAN/control"
sed -i "s/^Version: .*/Version: $VERSION/" "$STAGE/DEBIAN/control"
install -Dm755 "$ROOT/package/DEBIAN/postinst" "$STAGE/DEBIAN/postinst"

install -Dm755 "$ROOT/bin/maxnet-os" "$STAGE/usr/bin/maxnet-os"
install -Dm755 "$ROOT/bin/maxnet-os-sync-logo" "$STAGE/usr/bin/maxnet-os-sync-logo"
install -Dm755 "$ROOT/bin/maxos-installer-preview" \
  "$STAGE/usr/bin/maxos-installer-preview"
install -Dm644 "$ROOT/VERSION" "$STAGE/usr/share/maxnet-os/VERSION"
install -Dm644 "$ROOT/share/branding/maxnet-user-logo.png" \
  "$STAGE/usr/share/maxnet-os/maxnet-user-logo.png"
install -Dm644 "$ROOT/share/themes/maxos-installer.css" \
  "$STAGE/usr/share/maxnet-os/maxos-installer.css"
install -Dm644 "$ROOT/share/ubiquity/plugins/maxos-account.py" \
  "$STAGE/usr/lib/ubiquity/plugins/maxos-account.py"
install -Dm644 "$ROOT/share/ubiquity/gtk/stepMaxosAccount.ui" \
  "$STAGE/usr/share/ubiquity/gtk/stepMaxosAccount.ui"
install -Dm644 "$ROOT/share/applications/features.tsv" \
  "$STAGE/usr/share/maxnet-os/features.tsv"
sed -e "s|@MAXNET_LOGO_DATA_URI@|$logo_data_uri|g" \
  "$ROOT/share/backgrounds/maxnet-os.svg.in" \
  > "$STAGE/usr/share/backgrounds/maxnet-os.svg"
install -Dm644 "$ROOT/share/videos/maxos-intro.mp4" \
  "$STAGE/usr/share/maxnet-os/maxos-intro.mp4"

while IFS='|' read -r theme_id label bg fg accent surface border accent_fg font_family frame radius panel_bg button_bg title_top title_mid title_bottom title_text inactive_top inactive_bottom inactive_text close_bg frame_highlight frame_shadow wm_edge control_radius title_radius; do
  [[ -n "$theme_id" && "$theme_id" != \#* ]] || continue
  theme_name="MaxNet-$theme_id"
  theme_dir="$STAGE/usr/share/themes/$theme_name"
  install -d "$theme_dir/cinnamon" "$theme_dir/gtk-3.0" "$theme_dir/gtk-4.0" "$theme_dir/metacity-1"
  cat > "$theme_dir/index.theme" <<EOF
[Desktop Entry]
Name=$theme_name
Comment=MaxNet $label desktop theme
Type=X-GNOME-Metatheme
Encoding=UTF-8
GtkTheme=$theme_name
MetacityTheme=$theme_name
EOF
  for template in cinnamon/cinnamon.css gtk-3.0/gtk.css gtk-4.0/gtk.css; do
    sed \
      -e "s|@BG@|$bg|g" \
      -e "s|@FG@|$fg|g" \
      -e "s|@ACCENT@|$accent|g" \
      -e "s|@SURFACE@|$surface|g" \
      -e "s|@BORDER@|$border|g" \
      -e "s|@ACCENT_FG@|$accent_fg|g" \
      -e "s|@FONT@|$font_family|g" \
      -e "s|@FRAME@|$frame|g" \
      -e "s|@RADIUS@|$radius|g" \
      -e "s|@PANEL_BG@|$panel_bg|g" \
      -e "s|@BUTTON_BG@|$button_bg|g" \
      -e "s|@TITLE_TOP@|$title_top|g" \
      -e "s|@TITLE_MID@|$title_mid|g" \
      -e "s|@TITLE_BOTTOM@|$title_bottom|g" \
      -e "s|@TITLE_TEXT@|$title_text|g" \
      -e "s|@INACTIVE_TOP@|$inactive_top|g" \
      -e "s|@INACTIVE_BOTTOM@|$inactive_bottom|g" \
      -e "s|@INACTIVE_TEXT@|$inactive_text|g" \
      -e "s|@CLOSE_BG@|$close_bg|g" \
      -e "s|@FRAME_HIGHLIGHT@|$frame_highlight|g" \
      -e "s|@FRAME_SHADOW@|$frame_shadow|g" \
      -e "s|@WM_EDGE@|$wm_edge|g" \
      -e "s|@CONTROL_RADIUS@|$control_radius|g" \
      -e "s|@TITLE_RADIUS@|$title_radius|g" \
      "$ROOT/share/themes/templates/${template##*/}.in" > "$theme_dir/$template"
  done
  sed \
    -e "s|@BG@|$bg|g" \
    -e "s|@FG@|$fg|g" \
    -e "s|@ACCENT@|$accent|g" \
    -e "s|@SURFACE@|$surface|g" \
    -e "s|@BORDER@|$border|g" \
    -e "s|@ACCENT_FG@|$accent_fg|g" \
    -e "s|@FONT@|$font_family|g" \
    -e "s|@FRAME@|$frame|g" \
    -e "s|@RADIUS@|$radius|g" \
    -e "s|@PANEL_BG@|$panel_bg|g" \
    -e "s|@BUTTON_BG@|$button_bg|g" \
    -e "s|@MAXNET_LOGO_DATA_URI@|$logo_data_uri|g" \
    "$ROOT/share/themes/templates/wallpaper.svg.in" \
    > "$STAGE/usr/share/backgrounds/maxnet-os-$theme_id.svg"

  sed \
    -e "s|@TITLE_TOP@|$title_top|g" \
    -e "s|@TITLE_MID@|$title_mid|g" \
    -e "s|@TITLE_BOTTOM@|$title_bottom|g" \
    -e "s|@FRAME_HIGHLIGHT@|$frame_highlight|g" \
    -e "s|@BORDER@|$border|g" \
    "$ROOT/share/themes/templates/metacity-titlebar.svg.in" \
    > "$theme_dir/metacity-1/titlebar-active.svg"
  sed \
    -e "s|@TITLE_TOP@|$inactive_top|g" \
    -e "s|@TITLE_MID@|$inactive_bottom|g" \
    -e "s|@TITLE_BOTTOM@|$inactive_bottom|g" \
    -e "s|@FRAME_HIGHLIGHT@|$border|g" \
    -e "s|@BORDER@|$frame_shadow|g" \
    "$ROOT/share/themes/templates/metacity-titlebar.svg.in" \
    > "$theme_dir/metacity-1/titlebar-inactive.svg"
  sed \
    -e "s|@BORDER@|$border|g" \
    -e "s|@SURFACE@|$surface|g" \
    -e "s|@FG@|$fg|g" \
    -e "s|@ACCENT@|$accent|g" \
    -e "s|@TITLE_TEXT@|$title_text|g" \
    -e "s|@INACTIVE_TEXT@|$inactive_text|g" \
    -e "s|@BUTTON_BG@|$surface|g" \
    -e "s|@BUTTON_HOVER@|$accent|g" \
    -e "s|@CLOSE_BG@|$close_bg|g" \
    -e "s|@FRAME_HIGHLIGHT@|$frame_highlight|g" \
    -e "s|@FRAME_SHADOW@|$frame_shadow|g" \
    -e "s|@WM_EDGE@|$wm_edge|g" \
    "$ROOT/share/themes/templates/metacity-theme-3.xml.in" \
    > "$theme_dir/metacity-1/metacity-theme-3.xml"
done < "$ROOT/share/themes/palette.tsv"

while IFS= read -r -d '' file; do
  install -Dm644 "$file" "$STAGE/usr/share/icons/hicolor/scalable/apps/$(basename "$file")"
done < <(find "$ROOT/share/icons" -type f -name '*.svg' -print0)

sed -e "s|@MAXNET_LOGO_DATA_URI@|$logo_data_uri|g" \
  "$ROOT/share/icons/maxnet.svg.in" \
  > "$STAGE/usr/share/icons/hicolor/scalable/apps/maxnet.svg"

install -Dm644 "$ROOT/share/branding/maxnet-user-logo.png" \
  "$STAGE/usr/share/icons/hicolor/128x128/apps/maxnet-os-start.png"

while IFS= read -r -d '' file; do
  install -Dm644 "$file" "$STAGE/usr/share/applications/$(basename "$file")"
done < <(find "$ROOT/share/applications" -type f -name '*.desktop' -print0)

while IFS= read -r -d '' file; do
  install -Dm644 "$file" "$STAGE/etc/xdg/autostart/$(basename "$file")"
done < <(find "$ROOT/share/autostart" -type f -name '*.desktop' -print0)

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
StartupWMClass=maxnet-$feature
EOF
done < "$ROOT/share/applications/features.tsv"

install -Dm644 "$ROOT/share/menus/maxnet-os.menu" \
  "$STAGE/etc/xdg/menus/applications-merged/maxnet-os.menu"
install -Dm644 "$ROOT/share/desktop-directories/maxnet-os.directory" \
  "$STAGE/usr/share/desktop-directories/maxnet-os.directory"
install -Dm644 "$ROOT/share/desktop-directories/maxnet-os-system.directory" \
  "$STAGE/usr/share/desktop-directories/maxnet-os-system.directory"

install -Dm644 "$ROOT/share/maxnet-os/settings.conf" \
  "$STAGE/etc/maxnet-os/settings.conf"

mkdir -p "$ROOT/dist"
dpkg-deb --root-owner-group --build "$STAGE" \
  "$ROOT/dist/maxnet-os_${VERSION}_${ARCH}.deb"
printf 'Built %s\n' "$ROOT/dist/maxnet-os_${VERSION}_${ARCH}.deb"
