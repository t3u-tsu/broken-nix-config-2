{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./disko-config.nix
    # Include modules
    ../../modules
    ../../modules/services/desktop/plasma.nix
  ];

  # Hardware settings (Extracted from /etc/nixos/hardware-configuration.nix)
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Enable KDE Plasma
  my.services.desktop.plasma.enable = true;

  # Hostname
  networking.hostName = "BrokenPC";

  # Bootloader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Basic networking
  networking.networkmanager.enable = true;

  # User account (Default t3u)
  users.users.t3u = {
    isNormalUser = true;
    description = "t3u";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
    # Use standard shell (Zsh is managed by modules/shell)
    shell = pkgs.zsh;
  };

  # Local network tools (PC tools)
  my.hardware.pc-tools.enable = true;

  # State version
  system.stateVersion = "25.11";
}
