# My NixOS Fleet

This repository manages multiple NixOS configurations using Flakes. It is designed for secure, reproducible, and multi-architecture system management.

## ℹ️ Documentation Structure

Detailed documentation is distributed across the repository. Please refer to the specific `README.md` files in these locations:

- `hosts/<hostname>/`: Hardware specs and deployment guides for specific machines.
- `services/<service-name>/`: Deep dives into specific service configurations (e.g., Minecraft).
- `common/`: Settings shared across all hosts.

## 📂 Directory Structure

```text
.
├── flake.nix           # Entry point for the configuration
├── hosts/              # Host-specific configurations
├── common/             # Shared configurations across all hosts
├── services/           # Common service configurations
│   ├── minecraft/      # Minecraft Network (Velocity + Paper)
│   ├── backup/         # Automated Restic Backups
│   └── update-hub/     # Coordinated Update System (Hub & Client)
├── lib/                # Common library functions
└── secrets/            # Encrypted secrets (SOPS)
```

## 🖥️ The Fleet (Hosts)

| Host | Mgmt IP (WG0) | App IP (WG1) | Role | Storage |
| :--- | :--- | :--- | :--- | :--- |
| `torii-chan` | `10.0.0.1` | `10.0.1.1` | Gateway / Update Hub / DDNS | SD + HDD |
| `sando-kun` | `10.0.0.2` | `10.0.1.2` | Sando Server | HDD + ZFS Mirror |
| `kagutsuchi-sama` | `10.0.0.3` | `10.0.1.3` | Compute Server / Backup Receiver | SSD + 3TB HDD |
| `shosoin-tan` | `10.0.0.4` | `10.0.1.4` | Minecraft / Discord Bridge / Producer | SSD + ZFS Mirror |

## 🛠️ Core Technologies

- **Nix Flakes:** For reproducible builds and dependency management.
- **sops-nix:** For encrypting secrets (passwords, API keys) via `age`. Enables secure dynamic injection of RCON passwords.
- **nvfetcher:** For managing external binary assets with automatic version tracking.
- **WireGuard:** For secure management (wg0) and application (wg1) networks.
- **Coordinated Auto Updates:** Daily automated updates at 4 AM with Webhook push notification sync.
- **Minecraft Discord Bridge:** Custom multi-tenant Go-based management bot for whitelists.
- **Automated Backup (Restic):** Automated backups every 2 hours with Minecraft data consistency hooks.
- **Build Optimization:** aarch64 emulation building to fully utilize NixOS official binary caches.

---

## 🚀 Deployment and Updates

Normally, changes are automatically reflected across all hosts via **Update Hub** after pushing to GitHub.

### Immediate Reflect (Global)
After pushing to GitHub, you can trigger updates on all hosts by notifying the Hub:
```bash
curl -X POST -H "Content-Type: application/json" -d "{\"commit\": \"$(git rev-parse HEAD)\", \"host\": \"$(hostname)\"}" http://10.0.0.1:8080/producer/done
```

### Manual Deployment (Emergency or New Setup)
```bash
# Example: Deploy to shosoin-tan
nixos-rebuild switch --flake .#shosoin-tan --target-host t3u@10.0.0.4 --sudo
```

For more details, see [services/update-hub](services/update-hub/README.md).

---

## Getting Started

To learn about a specific host or service, navigate to its directory:
```bash
cd hosts/kagutsuchi-sama
cat README.md
```