{ config, ... }: {
  imports = [
    ../../services/desktop
  ];

  # Integrate Home-manager desktop settings for the primary user
  home-manager.users.${config.my.user.name} = {
    imports = [
      ../../home/desktop
    ];
  };

  # Enable core desktop service
  my.services.desktop.plasma.enable = true;
}
