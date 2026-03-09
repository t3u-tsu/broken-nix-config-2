# Niri Configuration

This directory manages the Niri scrollable-tiling Wayland compositor and its ecosystem.

## 📂 Components

- **`default.nix`**: Core Niri settings, including layout, window rules, and keybindings (Omarchy + Vim style).
- **`noctalia.nix`**: Integration with `noctalia-shell` for status bars and launchers.
- **`addons.nix`**: Companion tools like `fuzzel`, `swaync`, `swayosd`, and `nautilus`.
- **`power.nix`**: Power management and locking via `hyprlock` and `hypridle`.

## ⌨️ Keybindings Highlights

- `Mod + Return`: Terminal (Alacritty)
- `Mod + Shift + B`: Browser (Zen)
- `Mod + Space`: Launcher (Noctalia)
- `Mod + W`: Close window
- `Mod + H/J/K/L`: Navigation (Vim-style)
- `Mod + Arrow Keys`: Navigation (Standard)
- `Mod + V`: Toggle floating
