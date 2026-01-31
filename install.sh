#!/bin/bash

# Installation script for Personal Omarchy Setup
# This script symlinks configuration files from this repo to ~/.config/

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Installing Personal Omarchy Setup${NC}"
echo "Repository directory: $REPO_DIR"
echo "Target directory: $CONFIG_DIR"
echo

# Function to backup existing configs
backup_config() {
    local config_path="$1"
    if [ -e "$config_path" ] && [ ! -L "$config_path" ]; then
        local backup_name="${config_path}.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${YELLOW}⚠️  Backing up existing config: $config_path -> $backup_name${NC}"
        mv "$config_path" "$backup_name"
    fi
}

# Function to create symlink
create_symlink() {
    local source="$1"
    local target="$2"
    
    backup_config "$target"
    
    if [ ! -e "$target" ]; then
        echo -e "${GREEN}✓ Creating symlink: $target -> $source${NC}"
        ln -s "$source" "$target"
    else
        echo -e "${YELLOW}⚠️  Target already exists: $target${NC}"
    fi
}

# Install configs using stow (if available) or manual symlinking
if command -v stow >/dev/null 2>&1; then
    echo -e "${GREEN}📦 Using GNU Stow to manage symlinks${NC}"
    cd "$REPO_DIR"
    stow -t "$HOME" configs
    stow -t "$HOME" scripts
else
    echo -e "${YELLOW}⚠️  GNU Stow not found, creating symlinks manually${NC}"
    
    # Manual symlinking for configs
    for app_dir in "$REPO_DIR/configs"/*; do
        if [ -d "$app_dir" ]; then
            app_name=$(basename "$app_dir")
            create_symlink "$app_dir" "$CONFIG_DIR/$app_name"
        fi
    done
    
    # Manual symlinking for scripts
    for script_dir in "$REPO_DIR/scripts"/*; do
        if [ -d "$script_dir" ]; then
            script_name=$(basename "$script_dir")
            create_symlink "$script_dir" "$CONFIG_DIR/omarchy/$script_name"
        fi
    done
fi

echo
echo -e "${GREEN}✅ Installation complete!${NC}"
echo
echo "Next steps:"
echo "1. Restart services to apply changes:"
echo "   omarchy-restart-waybar"
echo "   hyprctl reload"
echo
echo "2. Check that everything works correctly"
echo
echo "3. If you encounter issues, restore from the backup files created"