# Minecraft Network Configuration

This directory manages the Minecraft network consisting of a Velocity proxy and Paper backend servers.

## Overview

- **Proxy (Velocity)**: `proxy.nix`
  - Port: `25565`
  - Handles authentication and server forwarding.
  - Uses `modern` forwarding mode.
- **Backend (Lobby)**: `servers/lobby.nix`
  - Port: `25566`
  - Waiting lobby.
  - Version: Latest (PaperMC)
  - Plugins: ViaVersion, ViaBackwards

## Security and Secrets

### Player Information Forwarding (Forwarding Secret)
A shared secret is used to secure communication between Velocity and Lobby. To prevent exposing the secret in the Nix Store, we use:

1. **sops-nix**: Manages the secret encrypted in `secrets.yaml`.
2. **Dynamic Injection**: The `preStart` script of the `lobby` server injects the decrypted secret into `paper-global.yml` using `sed` just before the server starts.

## Operations

### Full Reset of World and Player Data
To initialize data after changing terrain generation settings, follow these steps:

1. **Create Reset Flag**:
   ```bash
   ssh -t <target-host> "sudo touch /srv/minecraft/lobby/.reset_world && sudo chown minecraft:minecraft /srv/minecraft/lobby/.reset_world"
   ```
2. **Deploy or Restart Service**:
   Run `nixos-rebuild switch`. The startup script will detect the flag, delete `world*` directories and `usercache.json`, and then start fresh.

### Accessing the Console
```bash
ssh -t <target-host> "sudo tmux -S /run/minecraft/lobby.sock attach"
```
To detach, press `Ctrl+b` followed by `d`.

## Lobby Server Specifications
- **Terrain**: Superflat (Ground level at Y=64 to prevent slimes)
- **Mobs**: Natural spawning and initial placement are completely disabled (Peaceful + Spawn Limits 0).
- **Mode**: Forced Adventure mode.
- **Structures**: Disabled.
