-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Optional modules — installed by their own omarchy-configs steps; silently
-- skipped when absent so stock Hyprland config never breaks.
pcall(require, "hypr.cursor")    -- Afterglow cursor env vars (cursor module)
pcall(require, "hypr.bootlock")  -- lock screen at boot (boot-lock module)

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Don't lock/screensaver while watching fullscreen video (YouTube, Netflix,
-- etc. in the browser, or a local video in mpv). Matches the same pattern
-- Omarchy's own defaults use for Steam/Moonlight/GeForce Now. Only inhibits
-- while the window is actually fullscreen, so normal browsing still locks
-- on idle as usual.
o.window({ tag = "chromium-based-browser" }, { idle_inhibit = "fullscreen" })
o.window({ tag = "firefox-based-browser" }, { idle_inhibit = "fullscreen" })
o.window("^(mpv)$", { idle_inhibit = "fullscreen" })
