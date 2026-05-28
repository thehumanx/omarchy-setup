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
| `looknfeel.conf` | gaps=5/10, border=2 | Tighter gaps (2/4), border=1, resize_on_border, blur config, group settings, 20+ animation curves, dwindle/master layout. **Shadow disabled on battery** for power savings |
| `monitors.conf` | No default | Scale 1.15 for 13" 2.8K display (GDK_SCALE=2) |
| `screensaver-script.sh` | None | Custom TTE screensaver with lock on keypress |
| `scripts/custom-screensaver-launch.sh` | None | Multi-monitor screensaver launcher, fades to lock on exit |
| `hyprland.conf` | Sources stock looknfeel | Sources custom `~/.config/hypr/looknfeel.conf` instead. Afterglow cursor theme |

### Waybar (Status Bar)

| Config | Stock Omarchy | Custom |
|--------|---------------|--------|
| `config.jsonc` | left: omarchy+workspaces, right: cpu+battery | left: window title, center: 10 modules (print-status, media, weather, bluetooth, notifications, idle, voxtype), right: tray, memory, power-mode. Height 30 |
| `style.css` | Solid background bar | Each module is a self-contained pill: semi-transparent background, 8px radius, 3px margins. Transparent bar background |
| `indicators/` | Default set | Custom TLP power mode indicator (needs `upower` + `bc`), bluetooth state, media status (needs `playerctl`) |

### Power Management (TLP)

Custom 3-mode TLP control (default/powersave/performance):
- `power-mode-toggle.sh` - cycle or set mode, manages Intel turbo boost (requires `sudo` for TLP)
- `power-mode-status.sh` - Waybar integration with icons
- Bound to `Super+Shift+P`
- **Dependencies:** `tlp`, `upower`, `bc`, `libnotify`
- **Sudo:** Passwordless `sudo tlp` required — see [Prerequisites](#prerequisites)

**Battery optimization config** (`configs/tlp/99-battery.conf`):
- Caps CPU max frequency to 800MHz on battery, 400MHz on powersave
- Limits Intel GPU to 400MHz (battery) / 200MHz (powersave)
- Forces PCI Express ASPM to `powersupersave`
- Sets platform profile to `low-power` on battery
- Aggressive SATA link power management and disk APM
- Deployed to `/etc/tlp.d/99-battery.conf` (requires `sudo`)

> **FYI:** `INTEL_GPU_*` and `PLATFORM_PROFILE_ON_BAT` params are Intel-specific. TLP silently ignores unsupported options on other hardware — no errors, they just won't apply. The CPU/ASPM/disk settings work on any laptop. This config is safe for all systems.

### System Tweaks

- `force-shutdown.sh` - instant shutdown, skips waiting for apps
- Custom `logind.conf` - power button behavior (copy to `/etc/systemd/logind.conf.d/`)
- **Sysctl battery tuning** (`configs/sysctl/99-sysctl.conf`): `vm.swappiness=10` — deployed to `/etc/sysctl.d/99-battery.conf` (requires `sudo`)
- **THP madvise** (`configs/sysctl/transparent_hugepage.conf`): avoids compaction CPU spikes — deployed to `/etc/tmpfiles.d/transparent_hugepage.conf` (takes effect on next boot)

## Structure

```
omarchy-setup/
├── configs/
│   ├── hypr/               # Hyprland configs + scripts/
│   ├── waybar/             # Waybar config + indicators/
│   ├── icons/              # Afterglow cursor theme
│   ├── sysctl/             # Kernel tuning (swappiness, THP)
│   ├── tlp/                # Battery optimization config
│   ├── omarchy/
│   │   ├── power-mode/     # TLP toggle and status scripts
│   │   ├── branding/       # ASCII art (about, screensaver)
│   │   ├── extensions/     # System menu overrides
│   │   ├── hooks/          # Post-update restore hook
│   │   └── bluetooth-state.sh
│   ├── system-tweaks/      # Force shutdown, logind
│   └── opencode/           # opencode config (memory plugin)
├── scripts/
│   └── sync-configs.sh     # Sync live configs back to repo
├── post-update             # Hook: restores configs after omarchy-update
├── recover-customizations.sh  # Manual restore (same as post-update)
└── images/                 # Screenshots
```

## Prerequisites

Install these packages before running setup:

```bash
# Power management (3-mode TLP toggle: default/powersave/performance)
sudo pacman -S tlp upower bc

# Media & notifications
sudo pacman -S playerctl mako pamixer libnotify jq

# Bluetooth
sudo pacman -S bluez bluez-utils

# Printing (status indicator)
sudo pacman -S cups

# Screensaver (Python module — note the version below)
pip install terminaltexteffects
```

**Sudo access for TLP:** The power mode toggle (`power-mode-toggle.sh`) runs `sudo tlp`. Add a sudoers rule to avoid password prompts:

```bash
echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/tlp" | sudo tee /etc/sudoers.d/tlp
```

**Python path for screensaver:** If `terminaltexteffects` is installed under a different Python version than the system default, set the path in `~/.config/hypr/scripts/custom-screensaver-launch.sh`:

```bash
export PYTHONPATH="/usr/lib/python3.13/site-packages:$PYTHONPATH"
```

## Setup on New System

```bash
git clone <repo> ~/omarchy-setup
cd ~/omarchy-setup
./scripts/sync-configs.sh
mkdir -p ~/.config/omarchy/hooks
cp post-update ~/.config/omarchy/hooks/
chmod +x ~/.config/omarchy/hooks/post-update

# System-wide configs (requires sudo)
sudo cp configs/tlp/99-battery.conf /etc/tlp.d/
sudo cp configs/sysctl/99-sysctl.conf /etc/sysctl.d/99-battery.conf
sudo sysctl -p /etc/sysctl.d/99-battery.conf
sudo cp configs/sysctl/transparent_hugepage.conf /etc/tmpfiles.d/
# Reboot or apply manually:
echo madvise | sudo tee /sys/kernel/mm/transparent_hugepage/enabled

# Bluetooth off (persists via systemd-rfkill)
sudo rfkill block bluetooth

omarchy restart waybar
hyprctl reload
```

**Note:** `post-update` restores all `~/.config/` files automatically after Omarchy updates, but `/etc/` configs (TLP, sysctl) must be restored manually.

## Workflow

```bash
# Edit → Test → Sync → Commit
vim ~/.config/waybar/style.css
# test...
~/omarchy-setup/scripts/sync-configs.sh
cd ~/omarchy-setup && git add -A && git commit -m "..." && git push
```

Before `omarchy-update`, run `sync-configs.sh` as backup. If defaults get overwritten, `recover-customizations.sh` restores everything.
