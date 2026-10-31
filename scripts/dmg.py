# dmgbuild settings for build/Webcam.dmg. Run through `mise run dmg`.
# Icon positions must match scripts/dmg-background.swift.

app = defines.get("app", "build/Webcam.app")  # noqa: F821 (injected by dmgbuild)
background = defines.get("background", "build/dmg/background.tiff")  # noqa: F821

format = "UDZO"
filesystem = "APFS"

files = [app]
symlinks = {"Applications": "/Applications"}
icon = "Resources/AppIcon.icns"

# 640x400 of background plus Finder's title bar.
window_rect = ((200, 200), (640, 432))
default_view = "icon-view"
show_status_bar = False
show_tab_view = False
show_toolbar = False
show_pathbar = False
show_sidebar = False

icon_size = 112
text_size = 13
icon_locations = {
    "Webcam.app": (170, 210),
    "Applications": (470, 210),
}
