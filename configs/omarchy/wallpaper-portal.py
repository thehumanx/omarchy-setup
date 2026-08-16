#!/usr/bin/env python3
"""
xdg-desktop-portal backend for org.freedesktop.impl.portal.Wallpaper.
Routes Nautilus "Set as Background" calls to wallpaper-to-theme, which sets
the background and regenerates the color theme from it.
"""

import os
import subprocess
import urllib.parse
import dbus
import dbus.service
import dbus.mainloop.glib
from gi.repository import GLib

BUS_NAME = "org.freedesktop.impl.portal.desktop.omarchy"
OBJECT_PATH = "/org/freedesktop/portal/desktop"
IFACE = "org.freedesktop.impl.portal.Wallpaper"
WALLPAPER_TO_THEME = os.path.expanduser("~/.config/omarchy/wallpaper-to-theme")


class WallpaperPortal(dbus.service.Object):
    def __init__(self, bus):
        super().__init__(bus, OBJECT_PATH)

    @dbus.service.method(
        dbus_interface=IFACE,
        in_signature="osssa{sv}",
        out_signature="u",
    )
    def SetWallpaperURI(self, handle, app_id, parent_window, uri, options):
        parsed = urllib.parse.urlparse(str(uri))
        path = urllib.parse.unquote(parsed.path)
        try:
            subprocess.Popen([WALLPAPER_TO_THEME, path])
            return dbus.UInt32(0)  # success
        except Exception as e:
            print(f"wallpaper-portal error: {e}")
            return dbus.UInt32(1)


if __name__ == "__main__":
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    session_bus = dbus.SessionBus()
    name = dbus.service.BusName(BUS_NAME, session_bus)
    WallpaperPortal(session_bus)
    GLib.MainLoop().run()
