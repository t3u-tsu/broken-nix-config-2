{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./disko-config.nix
    ./services
    ../../modules
    ../../modules/services/desktop/plasma.nix
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Hardware settings
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # GPU Configuration (NVIDIA + AMD Hybrid)
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
      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:7:0:0";
    };
  };

  # Specialisation: No-NVIDIA Mode
  specialisation."No-NVIDIA".configuration = {
    system.nixos.tags = [ "no-nvidia" ];
    services.xserver.videoDrivers = lib.mkForce [ "amdgpu" ];
    hardware.nvidia.prime.offload.enable = lib.mkForce false;
    hardware.nvidia.modesetting.enable = lib.mkForce false;
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

  # User account
  users.users.t3u = {
    isNormalUser = true;
    description = "t3u";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
    shell = pkgs.zsh;
  };

  # Local network tools
  my.hardware.pc-tools.enable = true;

  # State version
  system.stateVersion = "25.11";
}
