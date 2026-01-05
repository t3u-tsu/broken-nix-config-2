{ config, pkgs, inputs, ... }:

{
  imports = [
    ./disko-config.nix
    ./services
    ../../common
    ../../common/tower-server
  ];

  # Bootloader configuration (Using GRUB to match shosoin-tan)
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # Unique hostId for future ZFS support
  networking.hostId = "c0ffee01";
  networking.hostName = "kagutsuchi-sama";

  # Enable local network optimizations (NAT loopback bypass for torii-chan)
  # my.localNetwork.enable = true;

  # GTX 980 Ti (Maxwell) configuration
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false; # Maxwell is not supported by the 'open' kernel module
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  system.stateVersion = "25.05";
}