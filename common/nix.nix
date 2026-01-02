{ pkgs, lib, ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "@wheel" "t3u" ];
    
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    auto-optimise-store = true;
  };

  # x86_64 ホストでのみ aarch64 エミュレーションを有効にする
  boot.binfmt.emulatedSystems = lib.optional (pkgs.stdenv.hostPlatform.isx86_64) "aarch64-linux";

  # 1週間に一度のガベージコレクション
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}
