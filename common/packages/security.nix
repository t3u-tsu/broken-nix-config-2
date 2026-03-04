{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    age
    gnupg
    sops
  ];
}
