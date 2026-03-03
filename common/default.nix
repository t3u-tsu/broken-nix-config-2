{ pkgs, lib, ... }:

{
  imports = [
    ./nix.nix
    ./network.nix
    ./packages.nix
    ./time.nix
    ./wireguard.nix
    ../services/update-hub/client.nix
  ];

  # Emergency Fix: Pin kernel version to 6.18 for all hosts to avoid unbootable issue with kernel 6.19.4 regression
  # Use mkForce to override host-specific or tower-server-specific defaults
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_18;
}