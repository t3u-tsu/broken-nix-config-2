{ config, pkgs, lib, ... }:

with lib;
let
  pkgCfg = config.my.packages.monitoring;
  hwCfg = config.my.hardware.pc-tools;
in {
  config = mkIf pkgCfg.enable {
    environment.systemPackages = with pkgs; [
      btop
      duf
      dust
      fastfetch
      htop
      hwinfo
      hwloc
      lm_sensors
      procs
      bottom
    ] ++ lib.optionals hwCfg.enable [
      nvme-cli
      pciutils
      smartmontools
      usbutils
    ];
  };
}
