{ ... }: {
  imports = [
    ./nix.nix
    ./time.nix
    ./networking.nix
    ./wireguard.nix
    ./sops.nix
    ../services/update-hub
  ];
}
