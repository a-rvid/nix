{ config, inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.nixos-hardware.nixosModules.asus-zephyrus-ga401
    inputs.home-manager.nixosModules.home-manager
    ./hardware.nix
    ./disko.nix
    ../../modules/nixos
  ];

  networking.hostName = "nvidia";
  system.stateVersion = config.my.stateVersion;

  my = {
    profile.userName = "user";
    profile.fullName = "Arvid Andersson";

    locale = {
      uiLocale = "en_US.UTF-8";
      formatsLocale = "sv_SE.UTF-8";
      timeZone = "Europe/Stockholm";
      keymap = {
        xkbLayout = "se";
        consoleKeyMap = "sv-latin1";
      };
    };

    desktop.enable = true;
    features = {
      gaming.enable = true;
      development.enable = true;
      spotify.enable = true;
    };

    browser = {
      librewolf.enable = true;
      disableNova = true;
    };

    persistence.enable = true;
    hardware.nvidiaLaptop.enable = true;
  };

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = ".backup";
    users.${config.my.profile.userName} = import ../../modules/home-manager.nix;
    extraSpecialArgs = { inherit inputs; };
  };
}
