# My NixOS Fleet

This repository manages multiple NixOS configurations using Flakes and a **Modular Architecture**.

## 📂 Directory Structure

The repository is divided into "Mechanisms (Modules)" and "Entities (Hosts)".

```text
.
├── flake.nix           # Entry point for the configuration
├── hosts/              # Host-specific configurations
└── modules/            # Reusable modules
    ├── core/           # Base settings (Nix, Network, WireGuard)
    ├── packages/       # Functional package groups (my.packages.*)
    ├── shell/          # Shell integration (Zsh & Home-manager)
    ├── services/       # Server services (Minecraft, Backup, etc.)
    └── profiles/       # Role-based presets (Tower Server, etc.)
```

## 🚀 Deployment and Updates

Normally, changes are automatically reflected across all hosts via **Update Hub** after pushing to GitHub.

### Immediate Reflect (Global)
After pushing to GitHub, you can trigger updates on all hosts by notifying the Hub:
```bash
curl -X POST -H "Content-Type: application/json" -d "{\"commit\": \"$(git rev-parse HEAD)\", \"host\": \"$(hostname)\"}" http://10.0.0.1:8080/producer/done
```

## 🛠️ Key Features

- **Zsh & Home-manager**: Zsh is the default shell on all hosts, deeply integrated with completion and aliases.
- **Modular Packages**: Control package groups via options like `my.packages.monitoring.enable = false`.
- **Smart Hardware Tools**: Opt-in to physical server tools via `my.hardware.pc-tools.enable = true`.
- **sops-nix**: Secret encryption via `age`.
- **Automated Backup**: Restic backups every 2 hours.

For more details, see [GEMINI.md](GEMINI.md) or specific `README.md` files in subdirectories.