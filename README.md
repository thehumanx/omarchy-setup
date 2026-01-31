# Personal Omarchy Setup

This repository contains my personal Omarchy Linux configuration files, customizations, and scripts.

## 🛠️ Components

### Window Manager & Desktop
- **Hyprland** - Wayland compositor configuration
- **Waybar** - Status bar with custom modules
- **Walker** - Application launcher
- **Mako** - Notification daemon

### Terminal & Tools
- **Ghostty** - Terminal emulators -- default
- **Fastfetch** - System information tool -- default
- **Starship** - Custom shell prompt

### Customizations
- **Power Management** - TLP profiles with toggle scripts
- **Keybindings** - Personalized shortcuts
- **Themes** - Custom theme configurations
- **Scripts** - Utility scripts and automation

## 📁 Repository Structure

```
omarchy-setup/
├── README.md                 # This file
├── install.sh               # (Optional) Installation script
├── configs/                 # Configuration files
│   ├── hypr/               # Hyprland configs
│   ├── waybar/             # Waybar configs and custom scripts
│   ├── walker/             # Walker launcher configs
│   └── ...                 # Other application configs
├── scripts/                # Custom scripts
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

3. Restart services:
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

## 🤝 Contributing

This is a personal repository, but feel free to:
- Fork for your own setup
- Submit issues or suggestions
- Adapt configurations for your needs

## 📄 License

Personal use - feel free to adapt for your own setup.