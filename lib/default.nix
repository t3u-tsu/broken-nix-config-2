{ nixpkgs, inputs, home-manager, disko, sops-nix }:

{
  mkSystem = { name, system, targetSystem ? null, disks ? [], extraModules ? [] }:
    nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = { inherit inputs; };

      modules = [
        disko.nixosModules.disko
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
        (if targetSystem != null then {
          nixpkgs.crossSystem = {
            system = targetSystem;
          };
        } else {})

        ../hosts/${name}/configuration.nix
      ] ++ extraModules;
    };
}