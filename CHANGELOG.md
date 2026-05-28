# Changelog - Omarchy Setup

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