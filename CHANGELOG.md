# Changelog - Omarchy Setup

## 2026-08-16 (later still) - Activate Afterglow cursor theme on Omarchy 4

The cursor theme files were already on disk (`~/.local/share/icons/Afterglow-cursors`,
carried over from the pre-4 install) but never activated — Hyprland has no
default `XCURSOR_THEME`, so it was silently falling back to the system
default cursor.

### Changes Made

1. Activated via three mechanisms so it actually persists: `gsettings set
   org.gnome.desktop.interface cursor-theme "Afterglow-cursors"` (GTK apps),
   `hyprctl setcursor Afterglow-cursors 24` (immediate, current session), and
   `XCURSOR_THEME`/`HYPRCURSOR_THEME`/`XCURSOR_SIZE`/`HYPRCURSOR_SIZE` env
   vars added to `hypr/looknfeel.lua` (persists across Hyprland restarts).
2. `sync-configs.sh` now syncs `~/.local/share/icons/Afterglow-cursors` into
   `configs/icons/` (previously never synced automatically).
3. `recover-customizations.sh` and `restore-customizations.hook` both now
   restore the cursor theme dir and re-run all three activation steps.
4. **Repeated the exact same mistake from the previous entry** — edited
   `looknfeel.lua` live, then ran the post-update hook as a test *before*
   syncing the edit to the repo, so the hook correctly flagged the drift and
   then "won" with the stale repo copy, wiping the new env vars out again.
   Caught it the same way (drift warning + `journalctl`/config check), fixed
   it, and this time synced to the repo *before* testing the hook again.
   Noting this explicitly as a process lesson: **always sync live→repo
   before test-running a restore hook**, since "repo wins" is the hook's
   entire point.

### Files Modified
- `hypr/looknfeel.lua` — cursor env vars
- `scripts/sync-configs.sh` — cursor theme sync
- `recover-customizations.sh`, `restore-customizations.hook` (+ installed `post-update.d/` copy) — restore + activate cursor theme
- `README.md` — new "Cursor theme" subsection under Omarchy 4 (current)

---

## 2026-08-16 (later) - Fix broken post-update automation, drop TLP/battery tuning

A follow-up audit found the "Omarchy 4 Migration" entry below never actually
wired the new configs into the restore automation — the post-update hook and
recovery script both still only handled the dead pre-4 files, and worse, the
installed hook was **disabled** (`post-update.disabled`) since the Omarchy 4
upgrade migration, so it hadn't been running at all.

### Changes Made

1. **TLP/battery tuning removed** — not in use right now. Deleted
   `configs/tlp/`, `configs/sysctl/`, `configs/omarchy/power-mode/`, and the
   two TLP-related waybar indicator scripts. Will be re-added fresh in a
   future version if needed rather than restored from this history.
2. **Post-update hook rewritten and properly installed** — moved from a
   single `~/.config/omarchy/hooks/post-update` file (the old, pre-4 hook
   mechanism — Omarchy 4 uses a `post-update.d/` directory of individual
   hook scripts instead) to `restore-customizations.hook`, installed via
   `omarchy hook install post-update <file>`. Now restores the real Omarchy 4
   config: `bindings.lua`/`input.lua`/`looknfeel.lua`/`autostart.lua`,
   `shell.json`, `shell.toml`, and the entire `plugins/bbk.*` tree. Dropped
   the dead pre-4 restores (`bindings.conf`, `hyprlock.conf`,
   `waybar/config.jsonc`, etc.) entirely rather than leaving them as
   pointless no-ops.
3. **Drift detection added** — every `restore_config`/`restore_tree` call now
   diffs the live file against the repo copy *before* overwriting, and prints
   a `⚠ DRIFT` warning (with a suggested `diff` command) if they differ. This
   directly addresses "what if an Omarchy update changes waybar/lock-screen
   configs" — instead of silently clobbering an upstream change, the hook
   flags it so it can be reviewed and folded into the repo by hand.
   Live-tested: correctly caught a since-resynced widget edit and stale
   leftover backup directories from an earlier failed experiment.
4. **`recover-customizations.sh` rewritten** to match — same Omarchy 4 file
   set as the hook, dead pre-4 restores removed, and it now installs the
   post-update hook itself via `omarchy-hook-install` at the end instead of
   requiring a manual copy.
5. **`sync-configs.sh` updated** — drops the power-mode sync, excludes
   dotfile-prefixed rollback-backup directories under `plugins/`
   (`.bbk.<name>.bak.<timestamp>`, created by `omarchy plugin remove`) so
   they can't leak into the repo again, and tightened the `*.bak` exclude
   pattern to also catch backup files without a numeric suffix.
6. **Verified live**: ran the installed hook end-to-end (`bash
   ~/.config/omarchy/hooks/post-update.d/restore-customizations.hook`) —
   correctly flagged real drift on the first run, zero drift on the second
   after resyncing, and `hyprctl reload`/`omarchy restart shell` both came
   back clean afterward.

### Files Removed
- `configs/tlp/`, `configs/sysctl/`, `configs/omarchy/power-mode/`
- `configs/waybar/indicators/tlp-profile.sh`, `tlp-toggle.sh`
- `post-update` (root) → renamed `restore-customizations.hook`
- `configs/omarchy/hooks/post-update` → moved to `configs/omarchy/hooks/post-update.d/restore-customizations.hook`

### Files Modified
- `restore-customizations.hook` (formerly `post-update`) — full rewrite: Omarchy 4 restores + drift detection
- `recover-customizations.sh` — full rewrite: Omarchy 4 restores, installs the hook itself
- `scripts/sync-configs.sh` — drop power-mode, exclude plugin rollback-backup dirs, tighten `.bak` exclude
- `README.md` — battery section removed, install/setup instructions point at `recover-customizations.sh`, drift-flagging documented

---

## 2026-08-16 - Omarchy 4 Migration (Lua/Quickshell rewrite)

Omarchy 4 replaced waybar, hyprlock, and the old `.conf`-based Hyprland config
with a Lua-configured Hyprland and a Quickshell-based shell. This is a from-scratch
recreation of the old customizations on the new architecture, not a port — most of
the old scripts (waybar CSS, aether/waybar pipeline, hyprlock.conf DSL) have no
equivalent anymore and were left as legacy/historical reference.

### Changes Made

1. **Keybindings** (`hypr/bindings.lua`) — restored old muscle-memory bindings on
   the new Lua binding API: `Q`=close, `L`=system menu/`Shift+L`=layout toggle,
   `E`=file manager, `;`=emoji picker (new built-in picker, not walker),
   `Shift+S`/`Shift+R`=screenshot/recording, unbound ~15 unused preinstalled
   app/webapp shortcuts. Added `Ctrl+Shift+S`=capture menu and swapped
   `Super+Space`⇄`Super+Alt+Space` (apps menu / omarchy menu) per new preference.
2. **Touchpad** (`hypr/input.lua`) — 3-finger horizontal swipe to switch
   workspaces, natural scroll. (4-finger volume swipe and custom brightness floor
   from the old config were deliberately dropped.)
3. **Tiling look** (`hypr/looknfeel.lua`) — gaps 2/4, border 1px, rounded corners,
   `resize_on_border` + larger grab area. Border colors left theme-tied instead of
   hardcoded (new system ties them to the active theme already).
4. **Lock screen** (`omarchy/plugins/bbk.lock/LockView.qml`) — cloned the stock
   Quickshell lock service (`service`-kind plugin) and restyled only the visual
   layer: time/date/battery centered on screen, password field hidden until
   typed, borderless, fully rounded, smaller. `Service.qml` (PAM/session-lock
   logic) untouched. Verified safe by checking `journalctl --user -t
   omarchy-shell` after each change — the lock service loads (`keepLoaded:
   true`) at shell startup regardless of whether it's actively locked, so load
   errors show up without needing to trigger a real lock.
5. **Wallpaper portal + theme generation** — recreated `wallpaper-portal.py`
   (D-Bus `org.freedesktop.impl.portal.Wallpaper` backend) pointing at a new
   `wallpaper-to-theme` script. Unlike the old version (which wrote into the live
   theme directory and drove a waybar/aether pipeline), the new script generates
   a dedicated `from-wallpaper` theme via `aether --generate --no-apply` and
   applies it with `omarchy theme set` — fully isolated, never mutates another
   theme, uses Omarchy's own theme-activation path.
6. **Custom bar** (`omarchy/plugins/bbk.*`, `omarchy/shell.json`,
   `omarchy/shell.toml`) — cloned every stock bar widget individually
   (workspaces, clock, weather, keyboard-layout, system-update, tray, agents,
   monitor, power, bluetooth, network, audio; added a new memory widget) and gave
   each its own rounded, theme-colored box — solid `Color.bar.background`/
   `Color.bar.text` instead of a wallpaper-sampled tint, since the bar is
   transparent and tint contrast varied across the wallpaper. Iterated padding/
   gap/font-size/corner-radius to match. Bumped the actual bar height via
   `shell.toml`'s `[bar] size-horizontal` (the real fix — a `[font] base-size`
   override was silently shrinking it via `scale-with-font`). Made bluetooth/wifi/
   volume labels clickable, not just their icons.
7. **Known dead end** — cloning the top-level `omarchy.bar` plugin (`bar` kind) to
   add a *shared* per-widget box wrapper crashed with `Required property ... was
   not initialized`; that plugin kind doesn't get its startup properties
   forwarded the way `bar-widget`/`panel`/`service` kinds do. Worked around by
   duplicating the box styling into each widget file instead.

### Files Added
- `hypr/bindings.lua`, `hypr/input.lua`, `hypr/looknfeel.lua`, `hypr/autostart.lua`
- `omarchy/shell.json`, `omarchy/shell.toml`
- `omarchy/wallpaper-to-theme` (new location/rewrite; old one at `.local/bin/wallpaper-to-theme` is now dead)
- `omarchy/plugins/bbk.*/` — all custom shell plugin clones

### Files Modified
- `omarchy/wallpaper-portal.py` — now calls `wallpaper-to-theme` instead of the removed `omarchy-theme-bg-set`-only flow
- `scripts/sync-configs.sh` — added sync for `shell.json`, `shell.toml`, `plugins/`, and the new `wallpaper-to-theme` location
- `README.md` — added an "Omarchy 4 (current)" section; existing waybar/hyprlock content moved under "Legacy (pre-Omarchy-4)"

---

## 2026-08-07 - Screenshot Notification Fix

### Changes Made

1. **Screenshot notification — click to edit, right-click to dismiss** — The `✕` in the mako format string was decorative text, not a button. Clicking it (or anywhere on the notification) triggered the default action (open satty editor) rather than dismissing. Removed the misleading `✕` from the format and updated the notification body to say "Click to edit · right-click to dismiss" so the behavior is self-documenting.

### Files Modified
- `configs/mako/config` — removed `✕` from format string
- `configs/omarchy/bin/omarchy-capture-screenshot` — updated notification body text; now tracked in sync
- `scripts/sync-configs.sh` — added `omarchy-capture-screenshot` to the bin sync list

---

## 2026-08-07 - SOT Daemon Rewrite, Webapp Launcher Fix, Mako Improvements

### Changes Made

1. **SOT Daemon — Fully Event-Driven (no polling)** — The previous daemon polled `hyprctl monitors -j` every 5 seconds to detect screen state. Root cause found: `hyprctl dispatch dpms off/on` (used by `omarchy-brightness-display`) emits no events on Hyprland's socket2, so the original IPC listener was also deaf. New architecture:
   - `sot-daemon` blocks on a named pipe (`~/.local/state/omarchy/sot.pipe`) waiting for events
   - `omarchy-brightness-display` signals `screen-off`/`screen-on` to the pipe after each dpms dispatch
   - A new systemd sleep hook (`/etc/systemd/system-sleep/sot-hook.sh`) signals `sleep` before suspend and `screen-on` after wake
   - Battery state polled via `read -t 10` timeout (sysfs file read only, no process spawning)
   - Single `hyprctl` call on daemon startup only to detect initial screen state
   - SIGTERM trap banks in-progress screen time on daemon stop/restart

2. **System impact comparison:**
   | | Old (polling) | New (event-driven) |
   |---|---|---|
   | CPU | ~0.2% (hyprctl every 5s) | ~0% (blocks on pipe) |
   | Process spawns | 720/hour | only on screen events |
   | Latency | 0–5s lag | instant |

3. **Webapp Launcher — Vivaldi Fallback** — `omarchy-launch-webapp` fell back to `chromium.desktop` when the default browser wasn't Chromium-based (e.g. Zen). Chromium is not installed. Changed fallback to `vivaldi-stable.desktop` so all installed web apps (Google Photos, Maps, Messages, Contacts, WhatsApp, Figma) open correctly.

4. **Mako Notifications** — Added `border-radius=8` (matches Hyprland window rounding) and a `✕` dismiss icon in the format string using the border accent color. Right-click on any notification dismisses it.

### Files Added
- `configs/omarchy/bin/omarchy-launch-webapp` — vivaldi fallback fix
- `configs/omarchy/bin/omarchy-brightness-display` — signals SOT pipe on dpms changes
- `configs/system-sleep/sot-hook.sh` — systemd sleep/wake hook (requires sudo to install)

### Files Modified
- `configs/.local/bin/sot-daemon` — fully rewritten; event-driven via named pipe
- `configs/mako/config` — border-radius=8, format with ✕, on-button-right=dismiss
- `scripts/sync-configs.sh` — added omarchy/bin/, system-sleep/ to sync targets

### Setup Notes
```bash
# Install omarchy bin overrides
cp configs/omarchy/bin/omarchy-launch-webapp ~/.local/share/omarchy/bin/
cp configs/omarchy/bin/omarchy-brightness-display ~/.local/share/omarchy/bin/
chmod +x ~/.local/share/omarchy/bin/omarchy-launch-webapp
chmod +x ~/.local/share/omarchy/bin/omarchy-brightness-display

# Install SOT daemon
cp configs/.local/bin/sot-daemon ~/.local/bin/sot-daemon
chmod +x ~/.local/bin/sot-daemon
systemctl --user restart sot-daemon

# Install sleep hook (requires sudo)
sudo cp configs/system-sleep/sot-hook.sh /etc/systemd/system-sleep/
sudo chmod +x /etc/systemd/system-sleep/sot-hook.sh
```

---

## 2026-08-04 - Android-Style Screen-On Time Tracking

### Changes Made

1. **True Screen-On Time (SOT) in Waybar** — The TLP power-mode tooltip previously showed "time since last script run," not actual screen-on time. It now tracks only time the display is actively on — identical to how Android reports SOT — by listening to Hyprland's IPC socket for `dpms` events. Screen-off time (idle blanking, suspend, hibernate) is excluded automatically since hypridle turns the display off before sleep, which fires the dpms-off event that pauses the counter.

2. **SOT daemon (`sot-daemon`)** — A persistent bash daemon runs as a systemd user service. It:
   - Connects to Hyprland's `.socket2.sock` and listens for `dpms>>` events
   - Banks elapsed time on screen-off, resumes the clock on screen-on
   - Reads `/var/lib/upower/history-charge-<model>.dat` to get the accurate unplug timestamp (not just "when waybar started")
   - Polls battery status every 30 s to reset the counter when the charger reconnects
   - Persists state to `~/.local/state/omarchy/sot.state` so waybar restarts don't reset it
   - Reconnects automatically if the socket drops (e.g. after hibernate)

3. **Waybar `tlp-profile.sh` updated** — Removed the old inline SOT calculation (which used `/tmp/waybar_sot_start_time` and never subtracted sleep time). Now reads from the daemon's state file via a `get_sot_text()` function. Tooltip label changed from "Current SOT" to "Screen-On Time".

### Files Added
- `configs/local-bin/sot-daemon` — SOT tracker daemon script
- `configs/systemd/user/sot-daemon.service` — systemd user service unit

### Files Modified
- `configs/waybar/indicators/tlp-profile.sh` — reads SOT from daemon state file

### Setup Notes
```bash
# Install daemon script
cp configs/local-bin/sot-daemon ~/.local/bin/sot-daemon
chmod +x ~/.local/bin/sot-daemon

# Install and start the service
cp configs/systemd/user/sot-daemon.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now sot-daemon.service
```

---

## 2026-07-31 - Wallpaper-Driven Full Theme Generation

### Changes Made

1. **Nautilus "Set as Background" now works on Hyprland** — Nautilus 50 uses the XDG Desktop Portal (`org.freedesktop.impl.portal.Wallpaper`) to set wallpapers. Neither `xdg-desktop-portal-hyprland` nor `xdg-desktop-portal-gtk` implements this interface, so the call silently failed. Added a minimal Python D-Bus service (`wallpaper-portal.py`) that registers as `org.freedesktop.impl.portal.desktop.omarchy`, intercepts the `SetWallpaperURI` call, and routes it to `wallpaper-to-theme`.

2. **Full color system generated from wallpaper** — `wallpaper-to-theme` runs `aether --generate --no-apply` to extract a 16-color palette and write theme files directly into `~/.config/omarchy/current/theme/`. Covers: Hyprland borders, Waybar, hyprlock, mako notifications, SwayOSD (volume/brightness), all terminals, btop, VSCode, browser, Obsidian, Zed. Uses `--no-apply` so we control the restart sequence and prevent aether's async waybar restart from overwriting our `dynamic.css`.

3. **Adaptive Waybar module background** — Measures the luminosity of the top 60px strip of the wallpaper (where Waybar sits) instead of the whole image. Picks a readable module pill color automatically:
   - Bright top (LUM > 100): accent darkened to 40% brightness at 88% opacity
   - Mid-tone top (LUM 61–100): same darkened accent at 72% opacity
   - Dark top (LUM ≤ 60): `lighter_bg` from the palette at 80% opacity
   Writes full `rgba()` to `dynamic.css` (not `alpha()` in CSS, which had GTK rendering issues). Waybar `style.css` now uses `@module-bg` directly.

4. **`border-from-wallpaper` kept as theme-set hook** — Still runs on `omarchy theme set` to sync borders when switching named themes without changing the wallpaper.

### Files Added
- `configs/omarchy/wallpaper-portal.py` — D-Bus service implementing `org.freedesktop.impl.portal.Wallpaper`
- `configs/.local/bin/wallpaper-to-theme` — full theme generation pipeline from a wallpaper path
- `configs/.local/share/xdg-desktop-portal/portals/omarchy.portal` — portal backend registration
- `configs/xdg-desktop-portal/hyprland-portals.conf` — adds `omarchy` to the portal backend list

### Files Modified
- `configs/hypr/autostart.conf` — launches `wallpaper-portal.py` on login
- `configs/waybar/style.css` — module background uses `@module-bg` (was `alpha(@accent, 0.3)`)
- `configs/waybar/dynamic.css` — now defines `@module-bg` in addition to `@accent`
- `scripts/sync-configs.sh` — syncs new portal files and `wallpaper-to-theme`
- `post-update` / `recover-customizations.sh` — restore all new files

### Prerequisites
```bash
sudo pacman -S python-dbus python-gobject
# aether ships with Omarchy
```

## 2026-07-31 - Dynamic Accent Color from Wallpaper

### Changes Made
1. **Wallpaper-Derived Border Colors** — Window borders now take their color from the current wallpaper. `border-from-wallpaper` extracts the average color and writes `~/.config/hypr/border-colors.conf`, which `looknfeel.conf` sources. Falls back to the theme accent for grayscale/very dark wallpapers, boosts to minimum visibility, dims to 40% for the inactive border.

2. **Waybar Accent Backgrounds** — Waybar module pills now use the same wallpaper color as their background via `~/.config/waybar/dynamic.css` (`@accent`), replacing the old semi-transparent black.

3. **Theme-Set Hook** — Runs `border-from-wallpaper` automatically on every `omarchy theme set`.

### Files Added
- `configs/hypr/border-colors.conf` — generated border colors sourced by `looknfeel.conf`
- `configs/waybar/dynamic.css` — generated `@accent` color used by Waybar modules
- `configs/omarchy/hooks/theme-set.d/border-from-wallpaper` — auto-runs on theme change
- `configs/.local/bin/border-from-wallpaper` — color extraction script (also synced by `sync-configs.sh`)

### Files Modified
- `configs/hypr/looknfeel.conf` — border colors sourced from `border-colors.conf` instead of hardcoded
- `configs/waybar/style.css` — module backgrounds use `alpha(@accent, ...)`, imports `dynamic.css`
- `scripts/sync-configs.sh` — syncs `omarchy/hooks` and `~/.local/bin/border-from-wallpaper`
- `post-update` / `recover-customizations.sh` — restore the new border/waybar/hook/script files

## 2026-07-30 - Idle Timer Removal & Volume Step Fix

### Changes Made
1. **Removed Screensaver & Lock Timers** — Removed 150s screensaver and 152s lock listeners from hypridle.conf. System stays awake indefinitely until manually locked or suspended.

2. **Volume Step Increments** — Changed volume keybindings from default raise/lower to +5/-5 step increments for finer volume control. Added unbind directives for XF86AudioMute to prevent double-toggle (press mutes, release unmutes).

### Files Modified
- `configs/hypr/hypridle.conf` — removed both idle timeout listeners
- `configs/hypr/bindings.conf` — volume step increments, mute unbind directives

## 2026-07-22 - Waybar Clock Simplification

### Changes Made
1. **Simplified Clock Format** — Changed waybar clock from day+time with click-to-expand to single format: `Wed, Jul 22, 10:02`. Removed `format-alt` and `on-click-right` behavior.

### Files Modified
- `configs/waybar/config.jsonc` — updated clock format, removed alt format and click handler

## 2026-07-16 - Battery Indicator, Rounded Banners & Keybinding Fixes

### Changes Made
1. **Battery Indicator Module** — Added dedicated `custom/battery` module to waybar showing real-time battery status with charging indicator. Uses polling with change detection for instant updates when plugging/unplugging charger.

2. **Power Mode Simplified** — Simplified `custom/power-mode` module to show only the mode icon (󰛃/󰚥/󰾪) without battery percentage. Tooltip with detailed power info preserved on hover.

3. **Rounded Corners for Banners** — Updated SwayOSD (volume/brightness) and Mako (notifications) to use `border-radius: 8` matching Hyprland tiling window rounding.

4. **Volume Keybindings Restored** — Re-added missing XF86Audio volume/mute keybindings using `swayosd-client --output-volume`.

### Files Added
- `configs/waybar/indicators/battery.sh` — battery status script with real-time polling

### Files Modified
- `configs/waybar/config.jsonc` — added `custom/battery` module
- `configs/waybar/style.css` — added battery module styling (charging=green, full=blue)
- `configs/waybar/indicators/tlp-profile.sh` — removed battery info from text, icon only
- `configs/hypr/bindings.conf` — restored volume keybindings
- `configs/swayosd/style.css` — border-radius 0 → 8
- `configs/mako/config` — added border-radius=8

## 2026-07-15 - WiFi Power Save & Waybar Fixes

### Changes Made
1. **WiFi Power Save After Wake** — Added systemd service to temporarily disable WiFi power save after waking from hibernation/suspend, then re-enable after 30 seconds. Prevents "operation failed" error when reconnecting.

2. **Waybar Duplicate WiFi Icon Fixed** — Updated `bandwidth.sh` to output empty string when no network interface is found, hiding the net-speed module instead of showing "󰤭 --" alongside the network module's disconnected icon.

### Files Added
- `configs/system-tweaks/disable-wifi-powersave-wake.service` — systemd service for WiFi wake handling

### Files Modified
- `configs/waybar/indicators/bandwidth.sh` — hide module when disconnected
- `install.sh` — added systemd service deployment and enablement

## 2026-05-28 - Battery Optimization Configs

### Changes Made
1. **Hyprland Shadow Disabled** — turned off drop shadows in `looknfeel.conf` to reduce GPU compositing overhead on battery. Animations and blur preserved.

2. **TLP Battery Config** (`configs/tlp/99-battery.conf`) — aggressive battery-saving overrides:
   - CPU max freq capped at 800MHz (battery) / 400MHz (powersave)
   - Intel GPU max freq capped at 400MHz (battery) / 200MHz (powersave)
   - PCI Express ASPM forced to `powersupersave`
   - Platform profile forced to `low-power` on battery
   - Aggressive SATA link power and disk APM settings
   - Deployed to `/etc/tlp.d/99-battery.conf`

3. **Sysctl Battery Tuning** (`configs/sysctl/99-sysctl.conf`):
   - `vm.swappiness=10` — reduces unnecessary swap writes on 30GB RAM system
   - Deployed to `/etc/sysctl.d/99-battery.conf`

4. **THP madvise** (`configs/sysctl/transparent_hugepage.conf`):
   - `transparent_hugepage=madvise` — avoids compaction CPU spikes (not a sysctl, uses `tmpfiles.d`)
   - Deployed to `/etc/tmpfiles.d/transparent_hugepage.conf`

5. **Bluetooth Disabled** — `rfkill block bluetooth` persisted via systemd-rfkill

### Files Modified
- `configs/hypr/looknfeel.conf` — shadow `enabled = true` → `false`
- `configs/opencode/opencode.json` — added `opencode-mem` plugin for persistent memory
- `scripts/sync-configs.sh` — added opencode sync
- `post-update` — added opencode restore
- `recover-customizations.sh` — added opencode restore
- `README.md` — updated structure diagram, tables, setup instructions

### Files Added
- `configs/tlp/99-battery.conf` — TLP battery optimization overrides
- `configs/sysctl/99-sysctl.conf` — kernel tuning (swappiness)
- `configs/sysctl/transparent_hugepage.conf` — THP madvise via tmpfiles.d

### Setup Notes
- `/etc/` configs (TLP, sysctl) require `sudo` to deploy and are NOT covered by `post-update`. See README setup instructions for manual restore steps.

## 2026-05-17 - Afterglow Cursor Theme & Battery Fix

### Changes Made
1. **Afterglow Cursor Theme**
   - Installed custom Afterglow cursor theme to `~/.local/share/icons/`
   - Added `env = XCURSOR_THEME,Afterglow-cursors` to Hyprland config
   - Cursor theme tracked in `configs/icons/` for reinstallability

2. **Battery Indicator Fix**
   - Fixed `tlp-profile.sh` using non-existent `current_now` sysfs file
   - Switched to `power_now` (microwatts → watts) for drain rate calculation
   - Fixes noisy errors in Waybar logs

3. **Install/Recovery Scripts Updated**
   - `install.sh` — added cursor theme install step
   - `recover-customizations.sh` — added cursor theme restore step
   - Both scripts now handle `icons/` directory

### Files Modified
- `configs/hypr/hyprland.conf` — added XCURSOR_THEME + XCURSOR_SIZE
- `configs/waybar/indicators/tlp-profile.sh` — current_now → power_now
- `install.sh` — cursor theme install
- `recover-customizations.sh` — cursor theme restore
- `README.md` — structure diagram + hyprland table updated
- `CHANGELOG.md` — this entry

### Files Added
- `configs/icons/Afterglow-cursors/` — cursor theme files

## 2026-05-16 - Waybar Pill Modules & Repo Cleanup

### Changes Made
1. **Waybar Module Container Redesign**
   - Each module is now a self-contained pill with semi-transparent background (alpha(@background, 0.55)), border-radius (8px), padding (0 10px), and margins (3px)
   - Bar background made transparent (was solid color)
   - Bar height increased from 26 to 30
   - Backdrop-filter removed (not supported by Waybar's CSS engine)

2. **Repo Structure Cleanup**
   - Removed old Gruvbox theme files (alacritty.toml, btop.theme, colors.toml, hyprland.conf, etc.) — these are stock Omarchy theme files, not custom
   - Removed empty directories (backup-scripts/, configs/git/, configs/mako/)
   - Removed all *.bak.* files
   - Removed old background images (1-the-backwater.jpg, 2-leaves.jpg)
   - Removed obsolete files (icons.theme, keyboard.rgb, hyprland-preview-share-picker.css, preview.png)

3. **Configs Reorganized**
   - `configs/omarchy/` restructured from flat mess to proper subdirectories: branding/, extensions/, hooks/, power-mode/
   - Added bluetooth-state.sh
   - `configs/waybar/indicators/` now properly mirrors live structure
   - `configs/hypr/` — removed duplicate custom-screensaver-launch.sh from root (lives in scripts/)

4. **Scripts Updated**
   - `post-update` — simplified, removed dead code (backup-scripts reference), covers all custom configs
   - `recover-customizations.sh` — rewritten to match post-update, more comprehensive
   - `sync-configs.sh` — rewritten to use rsync, handles subdirectory structure properly

5. **Documentation Refined**
   - README completely rewritten with stock-vs-custom comparison table
   - CHANGELOG updated with today's entry, old history preserved

### Files Modified
- `configs/waybar/style.css` — complete redesign to pill modules
- `configs/waybar/config.jsonc` — height 26→30
- `configs/waybar/indicators/` — all indicator scripts synced from live
- `configs/hypr/*` — all configs synced from live
- `configs/omarchy/*` — restructured, synced from live
- `README.md` — complete rewrite
- `CHANGELOG.md` — added this entry
- `post-update` — simplified and updated
- `recover-customizations.sh` — rewritten
- `scripts/sync-configs.sh` — rewritten with rsync

### Removed
- `configs/alacritty/`, `configs/btop/`, `configs/fastfetch/`, `configs/ghostty/`, `configs/kitty/`, `configs/starship/`, `configs/walker/`, `configs/lazygit/` — stock omarchy defaults, not custom
- `configs/hypr/hyprsunset.conf`, `configs/hypr/xdph.conf` — stock, not configured
- `scripts/omarchy/` (161 files) — old upstream snapshots, not user-modified

## 2026-02-05 - Force Shutdown & System Menu Reset

### Changes Made
1. **Reset Omarchy System Menu to Defaults**
   - Reset hypridle, hyprlock, and hyprland configs to factory defaults
   - Restores standard lock, screensaver, hibernate, restart, shutdown behavior

2. **Added Force Shutdown Feature**
   - **Problem**: Normal shutdown hangs after long uptime or hibernation
   - **Solution**: Custom force shutdown that kills all apps immediately
   - **Location**: `~/.config/system-tweaks/force-shutdown.sh`
   - **Menu Integration**: System menu override in `~/.config/omarchy/extensions/menu.sh`
   - **Safe for Updates**: Lives in user config directory

3. **Updated Backup/Restore System**
   - Added `system-tweaks/` folder to sync script
   - Added `omarchy/extensions/` folder to sync script
   - Updated `post-update` hook to restore new components
   - Updated `recover-customizations.sh` for manual recovery

### Files Added/Modified
```
~/.config/system-tweaks/
├── force-shutdown.sh         # New: Force shutdown script
└── logind.conf               # Existing: Login/power settings

~/.config/omarchy/extensions/
└── menu.sh                   # New: System menu override with force shutdown
```

## 2026-01-31 - Post-Update Screensaver Fixes

### Issues Fixed
1. **Terminal Text Effects (TTE) Python Module Error**
   - **Problem**: `ModuleNotFoundError: No module named 'terminaltexteffects'`
   - **Cause**: Python version mismatch (package built for 3.13, system using 3.14)
   - **Solution**: Added Python path fix to custom screensaver scripts
   - **Files Updated**: 
     - `~/.config/hypr/screensaver-script.sh`
     - `~/.config/hypr/scripts/custom-screensaver-launch.sh`

2. **Hyprlock Configuration Errors**
   - **Problem**: "no such animation" and "config option does not exist" errors
   - **Cause**: Deprecated configuration options removed in updated hyprlock
   - **Deprecated Options Removed**:
     - `animation = fade, 1, 2, default`
     - `animation = slide, 1, 3, slide`
     - `animation = workspace, 1, 2, default`
     - `fade_on_empty_timeout = 2000`
     - `placeholder_text_fade_time = 500`
   - **Solution**: Updated to match new defaults
   - **Files Updated**: `~/.config/hypr/hyprlock.conf`

### Decision: System vs Custom Screensaver
- **Choice Made**: Keep only custom screensaver (Ctrl+Super+S) with lock functionality
- **Reasoning**: Avoid conflicts with system updates and maintain stability
- **Enhancement**: Added subtle fade transition from screensaver to lock screen
- **Current Behavior**:
  - ✅ Ctrl+Super+S → screensaver → fade transition → locks after exit
  - ❌ Omarchy system option → screensaver → no lock (intentional)

### Update Resilience
- **Added**: Post-update hook (`~/.config/omarchy/hooks/post-update`)
- **Purpose**: Automatically restore customizations after `omarchy-update`
- **What it restores**: Custom hyprlock, hypridle, scripts, and autostart configs

### Technical Details

#### Python Path Fix
```bash
# Added to screensaver scripts
export PYTHONPATH="/usr/lib/python3.13/site-packages:$PYTHONPATH"
```

#### Hyprlock Configuration Changes
```bash
# Old (deprecated)
animations {
    enabled = true
    animation = fade, 1, 2, default
    animation = slide, 1, 3, slide
    animation = workspace, 1, 2, default
}

# New (working)
animations {
    enabled = false
}
```

#### Files Backed Up
```
~/omarchy-setup/configs/hypr/
├── hyprlock.conf              # Fixed lock screen config
├── hypridle.conf              # Custom idle configuration
└── scripts/
    └── custom-screensaver-launch.sh    # Standalone screensaver with fade transition

~/omarchy-setup/post-update            # Update resilience hook
```

### Verification Commands
```bash
# Test screensaver
timeout 3 ~/.config/hypr/scripts/custom-screensaver-launch.sh

# Test hyprlock config
hyprlock --config ~/.config/hypr/hyprlock.conf

# Test Python module
export PYTHONPATH="/usr/lib/python3.13/site-packages:$PYTHONPATH"
python3 -c "import terminaltexteffects"
```

### Recovery Commands (if future issues)
```bash
# Restore customizations manually
~/.config/omarchy/hooks/post-update

# Reset to defaults if needed
omarchy-refresh-hyprland
omarchy-refresh-config hypr/hyprlock.conf
```

## Notes
- All changes are designed to survive Omarchy updates
- System screensaver intentionally left unmodified to avoid conflicts
- Custom solution provides more control and better update resilience
- Configuration follows Omarchy conventions for maximum compatibility