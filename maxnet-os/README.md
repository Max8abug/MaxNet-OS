# MaxNet OS

MaxNet OS is an unofficial Linux Mint Cinnamon customization that adapts MaxNet's eight display themes into Cinnamon and GTK desktop themes and exposes MaxNet's apps in the Linux Mint application menu. The launchers open MaxNet in a dedicated app window, with each shortcut opening its matching MaxNet app.

This is a Linux Mint integration layer, not a new Linux kernel or a replacement for Mint. MaxNet remains the online service at `https://moonbat.ddns.net`; the OS does not bundle or self-host the MaxNet server.

## MaxNet themes as desktop themes

The OS theme chooser includes the same theme IDs as MaxNet:

- Classic light and dark
- Windows XP light and dark
- Windows Vista light and dark
- Gold picture frame
- Silver picture frame

The theme IDs and names match MaxNet's `THEME_OPTIONS`. Each desktop theme now includes native Cinnamon/Muffin window decorations, GTK 3/4 titlebars and controls, and opaque content surfaces, using the gradients, frame colors, and type styles from the matching MaxNet web theme. Native Linux cannot reproduce browser-only blur exactly, so Vista glass is rendered as an opaque, glossy frame instead of a see-through window. Choose **MaxNet OS Themes** from the application menu, or run `maxnet-os --choose-theme`. A first-login chooser appears until that local user picks a theme. The selected theme is passed to MaxNet when a launcher opens. If a signed-in user changes the theme in MaxNet, **Sync theme to MaxOS** asks the OS to confirm applying it locally.

## MaxNet applications in the Linux Mint menu

The menu includes sign-in, Chatroom, Forums, Direct Messages, Network Feed/People/Wiki, Photo Gallery, Users, Guestbook, Visitor Counter, Planner, Site News, Games, Eaglercraft, My Page Editor, Synced YouTube, Polls, Music Player, Playlists, Drawing Pad, and MaxNet Display Settings.

The **Sign in to MaxNet** launcher uses the normal MaxNet account dialog and keeps its session in a separate persistent browser profile. Linux Mint's own login remains local, so it works even when MaxNet is offline. Signed-in users can sync their MaxNet display theme to the local Cinnamon theme and wallpaper after confirming the change. The local OS login PIN/password is never sent to MaxNet or synced; it is managed by Linux Mint, and the same local credential is also used for `sudo`.

App launch supports sign-in, Chatroom, Forums, Direct Messages, Network, Eaglercraft, and the other MaxNet apps listed in the menu.

## Build the Linux Mint integration package

On Linux Mint or Debian with `dpkg-deb` installed:

```bash
./maxnet-os/package/build-deb.sh
sudo apt install ./maxnet-os/dist/maxnet-os_0.4.0_$(dpkg --print-architecture).deb
```

The launcher defaults to the confirmed MaxNet host. Use **MaxNet OS → Configure** (or run `maxnet-os configure`) to change it. A per-user override is stored under `~/.config/maxnet-os/settings.conf`; the chosen theme is stored separately in `~/.config/maxnet-os/theme`. This package never stores a MaxNet password or session token.

Use **Set Local OS PIN** from the application menu to run Mint's standard `passwd` tool. This changes the local account password used at restart and lock screen; Mint also uses it for `sudo`. It is not a separate short PIN credential and it is never checked by MaxNet. Keep at least one administrator account with a strong recovery password.

Chromium/Chrome/Brave opens MaxNet in a clean app window with a separate persistent profile. Firefox and the system browser are supported as fallbacks; those may show normal browser controls. Install Chromium for the closest standalone-app experience.

## MaxNet OS updates

Open **MaxNet OS Update Manager** from the application menu or run `maxnet-os --updates`. The manager checks the latest stable GitHub release, downloads the matching architecture-specific `.deb`, verifies its SHA-256 sidecar and GitHub asset digest (when available), confirms the package name/version, and asks PolicyKit before installing through `apt`. It does not pull or execute repository source code.

When MaxNet OS files are pushed or merged to `main`, GitHub Actions automatically builds the Debian package, adds a SHA-256 checksum, and publishes a stable GitHub release. Automatic versions use `maxnet-os/VERSION` plus the workflow run number (for example, `0.4.2+build.17`), so each OS change can be offered as an update without manually editing the version for every sync. Feature branches do not publish updates until they reach `main`.

For a deliberate versioned release, push a `v<VERSION>` tag that matches `maxnet-os/VERSION`; the same workflow publishes that exact version.

Restore the previous Cinnamon theme and wallpaper with:

```bash
maxnet-os --restore-system-theme
```

## Make a bootable Linux Mint remaster

This repository does not include or redistribute a Linux Mint ISO. To make a bootable image:

1. Download the Linux Mint edition/version and verify its published checksum.
2. Use Cubic on a Linux Mint/Ubuntu host to customize the official ISO.
3. In Cubic's terminal, install `zenity`, `python3`, `xdg-utils`, and Chromium if desired; copy and install the built `.deb`.
4. Choose the desired theme for the live-session user, then finish Cubic's ISO creation.
5. Boot the result in a VM first. Test sign-in, chat, forum, Network, Eaglercraft/WebGL, all eight themes, and live-installer behavior before installing it on a physical computer.

The first boot splash is stored in the ISO's initramfs as well as the live root filesystem. The branding scripts replace both the main Plymouth animation and its separate Mint throbber frames with the supplied MaxOS boot icon. After branding the root filesystem, run `package/brand-initramfs.sh /path/to/iso-tree/casper/initrd.lz /path/to/branded-rootfs` before rebuilding the ISO so the early boot image gets the same artwork.

Linux Mint and Cinnamon are upstream open-source projects. MaxNet OS is an unofficial derivative and is not endorsed by the Linux Mint project.
