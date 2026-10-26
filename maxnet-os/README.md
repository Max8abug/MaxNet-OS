# MaxNet OS

MaxNet OS is an unofficial Linux Mint Cinnamon customization that adapts MaxNet's existing eight display themes into desktop themes and exposes MaxNet's apps in the Linux Mint application menu. The launchers open MaxNet in a dedicated app window, with each shortcut opening its matching MaxNet app after the frontend integration is merged and deployed.

This is a Linux Mint integration layer, not a new Linux kernel or a replacement for Mint. MaxNet remains the online service at `https://moonbat.ddns.net`; the OS does not bundle or self-host the MaxNet server.

## MaxNet themes as desktop themes

The OS theme chooser includes the same theme IDs as MaxNet:

- Classic light and dark
- Windows XP light and dark
- Windows Vista light and dark
- Gold picture frame
- Silver picture frame

Each option generates a matching Cinnamon theme, GTK 3/4 theme, and wallpaper. Choose **MaxNet OS Themes** from the application menu, or run `maxnet-os --choose-theme`. The selected theme is also passed to MaxNet when a launcher opens, so the web desktop uses the same appearance. Choosing a theme inside MaxNet still changes MaxNet's own account preference; a website cannot safely change the Linux desktop theme without an explicit local OS action.

## MaxNet applications in the Linux Mint menu

The menu includes sign-in, Chatroom, Forums, Direct Messages, Network Feed/People/Wiki, Photo Gallery, Users, Guestbook, Visitor Counter, Planner, Site News, Games, Eaglercraft, My Page Editor, Synced YouTube, Polls, Music Player, Playlists, Drawing Pad, and MaxNet Display Settings.

The MaxNet service still controls account sign-in, permissions, feature availability, and stored preferences. The app window keeps its own persistent browser profile rather than sharing cookies with a user's normal browser profile.

Direct-to-app launch requires the [MaxNet OS launcher integration](https://github.com/Max8abug/MaxNet/pull/1) to be reviewed, merged, and deployed. Until then, the menu entries open MaxNet but fall back to its home desktop.

## Build the Linux Mint integration package

On Linux Mint or Debian with `dpkg-deb` installed:

```bash
./maxnet-os/package/build-deb.sh
sudo apt install ./maxnet-os/dist/maxnet-os_0.2.0_$(dpkg --print-architecture).deb
```

The launcher defaults to the confirmed MaxNet host. Use **MaxNet OS → Configure** (or run `maxnet-os configure`) to change it. A per-user override is stored under `~/.config/maxnet-os/settings.conf`; the chosen theme is stored separately in `~/.config/maxnet-os/theme`. This package never stores a MaxNet password or session token.

Chromium/Chrome/Brave opens MaxNet in a clean app window with a separate persistent profile. Firefox and the system browser are supported as fallbacks; those may show normal browser controls. Install Chromium for the closest standalone-app experience.

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

Linux Mint and Cinnamon are upstream open-source projects. MaxNet OS is an unofficial derivative and is not endorsed by the Linux Mint project.
