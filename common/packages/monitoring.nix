{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    btop
    duf
    dust
    fastfetch
    htop
    hwinfo
    hwloc
    lm_sensors
    nvme-cli
    pciutils
    smartmontools
    usbutils
  ];
}
