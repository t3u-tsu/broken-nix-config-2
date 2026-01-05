{ ... }:

{
  imports = [
    ./boot.nix
    ./sops.nix
    ./ssh.nix
    ./user.nix
    ./auto-update.nix
  ];
}
