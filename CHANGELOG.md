# Changelog - Omarchy Setup

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
- **Current Behavior**:
  - ✅ Ctrl+Super+S → screensaver → locks after exit
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
    └── custom-screensaver-launch.sh    # Standalone screensaver launcher (no omarchy dependency)

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