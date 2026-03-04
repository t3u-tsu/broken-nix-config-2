{ ... }:

{
  imports = [
    ./ddns.nix
    ./wireguard.nix
    ../../../modules/services/update-hub
  ];
}
