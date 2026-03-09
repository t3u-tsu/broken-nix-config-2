{ ... }: {
  imports = [
    ../../services/desktop/plasma.nix
    ../../services/desktop/fcitx5.nix
    ../../services/desktop/fonts.nix
    ../../home/desktop.nix
  ];

  # Enable core desktop service
  my.services.desktop.plasma.enable = true;
}
