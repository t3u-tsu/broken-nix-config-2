# My NixOS Fleet

This repository manages multiple NixOS configurations using Flakes. It is designed for cross-compilation and secure secret management.

## Directory Structure

```text
.
├── flake.nix           # Entry point for the configuration
├── hosts/              # Host-specific configurations
│   └── torii-chan/     # Orange Pi Zero3 configuration
├── lib/                # Common library functions for mkSystem
└── secrets/            # Encrypted secrets (SOPS)
    └── secrets.yaml
```

## Hosts

- **torii-chan**: Orange Pi Zero3 (Allwinner H618)
  - Role: Gateway, WireGuard Server, DDNS
  - CPU: Allwinner H618, RAM: 1GB
  - Storage: 64GB microSD (Boot), 500GB HDD (Root)
- **shosoin-tan**: Tower Server
  - Role: Home Server, ZFS Storage
  - CPU: Core i7 870, GPU: Quadro K2200, RAM: 16GB
  - Storage: 480GB SSD (Root), 1TB x2 + 320GB x2 (ZFS Mirror), 2TB HDD (Backup)
- **kagutsuchi-sama**: High-power Tower Server
  - Role: Compute / Heavy Workloads
  - CPU: Xeon E5-2650 v2, GPU: GTX 980 Ti, RAM: 16GB
  - Storage: 500GB SSD (Root), 3TB + 160GB HDD

## Key Technologies

- **Flakes:** For reproducible builds and dependency management.
- **sops-nix:** For encrypting secrets (passwords, API keys) via `age`.
- **Cross-Compilation:** Building aarch64 (ARM) images on x86_64 machines.

## Getting Started

To explore a specific host, navigate to its directory in `hosts/` and read the local README.
