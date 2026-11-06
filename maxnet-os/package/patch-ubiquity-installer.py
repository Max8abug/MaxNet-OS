#!/usr/bin/env python3
"""Make Ubiquity the full-screen MaxOS setup assistant during ISO boot."""

from pathlib import Path
import sys


root = Path(sys.argv[1]) if len(sys.argv) == 2 else None
if root is None:
    raise SystemExit("Usage: patch-ubiquity-installer.py ROOTFS")

frontend = root / "usr/lib/ubiquity/ubiquity/frontend/gtk_ui.py"
if not frontend.is_file():
    raise SystemExit(f"Ubiquity GTK frontend is missing: {frontend}")

source = frontend.read_text(encoding="utf-8")
anchor = "self.live_installer.set_resizable(False)"
if source.count(anchor) != 1:
    raise SystemExit(
        "Could not uniquely locate the Ubiquity installer window setup; "
        "refusing to build an ISO that may show the live desktop."
    )

line_start = source.rfind("\n", 0, source.index(anchor)) + 1
indent = source[line_start:source.index(anchor)]
if indent.strip():
    raise SystemExit("Unexpected indentation around Ubiquity window setup.")

setup = """\
self.live_installer.set_title("MaxOS Setup")
self.live_installer.set_name("live_installer")
self.live_installer.set_decorated(False)
from gi.repository import Gdk, Gtk
maxos_css = Gtk.CssProvider()
try:
    maxos_css.load_from_path("/usr/share/maxnet-os/maxos-installer.css")
    maxos_screen = Gdk.Screen.get_default()
    if maxos_screen is not None:
        Gtk.StyleContext.add_provider_for_screen(
            maxos_screen, maxos_css, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
        self._maxos_installer_css = maxos_css
except Exception as error:
    print("MaxOS installer theme unavailable: %s" % error)
maxos_shell = self.builder.get_object("wizard")
if maxos_shell is not None:
    maxos_shell.set_name("maxos-installer-shell")
    maxos_shell.set_halign(Gtk.Align.CENTER)
    maxos_shell.set_valign(Gtk.Align.CENTER)
    maxos_shell.set_size_request(840, 560)
self.live_installer.fullscreen()
"""
inserted = anchor + "\n" + "\n".join(indent + line for line in setup.rstrip().splitlines())
source = source.replace(anchor, inserted, 1)
frontend.write_text(source, encoding="utf-8")
