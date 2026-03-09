{ ... }: {
  imports = [
    ./auto-update.nix
    ./boot.nix
    ./security.nix
    ./ssh.nix
    ./user.nix
  ];
}
