# -*- coding: utf-8; Mode: Python; indent-tabs-mode: nil; tab-width: 4 -*-
"""Final MaxOS installer page for optional MaxNet account sign-in."""

import os
from urllib.parse import urlencode
from uuid import uuid4

from ubiquity import misc, plugin


NAME = 'maxos_account'
AFTER = 'network'
WEIGHT = 100


def maxnet_url():
    base_url = 'https://moonbat.ddns.net'
    settings_path = '/etc/maxnet-os/settings.conf'
    try:
        with open(settings_path, encoding='utf-8') as settings:
            candidate = settings.readline().strip().rstrip('/')
        if candidate.startswith('https://') and not any(
                char in candidate for char in ('?', '#', '@')):
            base_url = candidate
    except OSError:
        pass

    query = urlencode({
        'maxnet-feature': 'signin',
        'maxnet-view': 'app',
        'maxnet-launch-id': 'installer-' + uuid4().hex,
    })
    return base_url + '/?' + query


class PageGtk(plugin.PluginUI):
    plugin_title = 'MaxNet Account'
    plugin_is_install = True

    def __init__(self, controller, *args, **kwargs):
        from gi.repository import Gdk, GLib, Gtk

        self.controller = controller
        builder = Gtk.Builder()
        controller.add_builder(builder)
        builder.add_from_file(os.path.join(
            os.environ['UBIQUITY_GLADE'], 'stepMaxosAccount.ui'))
        self.page = builder.get_object('stepMaxosAccount')
        self.plugin_widgets = self.page
        for widget_id, style_class in (
                ('stepMaxosAccount', 'maxos-installer-page'),
                ('maxos_installer_header', 'maxos-installer-header'),
                ('maxos_installer_card', 'maxos-installer-card'),
                ('maxos_installer_title', 'maxos-installer-title'),
                ('maxos_installer_subtitle', 'maxos-installer-subtitle'),
                ('maxnet_account_offline_note', 'maxos-installer-note'),
                ('maxnet_sign_in_button', 'maxos-sign-in-button')):
            builder.get_object(widget_id).get_style_context().add_class(style_class)

        sign_in_button = builder.get_object('maxnet_sign_in_button')
        sign_in_button.connect('clicked', self.open_maxnet)

        css_path = '/usr/share/maxnet-os/maxos-installer.css'
        if os.path.isfile(css_path):
            provider = Gtk.CssProvider()
            try:
                provider.load_from_path(css_path)
                screen = Gdk.Screen.get_default()
                if screen:
                    Gtk.StyleContext.add_provider_for_screen(
                        screen, provider,
                        Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
            except GLib.Error:
                pass

    def open_maxnet(self, unused_button):
        misc.launch_uri(maxnet_url())


class Page(plugin.Plugin):
    def prepare(self, unfiltered=False):
        return None
