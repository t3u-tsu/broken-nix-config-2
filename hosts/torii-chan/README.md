# Host: torii-chan (Orange Pi Zero3)

This directory contains the NixOS configuration for `torii-chan`, an Orange Pi Zero3 node used as a WireGuard server and DDNS client.

## Hardware Specs
- **Model:** Orange Pi Zero3 (Allwinner H618)
- **Architecture:** aarch64-linux

## Configurations in Flake
- `torii-chan-sd`: Initial SD card image build.
- `torii-chan-sd-live`: Update system while running on SD card.
- `torii-chan`: Production configuration with root on HDD.

---

## 🚀 Setup Guide

### Phase 1: Build & Flash SD Image
1. **Build the SD Image:**
   ```bash
   nix build .#nixosConfigurations.torii-chan-sd.config.system.build.sdImage
   ```
2. **Flash to SD Card:**
   ```bash
   sudo dd if=result/sd-image/nixos-image-sd-card-*.img of=/dev/sdX bs=4M status=progress conv=fsync
   ```

### Phase 2: Initial Provisioning
1. **Insert Key:** Place your age secret key at `/var/lib/sops-nix/key.txt`.
2. **First Deploy:**
   ```bash
   nix run nixpkgs#nixos-rebuild -- switch --flake .#torii-chan-sd-live --target-host root@192.168.0.128
   ```

### Phase 3: Migrate to HDD (Completed ✅)
1. **Prepare HDD:** Format with label `NIXOS_HDD`.
2. **Copy Data:** Rsync `/` to the HDD partition.
3. **Switch Config:**
   ```bash
   nix run nixpkgs#nixos-rebuild -- switch --flake .#torii-chan --target-host t3u@10.0.0.1 --sudo
   ```   *System now boots from HDD with /boot on SD card.*

## 🔐 Services and Secrets
- **Update Hub:** Coordinated Update Hub managing the fleet update status. Provides status at 10.0.1.1:8080.
- **WireGuard:** VPN Server (10.0.0.1).
- **DDNS:** Cloudflare DDNS (favonia). Requires API Token. Manages `torii-chan.t3u.uk` and Minecraft domains `mc.t3u.uk`, `*.mc.t3u.uk`.
- **Secrets:** Managed via `sops-nix`. Edit with `sops secrets/secrets.yaml`.

## 🛠️ Operation & Troubleshooting

### Unstable SSH Connection or Timeout
Due to the resource constraints of the Orange Pi, key exchange may timeout. Use the `curve25519-sha256` algorithm explicitly or ensure it's enforced in the configuration.

```bash
# Example for manual connection
ssh -o KexAlgorithms=curve25519-sha256 t3u@10.0.0.1
```

### Network (WireGuard) Stability
When using unstable parent connections like Rakuten Mobile (MTU 1340), packet fragmentation can cause hangs. The MTU for `wg0` and `wg1` is set to `1300` for better stability.

### Out-of-Memory (OOM) Issues
Builds may fail with `Result: oom-kill` due to low RAM.
A permanent 4GB swap file at `/var/lib/swapfile` is configured, with `vm.swappiness = 10` for optimization.

### Auto-Update (Update Hub) Sync Failure
If the commit notified by the Hub is not found locally, sync the repository manually:
```bash
cd ~/nix-config
git fetch --all
git reset --hard origin/main
```
After syncing, trigger the update manually via the webhook port:
```bash
curl -X POST http://127.0.0.1:8081/trigger-update
```
