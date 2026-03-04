{ config, lib, ... }:

let
  # Convert hostname hyphens to underscores for SOPS keys
  hostKey = builtins.replaceStrings [ "-" ] [ "_" ] config.networking.hostName;
in
{
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.sshKeyPaths = [ ];
  sops.age.generateKey = false;

  environment.variables = {
    SOPS_AGE_KEY_FILE = "/var/lib/sops-nix/key.txt";
  };

  # Dynamic password hashes based on hostname
  sops.secrets."${hostKey}_t3u_password_hash".neededForUsers = true;
  sops.secrets."${hostKey}_root_password_hash".neededForUsers = true;
}
