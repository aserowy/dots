#!/usr/bin/env nu

def main [] {
    (dbus-send --type=signal /org/freedesktop/Notifications com.github.ibonn.rofi.open)
    (clipman pick -t rofi)
    (dbus-send --type=signal /org/freedesktop/Notifications com.github.ibonn.rofi.close)
}

