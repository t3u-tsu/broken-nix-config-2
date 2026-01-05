{ pkgs, ... }:

let
  port = 8080;
  hubScript = pkgs.writeScriptBin "update-hub" ''
    #!${pkgs.python3}/bin/python3
    ${builtins.readFile ./hub.py}
  '';
in
{
  networking.firewall.allowedTCPPorts = [ port ];

  systemd.services.update-hub = {
    description = "NixOS Update Status Hub";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${hubScript}/bin/update-hub ${toString port}";
      Restart = "always";
      StateDirectory = "update-hub";
      User = "root";
    };
  };
}
