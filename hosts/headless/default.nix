{ config, inputs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ../../modules/nixos
  ];

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "mode=755" "size=2G" ];
  };

  networking.hostName = "headless";
  system.stateVersion = config.my.stateVersion;

  my = {
    profile.userName = "user";
    profile.fullName = "Headless Example";

    locale = {
      uiLocale = "en_US.UTF-8";
      formatsLocale = "sv_SE.UTF-8";
      timeZone = "Europe/Stockholm";
      keymap = {
        xkbLayout = "se";
        consoleKeyMap = "sv-latin1";
      };
    };

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

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users.${config.my.profile.userName} = import ../../modules/home-manager.nix;
    extraSpecialArgs = { inherit inputs; };
  };
}
