{ nixpkgs, inputs, home-manager, disko, sops-nix, nix-minecraft, overlays }:

{
  mkSystem = { name, system, username ? "t3u", targetSystem ? null, disks ? [], extraModules ? [] }:
    nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = { inherit inputs; };

      modules = [
        { my.user.name = username; }
        disko.nixosModules.disko
        sops-nix.nixosModules.sops
        nix-minecraft.nixosModules.minecraft-servers
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          nixpkgs.overlays = overlays;
        }
        (if targetSystem != null then {
          nixpkgs.crossSystem = {
            system = targetSystem;
          };
        } else {})

        ../hosts/${name}/configuration.nix
      ] ++ extraModules;
    };

  # Auto-update helpers
  autoUpdate = {
    mkNvfetcherTask = dir: {
      enable = true;
      inherit dir;
    };
  };
}