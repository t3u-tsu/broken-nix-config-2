{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, disko, sops-nix, ... }@inputs:
    let
      lib = import ./lib {
        inherit nixpkgs inputs home-manager disko sops-nix;
      };
      pkgs-x86 = import nixpkgs { system = "x86_64-linux"; };
    in
    {
      nixosConfigurations = {
        "torii-chan" = lib.mkSystem {
          name = "torii-chan";
          system = "x86_64-linux";
          targetSystem = "aarch64-linux";
        };
      };

      packages.x86_64-linux.sd-image = 
        let
          # クロスコンパイルされたシステムのconfigを取得
          config = self.nixosConfigurations.torii-chan.config;
          # クロスコンパイル環境では、pkgsはターゲット向け(aarch64)になっているはず
          # しかし、ビルドを実行するツール(dd, cpなど)はホスト向け(x86)が必要
          # ubootはターゲット向けが必要
          
          uboot = pkgs-x86.pkgsCross.aarch64-multiplatform.ubootOrangePiZero3;
          diskoImage = config.system.build.diskoImages;
        in
        pkgs-x86.runCommand "torii-chan-sd-image" {
          nativeBuildInputs = [ pkgs-x86.coreutils ];
        } ''
          mkdir -p $out
          echo "Copying disko image..."
          cp ${diskoImage}/mmc.raw $out/torii-chan.img
          chmod u+w $out/torii-chan.img
          
          echo "Writing U-Boot..."
          dd if=${uboot}/u-boot-sunxi-with-spl.bin of=$out/torii-chan.img bs=1024 seek=8 conv=notrunc
          
          echo "Done. Image is at $out/torii-chan.img"
        '';
    };
}
