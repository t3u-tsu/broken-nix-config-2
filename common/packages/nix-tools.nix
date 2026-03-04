{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    nh
    nix-du
    nix-index
    nix-output-monitor
    nix-tree
    nixfmt-rfc-style
  ];
}
