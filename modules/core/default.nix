{ ... }: {
  imports = [
    ./nix.nix
    ./time.nix
    ./networking.nix
    ./wireguard.nix
    ../services/update-hub/client.nix
  ];
}
