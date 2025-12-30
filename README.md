# My NixOS Fleet

This repository manages multiple NixOS configurations using Flakes. It is designed for secure, reproducible, and multi-architecture system management.

## ℹ️ Documentation Structure

**Please note:** Detailed documentation is distributed across this repository. You can find specific `README.md` files in the following locations:

- `hosts/<hostname>/`: Hardware specs and deployment guides for specific machines.
- `services/<service-name>/`: Deep dives into specific service configurations (e.g., Minecraft network).
- `common/`: Settings shared across all hosts.

## Core Technologies

- **Nix Flakes:** For reproducible builds and dependency management.
- **sops-nix:** For encrypting secrets (passwords, API keys) via `age`.
- **nvfetcher:** For managing external binary assets with automatic version tracking.
- **WireGuard:** For secure management and application networks.
- **Cross-Compilation:** Building aarch64 (ARM) images on x86_64 machines.

## Security Overview

- **Management Network (wg0):** Private network for SSH and administrative tasks.
- **Application Network (wg1):** Private network for inter-server communication.
- **Declarative Secrets:** All secrets are managed via SOPS and never stored in the Nix store in plain text.

---

## Getting Started

To learn about a specific host, navigate to its directory:
```bash
cd hosts/kagutsuchi-sama
cat README.md
```