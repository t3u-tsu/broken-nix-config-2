{ osConfig, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "torii-chan" = {
        hostname = "10.0.0.1";
        user = osConfig.my.user.name;
      };
      "sando-kun" = {
        hostname = "10.0.0.2";
        user = osConfig.my.user.name;
      };
      "kagutsuchi-sama" = {
        hostname = "10.0.0.3";
        user = osConfig.my.user.name;
      };
      "shosoin-tan" = {
        hostname = "10.0.0.4";
        user = osConfig.my.user.name;
      };
      "10.0.0.*" = {
        identityFile = "~/.ssh/id_ed25519";
        extraOptions = {
          ServerAliveInterval = "60";
        };
      };
    };
  };
}
