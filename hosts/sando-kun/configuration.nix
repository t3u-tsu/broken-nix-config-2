{ config, pkgs, inputs, ... }:

let
  username = "t3u";
in
{
  imports = [
    ./disko-config.nix
    ./services
    ./production-security.nix
    ../../common
  ];

  # GeForce 8400 GS (Tesla) is too old for modern NVIDIA drivers.
  # We stick with nouveau or basic kernel drivers for stability.
  boot.kernelPackages = pkgs.linuxPackages;

  nixpkgs.config.allowUnfree = true;

  # SOPS configuration
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.sshKeyPaths = [ ];
  sops.age.generateKey = false;

  environment.variables = {
    SOPS_AGE_KEY_FILE = "/var/lib/sops-nix/key.txt";
  };

  sops.secrets.sando_kun_t3u_password_hash = {
    neededForUsers = true;
  };
  sops.secrets.sando_kun_root_password_hash = {
    neededForUsers = true;
  };

  # Bootloader configuration
  boot.loader.grub = {
    enable = true;
    efiSupport = false; # i7-860 is Legacy BIOS
    # device will be set by disko
  };

  # Networking
  networking.hostId = "5a4d0001";
  networking.hostName = "sando-kun";
  networking.useDHCP = true;

  # Enable local network optimizations (Disabled as default since machines moved LANs)
  # my.localNetwork.enable = true;

  # ZFS Support
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  boot.zfs.extraPools = [ "tank-80gb" ];

  # SSH and basic settings
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  users.mutableUsers = false;

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "render" ];
    hashedPasswordFile = config.sops.secrets.sando_kun_t3u_password_hash.path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB3QNRSxPauISsWs7nob0tXfxjTsMpBEIYIjasRD9bpT t3u@BrokenPC"
    ];
  };

  users.users.root = {
    hashedPasswordFile = config.sops.secrets.sando_kun_root_password_hash.path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB3QNRSxPauISsWs7nob0tXfxjTsMpBEIYIjasRD9bpT t3u@BrokenPC"
    ];
  };

  my.autoUpdate = {
    enable = true;
    user = username;
    pushChanges = false;
  };

  system.stateVersion = "25.05";
}