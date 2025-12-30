{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.my.autoUpdate;
in {
  options.my.autoUpdate = {
    enable = mkEnableOption "Automatic system and plugin updates";
    flakePath = mkOption {
      type = types.str;
      description = "Absolute path to the nix-config repository";
    };
    remoteUrl = mkOption {
      type = types.str;
      default = "github.com/t3u-tsu/nix-config.git";
      description = "Remote URL (without https://) for the repository";
    };
    gitUserName = mkOption {
      type = types.str;
      default = "t3u-daemon";
    };
    gitUserEmail = mkOption {
      type = types.str;
      default = "t3u+daemon@t3u.uk";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.github_token = {
      owner = "root";
    };

    systemd.services.nixos-auto-update = {
      description = "NixOS Auto Update, Flake Update, and Minecraft Plugins Sync";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      path = with pkgs; [
        nix
        git
        openssh
        coreutils
        gnugrep
        gnused
        nvfetcher
        nixos-rebuild
      ];
      script = ''
        export NIX_CONFIG="extra-experimental-features = nix-command flakes"
        GITHUB_TOKEN=$(cat ${config.sops.secrets.github_token.path})

        # 0. リポジトリが存在しない場合はクローン
        if [ ! -d "${cfg.flakePath}/.git" ]; then
          echo "Repository not found at ${cfg.flakePath}. Cloning..."
          mkdir -p "$(dirname "${cfg.flakePath}")"
          git clone "https://x-access-token:$GITHUB_TOKEN@${cfg.remoteUrl}" "${cfg.flakePath}"
        fi

        cd "${cfg.flakePath}"
        
        # 1. Nix Flake の更新
        nix flake update

        # 2. nvfetcher によるプラグイン更新
        nvfetcher -c services/minecraft/plugins/nvfetcher.toml -o services/minecraft/plugins

        # 3. 変更があればコミット
        git config user.name "${cfg.gitUserName}"
        git config user.email "${cfg.gitUserEmail}"
        
        git add .
        if ! git diff --cached --exit-code; then
          git commit -m "chore(auto): update system and plugins $(date +%F)"
          
          # 4. GitHub へ Push
          git push "https://x-access-token:$GITHUB_TOKEN@${cfg.remoteUrl}" main
        fi

        # 5. システムに反映
        nixos-rebuild switch --flake .
      '';
    };

    systemd.timers.nixos-auto-update = {
      description = "Timer for NixOS Auto Update";
      timerConfig = {
        OnCalendar = "*-*-* 04:00:00";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
  };
}