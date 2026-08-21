-- Lock immediately after autologin — no delay, no desktop flash window.
-- SDDM still autologins; this throws the custom lock screen over the session
-- the moment Hyprland starts, so booting always ends at a password prompt.
o.exec_on_start("omarchy-shell lock lock")
