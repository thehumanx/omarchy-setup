# Omarchy Configs

> A curated layer of customizations on top of [Omarchy Linux](https://omarchy.org/) by DHH —
> daily-driving Arch + Hyprland without the rough edges.

![Desktop](images/cover.png)

| ![Lock screen](images/lockscreen-preview.png) |
|:---:|
| Lock screen: time, date, battery — centered, password field hidden until typed |

---

## Why this exists

Stock Omarchy is already great — this isn't a case for replacing it, just for
tuning the handful of things that don't match how I actually use it. Also some of the plugins on the marketplace are actual sh*t -- they are buggy, and do not persist on system update, and usually not as per my taste.

- **I don't use themes.** I change my wallpaper on a whim (by downloading images and right click -> set as wallpaper on Nautilus) and want the whole system to derive its colors from *that*, automatically. Right-click an image,
  set it as background, done.
- **The stock lock screen isn't my taste.** Rebuilt the layout (see above). Also, I've dual booted with Windows and Fedora so the SSD isn't encrypted. This means I need my own system lock that triggers during boot. (Note: If you have your device encrypted, installing lockscreen module will ask you for unlock 2 times.)
- **The bar deserved a *little* ricing.** Boxed pills with sane padding/gaps
  instead of bare icons on a transparent strip with some tweaks for multiple display support (the marketplace plugins came later, but i'd prefer my own).
- **The cursor is purely subjective.** Afterglow is just the one I liked. Always been using this on Windows as well.

None of this is "Omarchy is missing something." Although its marketplace is messy and confusing. It's "here's what *my*
Omarchy looks like," kept in a repo so it survives updates and reinstalls.

If you're end up using this, let me know it went for you (feedback/suggestions). Thanks for using. For anything, reach out to namaste@iambishistha.com.

### Next up
- Script to detect and download updates
- Better documentations and easy install/uninstall scripts/UX


---

## Step-by-step installer

Each customization is an independent module, applied **one step at a time**.
Every step shows what it does and exactly which files it adds, overwrites, or
patches — then you choose to proceed, skip, or abort. Progress is shown
per-step and overall:

```
$ ./install.sh

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  STEP 3 OF 9 — Lock screen — restyled (centered clock, battery, hidden password field)
  Module: lock
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  [█████████████░░░░░░░░░░░░░░░] 2/9 steps

  What this does:
  Clones the stock Omarchy lock service and restyles only the visual layer...

  Files:
      ADD        custom.lock/
          → ~/.config/omarchy/plugins/custom.lock/
      PATCH      (in place)
          → ~/.config/omarchy/shell.json — adds custom.lock, disables omarchy.lock

  Proceed with this step? [P]roceed / [s]kip / [a]bort:
```

Other modes:

```bash
./install.sh --help             # list available modules
./install.sh --all              # install everything without prompting
./install.sh --only bar,cursor  # walk through selected modules only
./uninstall.sh                  # same step-by-step flow, reverting to stock
./uninstall.sh --all            # revert everything without prompting
```

### How installing works

1. **Overview first** — `./install.sh` clears the screen and lists every
   module with its one-line description, then waits for Enter (Ctrl+C cancels).
2. **One step per module**, in fixed order: dock → wallpaper-pipeline → lock →
   hyprland → bar → branding → cursor → boot-lock → post-update-hook.
   Each step shows a header (`STEP n OF 9`) with an overall progress bar,
   a *"What this does"* explanation, and the exact **file plan** — every path
   labeled `ADD` (new file), `OVERWRITE` (backs up your existing copy first),
   `PATCH` (in-place edit), or `RUN` (command executed).
3. **Per-step choice** — `[P]roceed` (or just Enter) / `[s]kip` /
   `[a]bort`. Skipping one module never affects the others; aborting stops
   immediately having changed nothing further.
4. **Safe overwrites** — any existing target file is copied to
   `<name>.pre-omarchy-setup` *once* (an existing backup is never
   clobbered), so repeated installs stay reversible.
5. **Summary at the end** — every step listed as `✔ done`, `→ skipped`, or
   `✘ FAILED`; any failure exits non-zero. On success you get the follow-up
   hint: `hyprctl reload && hyprctl configerrors`, then `omarchy restart shell`.

### How uninstalling works

Same step-by-step UI in reverse. For each file the repo manages,
`uninstall.sh` either **restores the `.pre-omarchy-setup` backup**
(moving it back into place) or **removes the file outright** if it was
installed fresh. A few extras per module:

- **dock** — un-patches `shell.json` and removes the saved dock state
  (`~/.local/state/omarchy/dock.json` — position + pinned apps)
- **bar** — removes all `custom.*` plugins and runs `omarchy bar reset`
  to get the stock layout back
- **hyprland** — restores stock Omarchy `.lua` configs; optional extras
  (`cursor.lua`, `bootlock.lua`) are removed by their own modules
- **lock** — un-patches `shell.json`, restoring `omarchy.lock`
- **post-update-hook** — removes the hook from `post-update.d/`

Afterwards it cleans up directories the installer created, but only when
they're empty — anything still holding stock or user files is left alone.
The same summary/failure rules apply as during install.

---

## What's in each module

### App dock (independent module, installed first)
`configs/bar/plugins/custom.dock/` — a custom Quickshell plugin, not part of
the stock bar. Auto-hiding dock showing every open window grouped by app:

- **Hidden by default.** Only a faint low-opacity nub hints at the screen
  edge; hovering it reveals the full dock, which slides away again once the
  pointer leaves.
- **Position** defaults to bottom-center; right-click empty dock space for a
  tiny picker to switch top/left/right. Icons lay out vertically when docked
  left/right.
- **Pinning.** Right-click an app icon for a context menu — New Window /
  Close Window / Close All / Pin to Dock (or Unpin). A pinned app stays in
  the dock, launchable from it, even after every one of its windows closes;
  a small 📌 badge marks pinned icons.
- **Multi-monitor.** Runs independently on every connected display — each
  screen gets its own hover/reveal state, so hovering one monitor's dock
  never reveals another's.
- Left-click activates the app (cycling between its windows if it has more
  than one) or launches it if pinned-but-closed; middle-click closes the
  focused window.

Position and pinned apps are saved to `~/.local/state/omarchy/dock.json` —
per-machine runtime state, not tracked by this repo (each machine keeps its
own). `shell.json` is patched (via `install/dock-inject.py`) to load
`custom.dock` as a service plugin; unlike lock, it isn't a clone of a
first-party plugin, so there's nothing to un-disable on revert.

### Custom bar (all-or-nothing)
`configs/bar/` — `shell.json` (bar layout), `shell.toml` (sizing), and all
`custom.*` bar widget plugins copied to `~/.config/omarchy/`. The widgets are
independent QML files but `shell.json` references all of them — installing a subset
would break the bar layout. Lock screen is a **separate module**.

Shared widget styling lives in `custom.common/CustomPill.qml` — the boxed-pill
background (insets, corner radius, transparency) used by every bar widget.
Edit that one file to retune the pill look everywhere; restart the shell to
apply (`omarchy restart shell`).

`custom.monitor` (the Display widget) adds a Windows-style Mirror/Extend
toggle and Left/Right/Above/Below relative-position pills to the panel's
second-monitor section, shown whenever exactly two displays are enabled.
Applied live via `hyprctl eval hl.monitor(...)` — session-only, same as the
existing brightness/scale controls, not persisted to `monitors.lua`.

> **Bar API drift guard:** `Panel.open()`/`close()` in the cloned clock and
> weather widgets touch `bar.centerHoverRevealSuppressed`, which the shell
> made **read-only** (now a `setCenterHoverRevealSuppressed()` setter). If you
> edit these panels on a newer shell, keep the setter-first guard in
> `setCenterHoverRevealSuppressed()` — assigning the property directly throws
> a QML `TypeError` inside `close()` *before* `controller.hide()`, which leaves
> the popup's full-screen click-catcher mapped and the desktop frozen until the
> shell restarts. See CHANGELOG `2026-09-16`.

### Wallpaper → theme pipeline
`configs/wallpaper/` + `configs/portal/` — D-Bus service + theme generator
that makes Nautilus "Set as Background" work on Hyprland. Right-click any
image → Set as Background → full system recolors (borders, bar, terminals,
btop, browser accent, etc.). Requires `python-dbus` and `python-gobject`.

`hyprland-portals.conf` pins `org.freedesktop.impl.portal.Wallpaper` to the
`omarchy` backend explicitly — newer `xdg-desktop-portal-gtk` builds also
implement that interface, and being listed first they would otherwise win and
only write GNOME gsettings keys (nothing renders them on Hyprland). The
installer restarts `xdg-desktop-portal.service` at the end of this step;
`xdg-desktop-portal` only reads `omarchy.portal` and `hyprland-portals.conf`
at startup, so without that restart the feature does nothing until you log out
and back in. If "Set as Background" is silently a no-op on a machine you just
set up, that missing reload is the first thing to check
(`systemctl --user restart xdg-desktop-portal.service`, then retry; a full
re-login is the sure fix).

`wallpaper-to-theme` also guards bar contrast: after `aether` generates the
theme, it samples the average color of the wallpaper's top strip (where the
bar sits) with ImageMagick. If that strip is dark (luminance < 90/255), it
writes a `shell.bar.toml` section override next to the generated theme —
merged onto just the `[bar]` section by `omarchy-theme-set-templates`,
leaving every other surface (popups, menu, controls, ...) on the theme's
normal colors:
- `text` — the theme's foreground, relit to L=0.85 in HSL, so `Color.bar.text`
  (what every `custom.*` bar widget reads) stays legible instead of
  inheriting whatever value `aether` picked.
- `background` + `background-alpha` — the theme's background, relit to
  L=0.16 with alpha dropped to 0.15, so the `CustomPill` chip behind each
  widget (`custom.common/CustomPill.qml`, fixed 55% fill on top of this)
  reads as a faint tint instead of a near-invisible near-black smear or an
  oversaturated block.
On a bright-topped wallpaper no override is written and the theme's normal
colors apply everywhere, unchanged.

### Lock screen (separate from bar)
Clones the stock Omarchy lock service and restyles only the visual layer:
time/date/battery centered, password field hidden until typed, no border,
fully rounded. The PAM/session-lock logic is untouched stock Omarchy.
`shell.json` is patched to load `custom.lock` and disable `omarchy.lock`.

### Hyprland config
`configs/hypr/` — 6 Lua files copied to `~/.config/hypr/`:

- `hyprland.lua` — entry point; loads the other five and optionally pulls in
  `cursor.lua` / `bootlock.lua` via safe `pcall` requires, so missing
  optional files never break the config (stock Omarchy keeps working)
- `bindings.lua` — `Q`=close, `L`=system menu, `E`=file manager, `;`=emoji picker,
  `Shift+S`/`Shift+R`=screenshot/recording, unused app shortcuts unbound
- `input.lua` — natural scroll, 3-finger swipe to switch workspaces
- `looknfeel.lua` — gaps 2/4, border 1px, rounded corners, `resize_on_border`
- `autostart.lua` — launches wallpaper portal backend
- `monitors.lua` — laptop at `0x0`, external Dell U2520D above at `0x-1440`

### Branding
Interactive — prompts you to generate ASCII art at
[patorjk.com/software/taag](https://patorjk.com/software/taag/) and paste it.
Sets custom text for the about screen and lock screen.

### Afterglow cursor
`configs/cursor/` — theme installed to `~/.local/share/icons/Afterglow-cursors/`,
activated via gsettings (GTK), `hyprctl setcursor` (live), and
`XCURSOR`/`HYPRCURSOR` env vars dropped as a separate `cursor.lua` into
`~/.config/hypr/` (loaded by `hyprland.lua` via pcall; persists across restarts).

### Boot lock
`configs/boot-lock/` — SDDM keeps autologging you in, but `bootlock.lua` throws
the lock screen over the session the moment Hyprland starts, so every boot ends
at your password prompt instead of an open desktop. It polls `omarchy-shell
lock lock` every 100ms for up to 10s rather than firing once — `omarchy-shell`
(Quickshell) launches off that same startup event and needs a moment to come
up, so a single one-shot call can lose that race and silently do nothing.
Needs the hyprland module (pcall loader); pairs with the Lock screen module
for visuals, works with the stock lock too.

Depends on SDDM autologin already being active — that's owned by Omarchy's own
installer (on by default for standard, unencrypted installs), not by this repo.
Without autologin, this module still installs and works, it's just redundant
with the SDDM login prompt you'd already be typing a password at.

### Post-update hook
Installs `restore-customizations.hook` via `omarchy hook install post-update`.
After each `omarchy update`, it restores your customizations and **flags a
warning** if the update changed something the repo also manages.

---

## Structure

```
omarchy-configs/
├── install.sh                      # Interactive installer (step-by-step modules)
├── uninstall.sh                    # Interactive uninstaller (revert to stock)
├── install/modules/                # Install modules (one per feature)
│   ├── common.sh                   # Shared menu/copy/backup functions
│   ├── dock.sh                     # Auto-hiding app dock plugin
│   ├── bar.sh                      # shell.json/toml + boxed-pill widget plugins
│   ├── wallpaper-pipeline.sh       # Nautilus portal → theme generation
│   ├── lock.sh                     # Restyled lock screen
│   ├── hyprland.sh                 # Keybindings, input, gaps, monitors
│   ├── branding.sh                 # Custom ASCII art (interactive)
│   ├── cursor.sh                   # Afterglow cursor theme + env vars
│   ├── boot-lock.sh                # Lock screen at boot
│   └── post-update-hook.sh         # Auto-restore after updates
├── install/lock-inject.py          # Patches shell.json to add lock config
├── install/dock-inject.py          # Patches shell.json to add dock config
├── configs/                        # Module-organized config files
│   ├── bar/                        # shell.json, shell.toml, custom.* plugins
│   │   └── plugins/custom.dock/    # App dock plugin (its own module, see above)
│   ├── boot-lock/                  # bootlock.lua (lock on Hyprland start)
│   ├── branding/                   # ASCII art samples (populated during install)
│   ├── cursor/                     # Afterglow cursor theme + cursor.lua
│   ├── hooks/                      # border-from-wallpaper (theme-set hook)
│   ├── hypr/                       # Hyprland Lua configs (+ .luarc.json for linting)
│   ├── portal/                     # omarchy.portal, hyprland-portals.conf
│   └── wallpaper/                  # wallpaper-portal.py, wallpaper-to-theme
├── scripts/
│   └── sync-configs.sh             # Pull live configs back into repo
├── restore-customizations.hook     # Post-update hook (drift detection)
├── recover-customizations.sh       # Restore all (non-interactive)
├── CHANGELOG.md
└── images/
```

---

## Prerequisites

```bash
# For wallpaper pipeline (optional)
sudo pacman -S python-dbus python-gobject
# aether ships with Omarchy — no separate install needed
```

---

## Setup on a new machine

```bash
git clone <repo> ~/omarchy-configs
cd ~/omarchy-configs
./install.sh              # pick what you want
# or
./install.sh --all        # install everything
```

> **After install:** the wallpaper pipeline restarts `xdg-desktop-portal`
> automatically, but if you installed over SSH or the restart is skipped, log
> out and back in before testing Nautilus "Set as Background" — the portal
> backend and routing config are only read at portal startup. If this doesnot work, sign out and sign back in.

---

## Daily workflow

In case you made some tweaks on your own and backing up somewhere.

```bash
# Make a change, test it, sync back to repo, commit
vim ~/.config/omarchy/plugins/custom.clock/BarWidget.qml
# test with: qmllint -I /usr/share/omarchy/shell <file>
# then: omarchy restart shell && journalctl --user -t omarchy-shell --since "-30 seconds"
~/omarchy-configs/scripts/sync-configs.sh
```

Before running `omarchy update`, do a quick `sync-configs.sh` as a snapshot.
The post-update hook restores everything automatically and **flags a warning**
if the update changed something this repo also manages — check for `⚠ DRIFT`
lines and fold in anything worth keeping.
