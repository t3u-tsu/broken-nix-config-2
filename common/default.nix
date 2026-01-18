{ pkgs, ... }:

{
  imports = [
    ./nix.nix
    ../services/update-hub/client.nix
    ./local-network.nix
    ./time.nix
    ./wireguard.nix
  ];

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
