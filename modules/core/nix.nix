{ pkgs, lib, ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "@wheel" "t3u" ];
    
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    auto-optimise-store = true;
  };

  # Enable aarch64 emulation on x86_64 hosts
  boot.binfmt.emulatedSystems = lib.optional (pkgs.stdenv.hostPlatform.isx86_64) "aarch64-linux";

  # GC every week
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Emergency Fix: Pin kernel version to 6.18 for all hosts to avoid unbootable issue with kernel 6.19.4 regression
  # Use mkForce to override host-specific or tower-server-specific defaults
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_18;
}
