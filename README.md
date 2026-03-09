# My NixOS Fleet

This repository manages multiple NixOS configurations using Flakes and a **Modular Architecture**.

## 📂 Directory Structure

The repository is divided into "Mechanisms (Modules)" and "Entities (Hosts)".

```text
.
├── flake.nix           # Entry point for the configuration
├── hosts/              # Host-specific configurations
└── modules/            # Reusable modules
    ├── core/           # Base settings (Nix, Network, User, Sops)
    ├── packages/       # System package groups (base, monitoring, etc.)
    ├── home/           # User environment via Home-manager (Shell, Desktop, SSH)
    ├── services/       # Various services (Minecraft, Update Hub, Desktop)
    └── profiles/       # Role-based profiles (Desktop, Tower Server)
```

## 🚀 Deployment and Updates

Normally, changes are automatically reflected across all hosts via **Update Hub** after pushing to GitHub.

### Immediate Reflect (Global)
After pushing to GitHub, you can trigger updates on all hosts by notifying the Hub:
```bash
curl -X POST -H "Content-Type: application/json" -d "{\"commit\": \"$(git rev-parse HEAD)\", \"host\": \"$(hostname)\"}" http://10.0.0.1:8080/producer/done
```

## 🛠️ Key Features

- **Modular Architecture**: Clear separation between system (NixOS) and user (Home-manager) layers.
- **Modern CLI Tools**: Starship, Atuin, Zellij, Yazi, fzf, ripgrep standardized across all hosts.
- **Desktop Environment**: Powered by Zen Browser (declarative), Vesktop, Neovim, and Alacritty.
- **Smart Hardware Tools**: Opt-in to physical server tools via `my.hardware.pc-tools.enable = true`.
- **sops-nix**: Secret encryption via `age`.
- **Automated Backup**: Restic backups managed on shosoin-tan.

For more details, see [GEMINI.md](GEMINI.md) or specific `README.md` files in subdirectories.