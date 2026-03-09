{ config, pkgs, ... }:

{
  imports = [
    ./alacritty.nix
    ./browsers.nix
    ./communication.nix
    ./creative.nix
    ./dev-tools.nix
    ./utils.nix
  ];

  # Default Browser (XDG)
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "zen.desktop";
      "x-scheme-handler/http" = "zen.desktop";
      "x-scheme-handler/https" = "zen.desktop";
      "x-scheme-handler/about" = "zen.desktop";
      "x-scheme-handler/unknown" = "zen.desktop";
    };
  };

  # System-wide Dark Mode & Appearance
  gtk = {
    enable = true;
    theme = {
      name = "Breeze-Dark";
      package = pkgs.kdePackages.breeze-gtk;
    };
    iconTheme = {
      name = "breeze-dark";
      package = pkgs.kdePackages.breeze-icons;
    };
  };

  # Qt Appearance Integration
  qt = {
    enable = true;
    platformTheme.name = "kde";
    style.name = "breeze";
  };

  # Ensure user environment is Japanese
  home.language.base = "ja_JP.UTF-8";
}