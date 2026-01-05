{ pkgs, lib, ... }:

let
  port = 8080;
  
  hubConfig = {
    ip_map = {
      "torii-chan" = "10.0.1.1";
      "kagutsuchi-sama" = "10.0.1.3";
      "shosoin-tan" = "10.0.1.4";
      "sando-kun" = "10.0.1.2";
    };
  };

  configFile = pkgs.writeText "hub-config.json" (builtins.toJSON hubConfig);

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
      ExecStart = "${hubScript}/bin/update-hub --port ${toString port} --config ${configFile} --log-file /var/lib/update-hub/hub.log";
      Restart = "always";
      StateDirectory = "update-hub";
      User = "root";
    };
  };
}
