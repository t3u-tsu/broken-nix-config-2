# Host: BrokenPC (Victus by HP 16-e1xxx)

NixOS desktop machine with a hybrid GPU configuration. This host is a "Victus by HP" gaming laptop used for daily work and development, managed via Nix Flakes.

## Hardware Specs
- **CPU**: AMD Ryzen 7 6800H (16 threads)
- **GPU**: 
  - NVIDIA GeForce RTX 3050 Ti Mobile (Discrete - **Faulty Hardware**)
  - AMD Radeon 680M (Integrated)
- **RAM**: 16GB DDR5
- **Storage**: 512GB NVMe SSD (`nvme-MTFDKBA512TFH-1BC1AABHA_UMDMC01ZRH9LRX`)

## 🚀 Installation Guide (Clean Install)

Due to the faulty NVIDIA GPU and hybrid graphics, follow this procedure for a stable installation.

### Phase 1: Disk Preparation and Installation
1. **Boot from NixOS Installer USB.**
2. **Setup Network:** Connect to Wi-Fi/Ethernet.
3. **Run Install Script:** 
   Clone the repository and run the provided script to automate partitioning and installation:
   ```bash
   git clone https://github.com/t3u/nix-config.git
   cd nix-config/hosts/BrokenPC
   chmod +x install.sh
   ./install.sh
   ```

   ※ Manual procedure:
   ```bash
   nix build .#nixosConfigurations.BrokenPC.config.system.build.diskoScript
   sudo ./result --mode zap_create_mount
   sudo NIXPKGS_ALLOW_UNFREE=1 nixos-install --flake .#BrokenPC
   ```

### Phase 2: Transfer Secret Key (Important)
To ensure user passwords work on first boot, your age key needs to be at /mnt/var/lib/sops-nix/key.txt.
```bash
sudo mkdir -p /mnt/var/lib/sops-nix
# Copy your age key to /mnt/var/lib/sops-nix/key.txt
```

## 🔐 Configuration Features

### Hybrid Graphics Management
The discrete NVIDIA GPU on this machine has hardware faults that cause system crashes under heavy load or during power state transitions.
- **Default (PRIME Offload):** Rendering is handled by the stable AMD iGPU. NVIDIA is kept in a powered-on idle state to serve as a display pipe for the external monitor (ASUS VP248) via HDMI.
- **Conservative Power Settings:** Fine-grained power management is disabled to avoid voltage-change-induced crashes.
- **Nouveau Blacklist:** The open-source `nouveau` driver is strictly blacklisted as it causes instability during initial load.

### Specialisation: No-NVIDIA Mode
A boot entry named `No-NVIDIA` is available in the systemd-boot menu. This mode:
- Completely blacklists all NVIDIA kernel modules (`nvidia`, `nvidia_drm`, etc.).
- Forces the system to use `amdgpu` only.
- Recommended for maximum stability when an external monitor is not required.

### Services & Integration
- **DE:** KDE Plasma 6 (Wayland) with Japanese localization.
- **Update Hub:** Configured as a client to receive updates from the producer (`shosoin-tan`).
- **Hardware Tools:** Enabled `pc-tools` for local hardware management.

## ⚠️ Notes
- **External Monitor:** HDMI is physically wired to the NVIDIA GPU. You MUST use the default boot mode (not No-NVIDIA) to use the external monitor.
- **DO NOT RUN `nvidia-offload`:** Running applications on the NVIDIA GPU will cause a hardware crash.
