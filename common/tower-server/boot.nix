{ pkgs, ... }:

{
  # Tower servers generally use the LTS kernel for stability
  boot.kernelPackages = pkgs.linuxPackages;

  nixpkgs.config.allowUnfree = true;
}
