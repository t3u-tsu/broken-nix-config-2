# BrokenPC

NixOS desktop machine with a hybrid GPU configuration.

## Hardware
- **CPU**: AMD Ryzen (with Radeon Graphics)
- **GPU**: NVIDIA GeForce RTX 3050 Laptop (Faulty - only used for display output, no heavy rendering)
- **Disk**: NVMe SSD (512GB)

## Configuration Features
- **Desktop**: KDE Plasma 6 (Wayland)
- **Hybrid Graphics**: 
  - Uses NVIDIA PRIME Offload by default.
  - Rendering is handled by AMD iGPU to avoid crashes on the faulty NVIDIA dGPU.
  - NVIDIA is used as a display pipe for external monitors.
- **Specialisation**: 
  - `No-NVIDIA`: A boot option to completely disable NVIDIA drivers for emergency or safe usage.

## Deployment
```bash
sudo nixos-rebuild switch --flake .#BrokenPC
```
