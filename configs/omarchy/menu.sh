# Overwrite parts of the omarchy-menu with user-specific submenus.
# See $OMARCHY_PATH/bin/omarchy-menu for functions that can be overwritten.
#
# WARNING: Overwritten functions will obviously not be updated when Omarchy changes.
#
# Force shutdown - kills all apps immediately without waiting
show_system_menu() {
  local options="  Lock\n󱄄  Screensaver"
  [ -f ~/.local/state/omarchy/toggles/suspend-on ] && options="$options\n󰒲  Suspend"
  omarchy-hibernation-available && options="$options\n󰤁  Hibernate"
  options="$options\n󰜉  Restart\n󰐥  Shutdown"

  case $(menu "System" "$options") in
  *Lock*) omarchy-lock-screen ;;
  *Screensaver*) omarchy-launch-screensaver force ;;
  *Suspend*) systemctl suspend ;;
  *Hibernate*) systemctl hibernate ;;
  *Restart*) shutdown -r now ;;
  *Shutdown*) shutdown now ;;
  *) back_to show_main_menu ;;
  esac
}
