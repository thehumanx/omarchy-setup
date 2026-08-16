-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Wallpaper portal backend: bridges Nautilus "Set as Background" to omarchy-theme-bg-set.
o.exec_on_start("python3 " .. os.getenv("HOME") .. "/.config/omarchy/wallpaper-portal.py")
