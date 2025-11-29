# Dotfiles Configuration for Hyprland & ML4W

This dotfiles repository manages a complete Hyprland-based desktop environment with ML4W (My Linux for Work) enhancements. It provides a modular, customizable, and production-ready configuration for Wayland-based workflows, focusing on productivity, aesthetics, and seamless integration across applications.

## Configuration Status
- Actively refining Hyprland into a fully custom, optimized setup
- Core configuration: `~/.config/hypr/hyprland.conf`
- Simplified modular design with 5 main config files
- Each file focuses on a specific aspect of the configuration
- Focus areas: window management, workspace organization, and application integration

## Hyprland Configuration Files
The Hyprland configuration has been reorganized into 5 main files for better maintainability:

### appearance.conf
Contains all visual settings including:
- Color definitions from the theme system
- Cursor configuration and sizing
- Window borders, rounding, and gaps
- Layer rules for blur effects (SwayNC, Waybar)
- Window styling and layout parameters

### input.conf
Manages keyboard bindings and touch gestures:
- Application shortcuts (browser, file manager, etc.)
- Window management controls (move, resize, focus)
- Workspace navigation and assignment
- System actions (screenshot, power menu, settings)
- Touchpad gestures for workspace switching
- Function key bindings (volume, brightness, media)

### dispatch.conf
Handles application-specific rules and workspace assignments:
- Workspace assignment rules for specific applications
- Window floating and positioning rules
- Application-specific sizing and behavior
- XDG portal and file picker configurations
- Browser PiP and utility application rules

### workspace.conf
Manages workspace and monitor configuration:
- Monitor detection and setup
- Workspace-to-monitor assignments
- Multi-monitor workspace layout
- Special workspace configurations

### utils.conf
Contains system utilities and environment setup:
- Autostart applications and services
- Environment variables for applications
- Input device sensitivity and behavior
- System miscellaneous settings
- XWayland configuration
- Clipboard and notification daemon setup

All files include commented ML4W default configurations at the bottom for reference.

## Hyprland
- Core Wayland compositor with advanced window management
- Modular configuration via `source = ~/.config/hypr/...`
- Key config: `hyprland.conf`, `appearance.conf`, `input.conf`, `dispatch.conf`, `workspace.conf`, `utils.conf`
- Reload: `hyprctl reload` or `SUPER + CTRL + R`
- Main mod key: `$mainMod = SUPER`

## ML4W (My Linux for Work)
- Productivity-focused application suite
- Includes custom scripts for app launching, theme switching, and system automation
- Key scripts: `executable_launcher.sh`, `executable_toggle-theme.sh`, `executable_listeners.sh`
- Workspace rules for app placement (e.g., Firefox on workspace 2)

## Waybar
- Modern, lightweight status bar with dynamic theming
- Config: `waybar/config`, `waybar/style.css`
- Reload: `SUPER + SHIFT + B`
- Supports dynamic themes via `executable_themeswitcher.sh`

## Nwg-Dock-Hyprland
- Customizable dock with blur effects and animations
- Config: `nwg-dock-hyprland/style.css`, `nwg-dock-hyprland/launch.sh`
- Reload: `SUPER + SHIFT + D`

## Rofi
- Application launcher and menu system
- Config: `rofi/config.rasi`, `rofi/colors.rasi`
- Launch: `SUPER + RETURN`
- Supports clipboard history via `config-cliphist.rasi`

## SwayNC
- Notification daemon with blur effects and custom styling
- Config: `swaync/config.json`, `swaync/notifications.css`
- Launch: Autostarted via `autostart.conf`

## ML4W Scripts
- Automation suite for desktop management
- Key scripts: `executable_wallpaper.sh`, `executable_power.sh`, `executable_launcher.sh`, `executable_keybindings.sh`
- Managed via `~/.config/ml4w/scripts/`

## Build/Lint/Test Commands
All build, lint, and test commands are available via `justfile`.

## Code Style Guidelines
- Use consistent 4-space indentation
- File names: lowercase with hyphens (e.g., `executable_launcher.sh`)
- Shell scripts: use `#!/bin/bash` shebang
- Functions: use `function_name()` syntax
- Variable naming: lowercase with underscores
- Error handling: use `set -euo pipefail` in scripts when robustness is needed
- Follow shell scripting best practices
- Use relative paths or environment variables
- Use inline comments for clarity
- Maintain consistent indentation and spacing