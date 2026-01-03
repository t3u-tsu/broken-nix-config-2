{ ... }:

{
  imports = [
    ./ddns.nix
    ./wireguard.nix
    ../../../services/update-hub
  ];
}
