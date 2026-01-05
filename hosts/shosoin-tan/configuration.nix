{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./disko-config.nix
    ./services
    ./production-security.nix
    ../../services/minecraft
    ../../services/backup
    ../../services/discord-bridge
    ../../common
    ../../common/tower-server
  ];

  # GT 210 / GT 710 configuration

  sops.secrets.minecraft_forwarding_secret = {
    owner = "minecraft";
    group = "minecraft";
    mode = "0400";
  };

  sops.secrets.nitac23s_rcon_password = {
    owner = "minecraft";
    group = "minecraft";
    mode = "0400";
  };

  sops.secrets.discord_admin_guild_id = {
    owner = "minecraft";
    group = "minecraft";
    mode = "0400";
  };

  # Bootloader configuration
  boot.loader.grub = {
    enable = true;
    efiSupport = false;
  };

  # ZFS requires a unique hostId
  networking.hostId = "8425e349";
  networking.hostName = "shosoin-tan";
  networking.useDHCP = true;

  # Enable local network optimizations (NAT loopback bypass for torii-chan)
  # my.localNetwork.enable = true;

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  boot.zfs.extraPools = [ "tank-1tb" ];

  # Core i7 870 is x86_64
  # Quadro K2200 (Maxwell) uses standard NVIDIA drivers
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false; # Maxwell is not supported by the 'open' kernel module
    nvidiaSettings = true;
    # Quadro K2200 is well-supported by the 'stable' or 'production' branch
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Shosoin-tan is the Update Producer
  my.autoUpdate.pushChanges = true;

  system.stateVersion = "25.05";
}