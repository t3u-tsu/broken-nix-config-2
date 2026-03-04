{ ... }:

{
  imports = [
    ./wireguard.nix
    ../../../modules/services/backup/receiver.nix
  ];
}
