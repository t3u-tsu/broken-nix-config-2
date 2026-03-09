{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./disko-config.nix
    # Include modules
    ../../modules
    ../../modules/services/desktop/plasma.nix
  ];

  # Allow unfree packages (NVIDIA drivers, etc.)
  nixpkgs.config.allowUnfree = true;

  # Hardware settings (Extracted from /etc/nixos/hardware-configuration.nix)
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # GPU Configuration (NVIDIA + AMD Hybrid)
  # Default: Use NVIDIA driver for external monitor output (via PRIME offload)
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # Bus ID: 01:00.0 (NVIDIA) and 07:00.0 (AMD)
      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:7:0:0";
    };
  };

  # Specialisation: Add a "No NVIDIA" boot option for emergency or power saving
  specialisation."No-NVIDIA".configuration = {
    system.nixos.tags = [ "no-nvidia" ];
    # Force AMD driver only
    services.xserver.videoDrivers = lib.mkForce [ "amdgpu" ];
    # Disable NVIDIA settings in this mode
    hardware.nvidia.prime.offload.enable = lib.mkForce false;
    hardware.nvidia.modesetting.enable = lib.mkForce false;
    # Disable the NVIDIA kernel module to prevent it from even loading
    boot.blacklistedKernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  };

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
