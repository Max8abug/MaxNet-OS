# MaxOS

MaxOS is an unofficial Linux Mint Cinnamon customization that adapts MaxNet's eight display themes into Cinnamon and GTK desktop themes and exposes MaxNet's apps in a dedicated **MaxNet** section of the Start menu. Local tools live in a separate **System** section. The launchers open MaxNet in a dedicated app window, with each shortcut opening its matching MaxNet app.

This is a Linux Mint integration layer, not a new Linux kernel or a replacement for Mint. MaxNet remains the online service at `https://moonbat.ddns.net`; the OS does not bundle or self-host the MaxNet server.

## MaxNet themes as desktop themes

The OS theme chooser includes the same theme IDs as MaxNet:

- Classic light and dark
- Windows XP light and dark
- Windows Vista light and dark
- Gold picture frame
- Silver picture frame

The theme IDs and names match MaxNet's `THEME_OPTIONS`. Each desktop theme includes coordinated Cinnamon taskbar/menu styling, native Muffin window decorations, GTK 3/4 titlebars and controls, and opaque content surfaces. The supplied cat logo is used across the MaxOS identity icon and desktop backgrounds; its transparent mark keeps the original magenta detail against each theme. The Start button uses the supplied MaxOS logo by default, uses the logo configured in MaxNet site settings when available, and keeps that site logo cached for offline use. If the logo changes, MaxOS refreshes the panel branding without requiring a full logout. Vista glass is rendered as an opaque, glossy frame instead of a see-through window. Choose **MaxOS Themes** from Start → System, or run `maxnet-os --choose-theme`. If account sync is skipped, a first-login chooser offers a local theme. The selected theme is passed to MaxNet when a launcher opens.

## MaxNet applications in the MaxOS Start menu

All 22 MaxNet feature launchers appear together in the **MaxNet** section in Start: sign-in, Chatroom, Forums, Direct Messages, Network Feed/People/Wiki, Photo Gallery, Users, Guestbook, Visitor Counter, Planner, Site News, Games, Eaglercraft, My Page Editor, Synced YouTube, Polls, Music Player, Playlists, Drawing Pad, and MaxNet Display Settings. Account sync and the MaxOS desktop launcher are grouped there too. **System** separately contains Files, System Settings, local theme controls, updates, and device configuration.

## First-run welcome intro

On the first Cinnamon login after installation, MaxOS plays the bundled MaxNet intro video full-screen before showing the sign-in and theme setup prompts. The video is stored locally, so it also plays when the MaxNet server is offline. MaxOS uses `mpv` when available, then falls back to Celluloid on the Mint live system; the fallback closes after the six-second clip. Press **Q** or **Esc** to skip. It does not replay after the first-run setup marker is created.

## MaxNet account settings during setup

On first desktop startup, MaxOS offers to sign in to MaxNet and sync the signed-in account's display theme, profile background, timezone, rank, MaxNet permissions, and currently available MaxNet apps. The website uses its normal login dialog. The MaxOS sync helper receives only an expiring, one-time authorization code and settings snapshot; it never handles the MaxNet password or browser session. The browser stores sign-in locally so MaxNet apps can stay signed in. Review and confirm the settings on the computer before applying them. MaxOS does not change the Linux system timezone; MaxNet continues to use the account's timezone preference inside its apps. Use **Sync MaxNet Account** in the Start menu or run `maxnet-os --sync-account` to refresh the snapshot later.

Synced app availability controls MaxOS's launcher visibility, not site authorization; MaxNet continues to enforce access to every feature. A MaxNet rank or site permission never grants Linux administrator or `sudo` access. The sync snapshot is stored in the signed-in Linux user's private configuration. If MaxNet is offline, skip account sync and continue with the local desktop; the OS login, local theme, wallpaper, and apps remain usable offline.

The **Sign in to MaxNet** launcher uses the normal MaxNet account dialog and keeps its session in a separate persistent browser profile. The local OS login PIN/password is never sent to MaxNet or synced; it is managed by Linux Mint, and the same local credential is also used for `sudo`.

App launch supports sign-in, Chatroom, Forums, Direct Messages, Network, Eaglercraft, and the other MaxNet apps listed in the menu. Each feature launcher opens the matching MaxNet component without the website's desktop, taskbar, or navigation shell. Chromium/Chrome/Brave uses a native app window without browser controls. Firefox hides its tabs, address bar, and browser toolbars through a dedicated profile stylesheet while keeping the normal desktop title bar and window controls, so its app windows remain movable, resizable, and closable.

## Build the MaxOS integration package

On Linux Mint or Debian with `dpkg-deb` installed:

```bash
./maxnet-os/package/build-deb.sh
sudo apt install ./maxnet-os/dist/maxnet-os_0.4.9_$(dpkg --print-architecture).deb
```

The launcher defaults to the confirmed MaxNet host. Use **MaxNet OS → Configure** (or run `maxnet-os configure`) to change it. A per-user override is stored under `~/.config/maxnet-os/settings.conf`; the chosen theme is stored separately in `~/.config/maxnet-os/theme`. This package never stores a MaxNet password or session token.

Use **Set Local OS PIN** from Start → System to run the standard `passwd` tool. This changes the local account password used at restart and lock screen; the system also uses it for `sudo`. It is not a separate short PIN credential and it is never checked by MaxNet. Keep at least one administrator account with a strong recovery password.

Chromium/Chrome/Brave opens MaxNet in a clean app window with a separate persistent profile. Firefox uses a separate persistent profile and hides browser controls with `userChrome.css` without enabling kiosk or fullscreen mode; the native title bar remains available to move, resize, minimize, and close windows. Generic `xdg-open` fallback is limited to the full-site home shortcut so app launchers never unexpectedly open a tabbed browser.

## MaxNet OS updates

Open **MaxOS Update Manager** from Start → System or run `maxnet-os --updates`. The manager checks the latest stable GitHub release, downloads the matching architecture-specific `.deb`, verifies its SHA-256 sidecar and GitHub asset digest (when available), confirms the package name/version, and asks PolicyKit before installing through `apt`. It does not pull or execute repository source code.

When MaxOS files are pushed or merged to `main`, GitHub Actions automatically builds the Debian package, adds a SHA-256 checksum, and publishes a stable GitHub release. Automatic versions use `maxnet-os/VERSION` plus the workflow run number (for example, `0.4.2+build.17`), so each OS change can be offered as an update without manually editing the version for every sync. Feature branches do not publish updates until they reach `main`.

For a deliberate versioned release, push a `v<VERSION>` tag that matches `maxnet-os/VERSION`; the same workflow publishes that exact version.

Restore the previous Cinnamon theme and wallpaper with:

```bash
maxnet-os --restore-system-theme
```

## Make a bootable Linux Mint remaster

This repository does not include or redistribute a Linux Mint ISO. To make a bootable image:

1. Download the Linux Mint edition/version and verify its published checksum.
2. Use Cubic on a Linux Mint/Ubuntu host to customize the official ISO.
3. In Cubic's terminal, install `zenity`, `python3`, `xdg-utils`, and Chromium or Chrome for browser-free MaxNet app windows; copy and install the built `.deb`.
4. Choose the desired theme for the live-session user, then finish Cubic's ISO creation.
5. Boot the result in a VM first. Test sign-in, chat, forum, Network, Eaglercraft/WebGL, all eight themes, and live-installer behavior before installing it on a physical computer.

The first boot splash is stored in the ISO's initramfs as well as the live root filesystem. The branding scripts replace both the main Plymouth animation and its separate Mint throbber frames with the supplied MaxOS boot icon. After branding the root filesystem, run `package/brand-initramfs.sh /path/to/iso-tree/casper/initrd.lz /path/to/branded-rootfs` before rebuilding the ISO so the early boot image gets the same artwork.

Linux Mint and Cinnamon are upstream open-source projects. MaxNet OS is an unofficial derivative and is not endorsed by the Linux Mint project.
