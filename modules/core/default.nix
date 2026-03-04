{ ... }: {
  imports = [
    ./nix.nix
    ./time.nix
    ./networking.nix
    ./wireguard.nix
    # security.nix is handled in core or packages? 
    # Let's keep common system core modules here.
  ];
}
