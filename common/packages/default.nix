{ ... }: {
  imports = [
    ./core.nix
    ./monitoring.nix
    ./network-tools.nix
    ./data.nix
    ./nix-tools.nix
    ./security.nix
  ];
}
