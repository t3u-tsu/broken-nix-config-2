{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.my.autoUpdate;
  targetUser = config.users.users.${cfg.user};
  flakePath = "${targetUser.home}/${cfg.subdir}";

  # nvfetcher ターゲットのディレクトリとファイル名をスペース区切りで抽出
  nvDirs = concatStringsSep " " (map (t: t.dir) (filter (t: t.enable) cfg.nvfetcher));
  nvConfigs = concatStringsSep " " (map (t: t.configFile) (filter (t: t.enable) cfg.nvfetcher));

  # スクリプトの生成
  updateClientScript = pkgs.writeShellScriptBin "nixos-auto-update" (builtins.readFile ./update-client.sh);
  receiverScript = pkgs.writeScriptBin "nixos-update-receiver" ''
    #!${pkgs.python3}/bin/python3
    ${builtins.readFile ./receiver.py}
  '';
in {
  options.my.autoUpdate = {
    enable = mkEnableOption "Automatic system and plugin updates";
    user = mkOption {
      type = types.str;
      default = "t3u";
      description = "The user who owns the nix-config repository";
    };
    subdir = mkOption {
      type = types.str;
      default = "nix-config";
      description = "Subdirectory under home for the repository";
    };
    remoteUrl = mkOption {
      type = types.str;
      default = "github.com/t3u-tsu/nix-config.git";
    };
    gitUserName = mkOption {
      type = types.str;
      default = "t3u-daemon";
    };
    gitUserEmail = mkOption {
      type = types.str;
      default = "t3u+daemon@t3u.uk";
    };
    pushChanges = mkOption {
      type = types.bool;
      default = false;
      description = "Whether this host should update flake.lock and push changes to Git";
    };
    onCalendar = mkOption {
      type = types.str;
      default = "*-*-* 04:00:00";
      description = "Systemd OnCalendar expression for the update timer";
    };
    hubUrl = mkOption {
      type = types.str;
      default = "http://10.0.1.1:8080";
      description = "URL of the update-hub on torii-chan";
    };
    nvfetcher = mkOption {
      type = types.listOf (types.submodule {
        options = {
          enable = mkEnableOption "Enable nvfetcher for this target";
          dir = mkOption {
            type = types.str;
            description = "Directory containing nvfetcher.toml (relative to flake root)";
          };
          configFile = mkOption {
            type = types.str;
            default = "nvfetcher.toml";
            description = "Name of the nvfetcher config file";
          };
        };
      });
      default = [];
      description = "List of nvfetcher targets to update";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.github_token.owner = "root";

    systemd.services.nixos-auto-update = {
      description = "NixOS Auto Update Service";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      
      path = with pkgs; [ nix git openssh coreutils nvfetcher nixos-rebuild gnused curl ];

      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };

      environment = {
        FLAKE_PATH = flakePath;
        TOKEN_PATH = config.sops.secrets.github_token.path;
        HUB_URL = cfg.hubUrl;
        REMOTE_URL = cfg.remoteUrl;
        HOSTNAME = config.networking.hostName;
        USERNAME = cfg.user;
        GROUPNAME = targetUser.group;
        PUSH_CHANGES = if cfg.pushChanges then "true" else "false";
        GIT_USER_NAME = cfg.gitUserName;
        GIT_USER_EMAIL = cfg.gitUserEmail;
        NVFETCHER_DIRS = nvDirs;
        NVFETCHER_CONFIGS = nvConfigs;
      };

      script = "${updateClientScript}/bin/nixos-auto-update";
    };

    systemd.timers.nixos-auto-update = {
      description = "Timer for NixOS Auto Update";
      timerConfig = {
        OnCalendar = cfg.onCalendar;
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };

    # 通知レシーバー (Webhook)
    systemd.services.nixos-update-trigger = {
      description = "NixOS Update Trigger Receiver";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        ExecStart = "${receiverScript}/bin/nixos-update-receiver 8081";
        Restart = "always";
        User = "root";
      };
    };

    networking.firewall.interfaces.wg1.allowedTCPPorts = [ 8081 ];
  };
}