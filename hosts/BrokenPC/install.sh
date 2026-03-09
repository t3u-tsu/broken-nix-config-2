#!/usr/bin/env bash

# BrokenPC Installation Script
# This script is intended to be run from a NixOS Live USB.

set -e

REPO_URL="https://github.com/t3u/nix-config.git"
HOST="BrokenPC"
DISK_ID="nvme-MTFDKBA512TFH-1BC1AABHA_UMDMC01ZRH9LRX"

echo "=== BrokenPC (HP Victus 16) NixOS Installer ==="

# 1. Check disk existence
if [ ! -e "/dev/disk/by-id/$DISK_ID" ]; then
    echo "ERROR: Target disk $DISK_ID not found!"
    echo "Please check if the NVMe drive is correctly recognized."
    exit 1
fi

# 2. Preparation
echo "Cloning configuration repository..."
if [ ! -d "nix-config" ]; then
    git clone "$REPO_URL" nix-config
fi
cd nix-config

# 3. Partitioning with Disko
echo "Partitioning and formatting disk using Disko..."
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode zap_create_mount ./hosts/$HOST/disko-config.nix

# 4. Sops Secret Handling
echo ""
echo "--- Sops Secret Key (age) ---"
echo "To ensure user passwords work on first boot, your age key needs to be at /mnt/var/lib/sops-nix/key.txt"
echo "If you have the key file now, please provide the path to it (or press Enter to skip):"
read -r -p "Path to age key: " KEY_PATH

if [ -n "$KEY_PATH" ] && [ -f "$KEY_PATH" ]; then
    sudo mkdir -p /mnt/var/lib/sops-nix
    sudo cp "$KEY_PATH" /mnt/var/lib/sops-nix/key.txt
    sudo chmod 600 /mnt/var/lib/sops-nix/key.txt
    echo "Key successfully copied to target system."
else
    echo "Skipping key copy. Remember to place it at /var/lib/sops-nix/key.txt on the new system."
fi
echo "------------------------------"
echo ""

# 5. Installation
echo "Installing NixOS..."
sudo NIXPKGS_ALLOW_UNFREE=1 nixos-install --flake ".#$HOST" --no-root-passwd

echo "=== Installation Complete! ==="
echo "You can now reboot into your new NixOS system."
