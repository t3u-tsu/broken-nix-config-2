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

      packages.x86_64-linux.sd-image = import ./hosts/torii-chan/sd-image.nix {
        pkgs = pkgs-x86;
        config = self.nixosConfigurations.torii-chan.config;
        uboot = pkgs-x86.pkgsCross.aarch64-multiplatform.ubootOrangePiZero3;
      };
    };
}
