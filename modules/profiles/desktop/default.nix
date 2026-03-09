{ config, ... }: {
  imports = [
    ../../services/desktop
  ];

  # Integrate Home-manager desktop settings for the primary user
  home-manager.users.${config.my.user.name} = {
    imports = [
      ../../home/desktop
    ];

    # Enable desktop categories by default in this profile
    my.home.desktop = {
      browsers.enable = true;
      communication.enable = true;
      dev-tools.enable = true;
      utils.enable = true;
      creative.enable = true;
      terminal.alacritty.enable = true;
      theme.enable = true;
      xdg.enable = true;
      locales.enable = true;
    };
  };

  # Enable core desktop service
  my.services.desktop.plasma.enable = true;
}