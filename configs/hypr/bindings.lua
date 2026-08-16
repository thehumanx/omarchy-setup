-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- ============================================================
-- Personal overrides restored from old omarchy-setup config
-- ============================================================

-- Swap System menu / workspace layout toggle back to old keys.
-- Was: SUPER+ESCAPE=System menu, SUPER+L=Toggle workspace layout
hl.unbind("SUPER + ESCAPE")
hl.unbind("SUPER + L")
o.bind("SUPER + L", "System menu", "omarchy-menu toggle system")
o.bind("SUPER + SHIFT + L", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")

-- File manager back on SUPER+E (default SUPER+SHIFT+F left intact as a bonus)
o.bind("SUPER + E", "File manager", { omarchy = "nautilus" })

-- Close window back on SUPER+Q
-- Was: SUPER+W=Close window
hl.unbind("SUPER + W")
o.bind("SUPER + Q", "Close window", hl.dsp.window.close())

-- Disable preinstalled app/webapp shortcuts (not used)
hl.unbind("SUPER + SHIFT + D")           -- Docker
hl.unbind("SUPER + SHIFT + G")           -- Signal
hl.unbind("SUPER + SHIFT + O")           -- Obsidian
hl.unbind("SUPER + SHIFT + SLASH")       -- Passwords
hl.unbind("SUPER + SHIFT + A")           -- ChatGPT
hl.unbind("SUPER + SHIFT + ALT + A")     -- Grok
hl.unbind("SUPER + SHIFT + C")           -- Calendar
hl.unbind("SUPER + SHIFT + E")           -- Email
hl.unbind("SUPER + SHIFT + Y")           -- YouTube
hl.unbind("SUPER + SHIFT + ALT + G")     -- WhatsApp
hl.unbind("SUPER + SHIFT + CTRL + G")    -- Google Messages
hl.unbind("SUPER + SHIFT + P")           -- Google Photos
hl.unbind("SUPER + SHIFT + X")           -- X
hl.unbind("SUPER + SHIFT + ALT + X")     -- X Post

-- Emoji picker moved to SUPER+SEMICOLON, using the new built-in picker
hl.unbind("SUPER + CTRL + E")
o.bind("SUPER + SEMICOLON", "Emoji picker", "omarchy-shell shell toggle omarchy.emojis")

-- Screenshot/Screenrecording back on SUPER+SHIFT+S / SUPER+SHIFT+R (no Print key needed)
hl.unbind("PRINT")
hl.unbind("ALT + PRINT")
hl.unbind("SUPER + SHIFT + S")           -- was Google Maps (webapp shortcut, unused)
o.bind("SUPER + SHIFT + S", "Screenshot", "omarchy-capture-screenshot")
o.bind("SUPER + SHIFT + R", "Screenrecording", "omarchy-capture-screenrecording --stop-recording || omarchy-menu toggle trigger.capture.screenrecord")

-- Capture menu, duplicated on SUPER+CTRL+SHIFT+S
o.bind("SUPER + CTRL + SHIFT + S", "Capture menu", "omarchy-menu toggle capture")

-- Disable unused built-in feature shortcuts
hl.unbind("SUPER + ALT + RETURN")        -- Tmux
hl.unbind("SUPER + CTRL + RETURN")       -- Herdr
hl.unbind("SUPER + CTRL + X")            -- Toggle dictation
hl.unbind("F9")                          -- Dictation push-to-talk (start/stop)
hl.unbind("SUPER + CTRL + Q")            -- Calculator
hl.unbind("SUPER + CTRL + R")            -- Set reminder
hl.unbind("SUPER + SHIFT + CTRL + R")    -- Clear reminders
hl.unbind("SUPER + CTRL + ALT + W")      -- Toggle weather
hl.unbind("SUPER + CTRL + T")            -- Activity
hl.unbind("SUPER + SHIFT + CTRL + A")    -- Agent
hl.unbind("SUPER + SHIFT + W")           -- Omawrite
hl.unbind("SUPER + SHIFT + ALT + M")     -- Music TUI

-- Swap SUPER+SPACE / SUPER+ALT+SPACE
-- Was: SUPER+SPACE=Omarchy menu, SUPER+ALT+SPACE=Apps menu
hl.unbind("SUPER + SPACE")
hl.unbind("SUPER + ALT + SPACE")
o.bind("SUPER + SPACE", "Apps menu", "omarchy-menu toggle apps")
o.bind("SUPER + ALT + SPACE", "Omarchy menu", "omarchy-menu toggle")
