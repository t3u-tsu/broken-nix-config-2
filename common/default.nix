{ pkgs, lib, ... }:

{
  imports = [
    ./nix.nix
    ../services/update-hub/client.nix
    ./local-network.nix
    ./time.nix
    ./wireguard.nix
  ];

  # Emergency Fix: Pin kernel version to 6.18 for all hosts to avoid unbootable issue with kernel 6.19.4 regression
  # Use mkForce to override host-specific or tower-server-specific defaults
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_18;

  # Prioritize IPv4 over IPv6 in glibc (RFC 3484/6724)
  environment.etc."gai.conf".text = ''
    precedence  ::ffff:0:0/96  100
  '';

  environment.systemPackages = with pkgs; [
    vim
    git
    tmux
    htop
    btop
    rsync
    pciutils
    usbutils
    wget
    curl
    dnsutils
    jq
    smartmontools
    nvme-cli
    lm_sensors
    fastfetch
    nix-index
    nix-tree
    nix-du
    nixfmt-rfc-style
  ];
}
