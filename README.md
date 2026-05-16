# Personal Omarchy Setup

Customizations on top of [Omarchy Linux](https://omarchy.org/) by DHH.

![Desktop](/images/screenshot-2026-05-16_21-22-58.png)

## What's Customized

All changes live in `~/.config/` and survive Omarchy updates.

### Hyprland (Window Manager)

| Config | Stock Omarchy | Custom |
|--------|---------------|--------|
| `autostart.conf` | Generic startup | Restores power mode & bluetooth state from last session |
| `bindings.conf` | Default keybinds | Rebind: `Q`=close, `L`=system menu, `S`=screenshot, `R`=screenrecording, `Ctrl+L`=screensaver. Custom brightness with 1% precision |
| `hypridle.conf` | Default timeouts | Screensaver at 2.5min, lock at 5min, improved DPMS handling |
| `hyprlock.conf` | Theme defaults | Clock, date, battery status; fingerprint auth enabled |
| `input.conf` | Basic touchpad | Natural scroll, 3-finger workspace swipe, 4-finger volume control, scroll_factor 1.0 |
| `looknfeel.conf` | gaps=5/10, border=2 | Tighter gaps (2/4), border=1, resize_on_border, blur config, group settings, 20+ animation curves, dwindle/master layout |
| `monitors.conf` | No default | Scale 1.15 for 13" 2.8K display (GDK_SCALE=2) |
| `screensaver-script.sh` | None | Custom TTE screensaver with lock on keypress |
| `scripts/custom-screensaver-launch.sh` | None | Multi-monitor screensaver launcher, fades to lock on exit |
| `hyprland.conf` | Sources stock looknfeel | Sources custom `~/.config/hypr/looknfeel.conf` instead |

### Waybar (Status Bar)

| Config | Stock Omarchy | Custom |
|--------|---------------|--------|
| `config.jsonc` | left: omarchy+workspaces, right: cpu+battery | left: window title, center: 10 modules (print-status, media, weather, bluetooth, notifications, idle, voxtype), right: tray, memory, power-mode. Height 30 |
| `style.css` | Solid background bar | Each module is a self-contained pill: semi-transparent background, 8px radius, 3px margins. Transparent bar background |
| `indicators/` | Default set | Custom TLP power mode indicator, bluetooth state, media status |

### Power Management

Custom 3-mode TLP control (default/powersave/performance):
- `power-mode-toggle.sh` - cycle or set mode, manages Intel turbo boost
- `power-mode-status.sh` - Waybar integration with icons
- Bound to `Super+Shift+P`

### System Tweaks

- `force-shutdown.sh` - instant shutdown, skips waiting for apps
- Custom `logind.conf` - power button behavior

## Structure

```
omarchy-setup/
├── configs/
│   ├── hypr/               # Hyprland configs + scripts/
│   ├── waybar/             # Waybar config + indicators/
│   ├── omarchy/
│   │   ├── power-mode/     # TLP toggle and status scripts
│   │   ├── branding/       # ASCII art (about, screensaver)
│   │   ├── extensions/     # System menu overrides
│   │   ├── hooks/          # Post-update restore hook
│   │   └── bluetooth-state.sh
│   └── system-tweaks/      # Force shutdown, logind
├── scripts/
│   └── sync-configs.sh     # Sync live configs back to repo
├── post-update             # Hook: restores configs after omarchy-update
├── recover-customizations.sh  # Manual restore (same as post-update)
└── images/                 # Screenshots
```

## Setup on New System

```bash
git clone <repo> ~/omarchy-setup
cd ~/omarchy-setup
./scripts/sync-configs.sh
mkdir -p ~/.config/omarchy/hooks
cp post-update ~/.config/omarchy/hooks/
chmod +x ~/.config/omarchy/hooks/post-update
omarchy restart waybar
hyprctl reload
```

## Workflow

```bash
# Edit → Test → Sync → Commit
vim ~/.config/waybar/style.css
# test...
~/omarchy-setup/scripts/sync-configs.sh
cd ~/omarchy-setup && git add -A && git commit -m "..." && git push
```

Before `omarchy-update`, run `sync-configs.sh` as backup. If defaults get overwritten, `recover-customizations.sh` restores everything.
