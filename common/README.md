# Common Configuration Modules (common/)

This directory contains NixOS configuration modules shared across all hosts or specific groups of hosts.

## Modules

### 1. `default.nix`
The base integration module that imports everything below.

### 2. `nix.nix`
Nix package manager settings.
- Enables experimental features (flakes, nix-command).
- Configures binary caches (Cachix).
- Defines `trusted-users`.

### 3. `time.nix`
Timezone and regional settings.
- Timezone: `Asia/Tokyo` (JST).
- Enables high-precision time sync via `chrony`.

### 4. `wireguard.nix`
WireGuard resilience settings.
- Automatically adds retry policies (`Restart=on-failure`) to all WireGuard peer services to handle transient DNS failures on boot.

### 5. `local-network.nix`
Provides local network optimization flag (`my.localNetwork.enable`).
- Handles local DNS resolution to bypass NAT loopback issues.

### 6. `tower-server/` (Directory)
Standard configuration set for tower-style (x86_64) servers.
- Unifies user environments, SSH security, SOPS, and auto-update settings for `shosoin-tan`, `kagutsuchi-sama`, and `sando-kun`.
