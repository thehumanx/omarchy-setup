# Personal Omarchy Setup

This repository contains my personal Omarchy Linux configuration files, customizations, and scripts.

![Omarchy by DHH](https://learn.omacom.io/2/the-omarchy-manual)

## 🛠️ Components

### Window Manager & Desktop
- **Hyprland** - Wayland compositor configuration -- customized
- **Waybar** - Status bar with custom modules -- customized
- **Walker** - Application launcher -- default
- **Mako** - Notification daemon -- default

### Terminal & Tools
- **Ghostty** - Terminal emulators -- default
- **Fastfetch** - System information tool -- default
- **Starship** - Custom shell prompt -- default

### Customizations
- **Power Management** - TLP profiles with toggle scripts -- changed from power-profile-daemons
- **Keybindings** - Personalized shortcuts -- customized
- **Themes** - Custom theme configurations 
- **Scripts** - Utility scripts and automation -- customized



## 📁 Repository Structure

```
omarchy-setup/
├── README.md                 # This file
├── CHANGELOG.md              # Changes and fixes documentation
├── install.sh               # (Optional) Installation script
├── post-update             # Hook to restore customizations after updates
├── configs/                 # Configuration files
│   ├── hypr/               # Hyprland configs
│   │   ├── scripts/         # Custom Hypr scripts (including screensaver)
│   │   ├── hyprlock.conf    # Custom lock screen config
│   │   ├── hypridle.conf    # Custom idle/screensaver config
│   │   └── ...
│   ├── waybar/             # Waybar configs and custom scripts
│   ├── walker/             # Walker launcher configs
│   └── ...                 # Other application configs
├── scripts/                # Standalone custom scripts
│   ├── power-mode/         # Power management scripts
│   └── ...                 # Other utility scripts
└── themes/                 # Custom themes (if any)
```

## 🚀 Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/omarchy-setup.git ~/omarchy-setup
   ```

2. Stow the configuration files:
    ```bash
    cd ~/omarchy-setup
    stow configs  # Symlink configs to ~/.config/
    ```

3. Install custom scripts:
    ```bash
    mkdir -p ~/.config/hypr/scripts
    cp configs/hypr/scripts/*.sh ~/.config/hypr/scripts/
    chmod +x ~/.config/hypr/scripts/*.sh
    ```

4. Install post-update hook:
    ```bash
    cp post-update ~/.config/omarchy/hooks/
    chmod +x ~/.config/omarchy/hooks/post-update
    ```

5. Restart services:
    ```bash
    omarchy-restart-waybar
    hyprctl reload
    ```

## ⚠️ Important Notes

- This repository contains **personal** configurations and may not work on all systems
- Always backup your existing configs before applying
- Some scripts may require sudo privileges or additional setup
- Hardware-specific configurations (monitors, power management) may need adjustment

## 🎨 Customizations

![Desktop Screenshot](/images/screenshot-2026-01-31_15-37-53.png)

- [Hyprland] I don't use mouse much, configured so settings for idea touchpad usage
- [Waybar] Changed the look and feel of waybar from flat fill to module containers
- [Waybar] Removed workspace and launcher as i use keyboard short and touchpad to switch between workspace and do not need those indicators and buttons. Replaced it with window title.
- [Waybar] Added Spotify play
- [PWRMGMT] Replaced *power-profile-daemon* with TLP using custom script for powersave and automatic profile toggles for my Lenovo Slim 7i.
- [MISC] Updated look and feel, removed apps, webapps, scripts i do not need.
- [Hyprlock] Unlock required after exit from screensaver (fixed after Omarchy update)
- [Touchpad] 3-finger left-right for workspace, 4-finger top-down for volume

### Power Profiles
- Custom TLP power mode toggle (automatic ↔ powersaver)
- Waybar integration with visual indicators
- Keybinding: `Super + Shift + P`

### Waybar Modules
- Custom power profile indicator
- Enhanced battery display
- System monitoring modules

### Keybindings
- Personalized shortcuts for common applications
- Custom workflow optimizations

## 🔧 Dependencies

Make sure you have these installed:
- Omarchy Linux distribution
- GNU Stow (for symlink management)
- TLP (for power management)
- Various packages depending on your configs

## 📝 Backup & Restore

To backup your current configs:
```bash
cd ~
tar -czf omarchy-backup-$(date +%Y%m%d).tar.gz .config/
```

## 🔧 Maintenance Workflow

### ✅ Do's and ❌ Don'ts

#### 1. Making Config Changes

**✅ DO:**
- Edit configs directly in `~/.config/` 
- Test changes immediately in your system
- Run `~/omarchy-setup/scripts/sync-configs.sh` when done
- Commit and push to git when ready

**❌ DON'T:**
- Edit files directly in `~/omarchy-setup/` (won't affect your system)
- Forget to sync before committing
- Edit files in `~/.local/share/omarchy/` (get overwritten on updates)

**Example Workflow:**
```bash
# Edit configuration
vim ~/.config/hypr/bindings.conf

# Test changes (restart services if needed)
hyprctl reload

# Sync to repo when happy with changes
~/omarchy-setup/scripts/sync-configs.sh

# Commit and push
cd ~/omarchy-setup
git add -A
git commit -m "Updated keybindings"
git push
```

#### 2. Updating Omarchy

**✅ DO:**
- Run `~/omarchy-setup/scripts/sync-configs.sh` BEFORE updating (backup)
- Update with `omarchy-update`
- Run `~/omarchy-setup/recover-customizations.sh` if things break
- Check that custom scripts still work after update

**❌ DON'T:**
- Update without backing up your configs first
- Panic if defaults get overwritten (just run recovery script)

**Update Workflow:**
```bash
# Before update - backup current configs
~/omarchy-setup/scripts/sync-configs.sh

# Update Omarchy
omarchy-update

# If something breaks, restore customizations
~/omarchy-setup/recover-customizations.sh

# Test everything works
SUPER+SHIFT+S  # Test screensaver
```

#### 3. Using GitHub Config in New Setup

**✅ DO:**
1. `git clone <your-repo> ~/omarchy-setup`
2. `cd ~/omarchy-setup`
3. `stow configs` (symlinks to ~/.config/)
4. Install custom scripts manually (scripts inside configs):
   ```bash
   mkdir -p ~/.config/hypr/scripts
   cp configs/hypr/scripts/*.sh ~/.config/hypr/scripts/
   chmod +x ~/.config/hypr/scripts/*.sh
   ```
5. Install post-update hook:
   ```bash
   cp post-update ~/.config/omarchy/hooks/
   chmod +x ~/.config/omarchy/hooks/post-update
   ```
6. Restart services: `hyprctl reload`, `omarchy-restart-waybar`
7. Test keybindings: `SUPER+SHIFT+S` for screensaver

**❌ DON'T:**
- Copy files manually (breaks symlink management)
- Skip testing basic functionality
- Forget to restore backup if installation fails

**New System Setup:**
```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/omarchy-setup.git ~/omarchy-setup

# Install configurations (creates symlinks)
cd ~/omarchy-setup
stow configs

# Install custom scripts manually (scripts are in configs/hypr/scripts/)
mkdir -p ~/.config/hypr/scripts
cp configs/hypr/scripts/*.sh ~/.config/hypr/scripts/
chmod +x ~/.config/hypr/scripts/*.sh

# Install post-update hook
cp post-update ~/.config/omarchy/hooks/
chmod +x ~/.config/omarchy/hooks/post-update

# Restart services to apply changes
omarchy-restart-waybar
hyprctl reload

# Test custom features
SUPER+SHIFT+S  # Test custom screensaver with lock
```

### 🔄 Custom Scripts and Features

This setup includes custom modifications that are safe from Omarchy updates:

- **Custom Screensaver System**: `~/.config/hypr/scripts/` - Fixed screensaver with Python path compatibility and lock on exit
- **Power Management**: Custom TLP profiles with toggle scripts
- **Enhanced Hyprlock**: Fixed deprecated configuration options (removed animations, updated settings)
- **Keybinding Customizations**: Personalized shortcuts and workflows
- **Update Resilience**: Post-update hook to restore customizations automatically

**Important:** These customizations live in `~/.config/hypr/` and are synced to repo, making them safe from Omarchy updates.

### 🔧 Recent Fixes (Post-Update Issues)
**Problem**: After Omarchy update, screensaver crashed with Python module errors and hyprlock configuration errors.

**Solutions Applied**:
1. **Python Path Fix**: Added `PYTHONPATH="/usr/lib/python3.13/site-packages:$PYTHONPATH"` to custom screensaver for Python 3.13/3.14 compatibility
2. **Hyprlock Configuration**: Removed deprecated options (`fade_on_empty_timeout`, `placeholder_text_fade_time`, specific animations)
3. **Post-Update Hook**: Ensures customizations survive future updates
4. **Clean Separation**: Standalone custom screensaver implementation (doesn't modify omarchy defaults)

**Working Configuration**:
- ✅ **Ctrl+Super+S**: Standalone custom screensaver → fade transition → locks after exit
- ❌ **Omarchy system option**: Original screensaver → no lock (untouched)
- ✅ **Update Resilience**: Automatic restoration via post-update hook
- ✅ **No Conflicts**: Clean separation between custom and omarchy implementations
- ✅ **Smooth Transition**: Subtle fade when moving from screensaver to lock screen

## 🤝 Contributing

This is a personal repository, but feel free to:
- Fork for your own setup
- Submit issues or suggestions
- Adapt configurations for your needs

## 📄 License

Personal use - feel free to adapt for your own setup.