{ config, lib, pkgs, inputs, ... }:

with lib;
let
  cfg = config.my.home.desktop.niri;
in {
  options.my.home.desktop.niri = {
    enable = mkEnableOption "Niri Home Manager configuration";
  };

  imports = [
    ./noctalia.nix
    ./addons.nix
    ./power.nix
  ];

  config = mkIf cfg.enable {
    programs.niri.settings = {
      input = {
        keyboard.repeat-delay = 250;
        keyboard.repeat-rate = 30;
        touchpad = {
          tap = true;
          dwt = true;
        };
      };

      layout = {
        gaps = 8;
        center-focused-column = "never";
        default-column-width = { proportion = 0.5; };
      };

      spawn-at-startup = [
        # awww is the new swww from Codeberg
        { command = [ "${inputs.awww.packages.${pkgs.system}.default}/bin/awww-daemon" ]; }
        { command = [ "${pkgs.swaynotificationcenter}/bin/swaync" ]; }
        { command = [ "${pkgs.networkmanagerapplet}/bin/nm-applet" "--indicator" ]; }
        { command = [ "${pkgs.blueman}/bin/blueman-applet" ]; }
      ];

      binds = {
        "Mod+Return".action.spawn = [ "alacritty" ];
        "Mod+D".action.spawn = [ "noctalia-shell" "ipc" "call" "launcher" "toggle" ];
        "Mod+Q".action.close-window = { };
        "Mod+F".action.maximize-column = { };
        "Mod+Space".action.toggle-window-floating = { };
        
        "Mod+Left".action.focus-column-left = { };
        "Mod+Right".action.focus-column-right = { };
        "Mod+Up".action.focus-window-up = { };
        "Mod+Down".action.focus-window-down = { };

        "Mod+Shift+Left".action.move-column-left = { };
        "Mod+Shift+Right".action.move-column-right = { };
        "Mod+Shift+Up".action.move-window-up = { };
        "Mod+Shift+Down".action.move-window-down = { };

        "Mod+Page_Up".action.focus-workspace-up = { };
        "Mod+Page_Down".action.focus-workspace-down = { };
        "Mod+Shift+Page_Up".action.move-column-to-workspace-up = { };
        "Mod+Shift+Page_Down".action.move-column-to-workspace-down = { };

        "Print".action.screenshot = { };
        "Mod+Shift+E".action.spawn = [ "noctalia-shell" "ipc" "call" "sessionMenu" "toggle" ];
        
        # Audio & Brightness via swayosd
        "XF86AudioRaiseVolume".action.spawn = [ "swayosd-client" "--output-volume" "raise" ];
        "XF86AudioLowerVolume".action.spawn = [ "swayosd-client" "--output-volume" "lower" ];
        "XF86AudioMute".action.spawn = [ "swayosd-client" "--output-volume" "mute" ];
        "XF86MonBrightnessUp".action.spawn = [ "swayosd-client" "--brightness" "raise" ];
        "XF86MonBrightnessDown".action.spawn = [ "swayosd-client" "--brightness" "lower" ];
      };

      window-rules = [
        {
          matches = [{ app-id = "org.keepassxc.KeePassXC"; }];
          open-floating = true;
        }
      ];
    };

    home.packages = with pkgs; [
      inputs.awww.packages.${pkgs.system}.default
      xwayland-satellite
      brightnessctl
      playerctl
      wl-clipboard
      cliphist
      grim
      slurp
    ];
  };
}
