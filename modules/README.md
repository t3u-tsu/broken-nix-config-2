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

### 5. `packages/` (Directory)
Modularized system package lists.
- `core.nix`: Essential CLI utilities.
- `monitoring.nix`: System monitor and hardware tools.
- `network-tools.nix`: Networking utilities.
- `data.nix`: Data processing and archives.
- `nix-tools.nix`: Nix ecosystem tools.
- `security.nix`: Security and encryption tools.
- `default.nix`: Integrates all of the above.

### 6. `tower-server/` (Directory)
Standard configuration set for tower-style (x86_64) servers.
- Unifies user environments, SSH security, SOPS, and auto-update settings for `shosoin-tan`, `kagutsuchi-sama`, and `sando-kun`.

## Operational Notes

### Kernel Pinning (6.18)
Due to a major regression in kernel 6.19.4 in `nixos-unstable` (causing unbootable systems), all hosts have their `boot.kernelPackages` pinned to the **6.18** branch via `lib.mkForce`. It is recommended to keep this pin until the issue is confirmed resolved in newer releases.

### IPv4 Prioritization (`gai.conf`)
To improve network stability and speed in environments with dual-stack connectivity, `/etc/gai.conf` is configured with `precedence ::ffff:0:0/96 100` to prioritize IPv4 traffic.
