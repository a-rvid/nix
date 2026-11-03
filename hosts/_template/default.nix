{ config, inputs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ../../modules/nixos
  ];

  networking.hostName = "template";
  system.stateVersion = config.my.stateVersion;

  my = {
    profile.userName = "user";
    profile.fullName = "Template User";

    desktop.enable = false;
    features = {
      gaming.enable = false;
      development.enable = true;
      spotify.enable = false;
    };

    browser.librewolf.enable = false;
    persistence.enable = false;
    hardware.nvidiaLaptop.enable = false;
  };

  home-manager.users.${config.my.profile.userName} = import ../../modules/home-manager.nix;
}
