#!/bin/bash

# sync-configs.sh - Sync actual config files to omarchy-setup repo
# This script copies real config files (not symlinks) to the repo for GitHub backup

set -euo pipefail

# Configuration
REPO_DIR="$HOME/omarchy-setup"
CONFIG_DIR="$HOME/.config"
SOURCE_DIR="$REPO_DIR/configs"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Sync a single config directory
sync_config() {
    local app_name="$1"
    local src="$CONFIG_DIR/$app_name"
    local dst="$SOURCE_DIR/$app_name"
    
    if [[ -d "$src" ]]; then
        log_info "Syncing $app_name..."
        
        # Remove existing destination
        rm -rf "$dst"
        
        # Copy all files (excluding symlinks to prevent circular references)
        mkdir -p "$dst"
        find "$src" -type f ! -path "*/.git/*" ! -path "*/cache/*" ! -path "*/__pycache__/*" -exec cp {} "$dst/" \;
        
        # Copy directories (non-recursive for specific ones)
        for subdir in "$src"/*; do
            if [[ -d "$subdir" ]]; then
                subdir_name=$(basename "$subdir")
                # Skip common cache/temp directories
                if [[ "$subdir_name" =~ ^(cache|__pycache__|\.git|tmp|log|backup)$ ]]; then
                    continue
                fi
                # Copy subdirectory contents
                find "$subdir" -type f ! -path "*/.git/*" ! -path "*/cache/*" ! -path "*/__pycache__/*" -exec cp {} "$dst/" \;
            fi
        done
        
        log_success "Synced $app_name"
    else
        log_warning "$app_name not found, skipping"
    fi
}

# Sync specific config files
sync_files() {
    local app_name="$1"
    shift
    local files=("$@")
    local dst="$SOURCE_DIR/$app_name"
    
    mkdir -p "$dst"
    
    for file in "${files[@]}"; do
        local src="$CONFIG_DIR/$file"
        if [[ -f "$src" ]]; then
            cp "$src" "$dst/"
            log_success "Synced $file"
        else
            log_warning "$file not found, skipping"
        fi
    done
}

# Main sync process
main() {
    log_info "Starting config sync to omarchy-setup..."
    
    # Ensure repo directory exists
    if [[ ! -d "$REPO_DIR" ]]; then
        log_error "omarchy-setup directory not found!"
        exit 1
    fi
    
    # Create configs directory
    mkdir -p "$SOURCE_DIR"
    
    # Sync main configuration directories
    sync_config "hypr"
    sync_config "waybar" 
    sync_config "walker"
    sync_config "mako"
    sync_config "btop"
    sync_config "fastfetch"
    sync_config "lazygit"
    sync_config "ghostty"
    sync_config "alacritty"
    sync_config "kitty"
    sync_config "system-tweaks"
    sync_config "omarchy"
    
    
    # Sync specific individual files
    sync_files "starship" "starship.toml"
    sync_files "git"
    
    # Sync custom omarchy configurations if they exist
    if [[ -d "$CONFIG_DIR/omarchy/themes" ]]; then
        sync_config "omarchy/themes"
    fi
    
    if [[ -d "$CONFIG_DIR/omarchy/hooks" ]]; then
        sync_config "omarchy/hooks"
    fi
    
    # Sync omarchy extensions (menu overrides, etc.)
    if [[ -d "$CONFIG_DIR/omarchy/extensions" ]]; then
        sync_config "omarchy/extensions"
    fi
    
    # Sync standalone system-tweaks scripts
    if [[ -d "$CONFIG_DIR/system-tweaks" ]]; then
        log_info "Syncing system-tweaks..."
        mkdir -p "$SOURCE_DIR/system-tweaks"
        find "$CONFIG_DIR/system-tweaks" -type f -name "*.sh" -exec cp {} "$SOURCE_DIR/system-tweaks/" \;
        log_success "Synced system-tweaks"
    fi
    
    # Sync custom hypr scripts  
    if [[ -d "$HOME/.config/hypr/scripts" ]]; then
        log_info "Syncing custom hypr scripts..."
        mkdir -p "$SOURCE_DIR/hypr/scripts"
        find "$HOME/.config/hypr/scripts" -type f -executable -exec cp {} "$SOURCE_DIR/hypr/scripts/" \;
        log_success "Synced hypr scripts"
    fi
    
    # Sync standalone hypr scripts (in root hypr dir)
    find "$CONFIG_DIR/hypr" -maxdepth 1 -name "*.sh" -type f -exec cp {} "$SOURCE_DIR/hypr/" \; 2>/dev/null || true
    
    log_success "All configurations synced!"
    echo
    echo "Next steps:"
    echo "cd ~/omarchy-setup && git add -A && git commit -m 'Update configs' && git push"
}

main "$@"
