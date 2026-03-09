{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./disko-config.nix
    ./services
    ../../modules
    ../../modules/services/desktop/plasma.nix
  ];

  # Sops (Secret Management) configuration
  # Matching torii-chan and tower-server pattern
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Hardware settings (AMD CPU + HP Victus specifics)
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" "sdhci_pci" "amdgpu" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # CRITICAL: Prevent Nouveau and force amdgpu
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelParams = [ 
    "nouveau.modeset=0" 
    "amdgpu.modeset=1"
    "nvidia-drm.modeset=1"
    "modprobe.blacklist=nouveau"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # GPU Configuration (Super-Conservative NVIDIA + AMD Hybrid)
  services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false; 
    powerManagement.finegrained = false;

    open = false; 
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # Bus IDs for HP Victus 16
      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:7:0:0";
    };
  };

  # Specialisation: No-NVIDIA Mode (Safety/Power Save)
  specialisation."No-NVIDIA".configuration = {
    system.nixos.tags = [ "no-nvidia" ];
    services.xserver.videoDrivers = lib.mkForce [ "amdgpu" ];
    hardware.nvidia.prime.offload.enable = lib.mkForce false;
    hardware.nvidia.modesetting.enable = lib.mkForce false;
    boot.blacklistedKernelModules = [ "nouveau" "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
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

  # Update Hub Client integration
  my.updateHub.client.enable = true;

  # State version
  system.stateVersion = "25.11";
}
