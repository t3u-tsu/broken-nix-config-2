{ pkgs, ... }:

{
  imports = [
    ./nix.nix
    ../services/update-hub/client.nix
    ./local-network.nix
    ./time.nix
    ./wireguard.nix
  ];

  # Pin kernel version to 6.18 to avoid unbootable issue with kernel 6.19.4 regression
  boot.kernelPackages = pkgs.linuxPackages_6_18;

  # Prioritize IPv4 over IPv6
  networking.gaiConfig = ''
    precedence  ::ffff:0:0/96  100
  '';

  environment.systemPackages = with pkgs; [
    vim
    git
    tmux
    htop
    rsync
    pciutils
    usbutils
    wget
    curl
    dnsutils
    jq
  ];
}
