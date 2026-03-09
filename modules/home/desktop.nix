{ config, pkgs, ... }:

{
  home-manager.users.${config.my.user.name} = {
    # Desktop-specific GUI packages for the user
    home.packages = with pkgs; [
      discord
      obsidian
      vscode
      vlc
      gimp
    ];

    # VSCode settings (Example of declarative config)
    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        ms-ceintl.vscode-language-pack-ja
      ];
    };

    # Basic Firefox config
    programs.firefox.enable = true;
  };
}
