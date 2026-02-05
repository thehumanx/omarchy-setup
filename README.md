# Personal Omarchy Setup

This repository contains my personal Omarchy Linux configuration files, customizations, and scripts.

[Omarchy by DHH](https://omarchy.org/)

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
- **Force Shutdown** - Instant shutdown without waiting for apps to close
- **Keybindings** - Personalized shortcuts -- customized
- **Themes** - Custom theme configurations 
- **Scripts** - Utility scripts and automation -- customized

## 📁 Repository Structure

```
omarchy-setup/
├── README.md                 # This file
├── CHANGELOG.md              # Changes and fixes documentation (optional)
├── install.sh               # (Optional) Installation script
├── post-update             # Hook to restore customizations after updates
├── recover-customizations.sh # Manual recovery script
├── configs/                 # Configuration files
│   ├── hypr/               # Hyprland configs
│   │   ├── scripts/         # Custom Hypr scripts (including screensaver)
│   │   ├── hyprlock.conf    # Custom lock screen config
│   │   ├── hypridle.conf    # Custom idle/screensaver config
│   │   └── ...
│   ├── waybar/             # Waybar configs and custom scripts
│   ├── walker/             # Walker launcher configs
│   ├── system-tweaks/      # System-level tweaks (force-shutdown, logind)
│   ├── omarchy/            # Omarchy extensions and hooks
│   │   ├── extensions/     # Menu overrides and extensions
│   │   └── hooks/          # Post-update hook
│   └── ...                 # Other application configs
├── scripts/                # Standalone custom scripts
│   ├── power-mode/         # Power management scripts
│   └── sync-configs.sh     # Config backup/sync script
└── backup-scripts/         # Backup of modified omarchy scripts (if needed)
```

## 🚀 Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/omarchy-setup.git ~/omarchy-setup
   ```

2. Run the sync script to copy configs to your system:
   ```bash
   cd ~/omarchy-setup
   ./scripts/sync-configs.sh
   ```

3. Install post-update hook:
   ```bash
   mkdir -p ~/.config/omarchy/hooks
   cp post-update ~/.config/omarchy/hooks/
   chmod +x ~/.config/omarchy/hooks/post-update
   ```

4. Restart services:
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

### Key Features

- **[Hyprland]** Touchpad-optimized settings (minimal mouse usage)
- **[Waybar]** Module container design, removed workspace/launcher, added window title and Spotify
- **[Power]** TLP power profiles with toggle scripts for Lenovo Slim 7i
- **[Screensaver]** Custom screensaver with Spotify integration and lock on exit
- **[Shutdown]** Force shutdown option in system menu (kills all apps immediately)
- **[Hyprlock]** Clock, Spotify music, and custom user image
- **[Touchpad]** 3-finger swipe for workspaces, 4-finger for volume
- **[Input]** Natural scroll and custom scroll factor

### Force Shutdown
A custom shutdown option in the system menu that forces immediate shutdown without waiting for applications to close.

- **Location:** `~/.config/system-tweaks/force-shutdown.sh`
- **Menu Override:** `~/.config/omarchy/extensions/menu.sh`
- **Safe for updates:** Lives in `~/.config/` (user directory)

**Use case:** When your system has been running for a long time or after hibernation, and the normal shutdown hangs due to frozen applications.

### Power Profiles
- Custom TLP power mode toggle (automatic ↔ powersaver)
- Waybar integration with visual indicators
- Keybinding: `Super + Shift + P`

### Waybar Modules
- Custom power profile indicator
- Enhanced battery display
- System monitoring modules
- Spotify integration

### Keybindings
- Personalized shortcuts for common applications
- Custom workflow optimizations
- `Super + Ctrl + L` - Custom screensaver with lock

## 🔧 Dependencies

Make sure you have these installed:
- Omarchy Linux distribution
- TLP (for power management)
- Various packages depending on your configs

## 📝 Backup & Restore

### Sync Configs to Repo (Backup)
```bash
~/omarchy-setup/scripts/sync-configs.sh
cd ~/omarchy-setup
git add -A
git commit -m "Update configs"
git push
```

### Manual Recovery (If Update Breaks Things)
```bash
~/omarchy-setup/recover-customizations.sh
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
- Check that custom features still work after update
- Run `~/omarchy-setup/recover-customizations.sh` if things break

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

# Test custom features
SUPER+CTRL+L  # Test custom screensaver
```

#### 3. Using GitHub Config in New Setup

**✅ DO:**
1. `git clone <your-repo> ~/omarchy-setup`
2. `cd ~/omarchy-setup`
3. `./scripts/sync-configs.sh` (copies configs to ~/.config/)
4. Install post-update hook:
   ```bash
   mkdir -p ~/.config/omarchy/hooks
   cp post-update ~/.config/omarchy/hooks/
   chmod +x ~/.config/omarchy/hooks/post-update
   ```
5. Restart services: `hyprctl reload`, `omarchy-restart-waybar`
6. Test keybindings: `SUPER+CTRL+L` for screensaver

**❌ DON'T:**
- Skip testing basic functionality
- Forget to restore backup if installation fails

**New System Setup:**
```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/omarchy-setup.git ~/omarchy-setup

# Install configurations
cd ~/omarchy-setup
./scripts/sync-configs.sh

# Install post-update hook
mkdir -p ~/.config/omarchy/hooks
cp post-update ~/.config/omarchy/hooks/
chmod +x ~/.config/omarchy/hooks/post-update

# Restart services to apply changes
omarchy-restart-waybar
hyprctl reload

# Test custom features
SUPER+CTRL+L  # Test custom screensaver with lock
```

### 🔄 Custom Scripts and Features

This setup includes custom modifications that are safe from Omarchy updates:

- **Custom Screensaver System**: `~/.config/hypr/scripts/` - Python path compatible screensaver with lock on exit
- **Force Shutdown**: `~/.config/system-tweaks/` - Instant shutdown without waiting for apps
- **Menu Extensions**: `~/.config/omarchy/extensions/` - System menu overrides
- **Power Management**: Custom TLP profiles with toggle scripts
- **Enhanced Hyprlock**: Added clock, Spotify play and user image
- **Update Resilience**: Post-update hook automatically restores customizations

**Important:** These customizations live in `~/.config/` and are synced to repo, making them safe from Omarchy updates.

## 🤝 Contributing

This is a personal repository, but feel free to:
- Fork for your own setup
- Submit issues or suggestions
- Adapt configurations for your needs

## 📄 License

Personal use - feel free to adapt for your own setup.
