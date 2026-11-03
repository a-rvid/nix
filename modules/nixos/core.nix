{ config, lib, pkgs, ... }:
let
  userName = config.my.profile.userName;
in
{
  config = {
    time.timeZone = config.my.locale.timeZone;

    i18n = {
      defaultLocale = config.my.locale.uiLocale;
      extraLocaleSettings = {
        LC_ADDRESS = config.my.locale.formatsLocale;
        LC_IDENTIFICATION = config.my.locale.formatsLocale;
        LC_MEASUREMENT = config.my.locale.formatsLocale;
        LC_MONETARY = config.my.locale.formatsLocale;
        LC_NAME = config.my.locale.formatsLocale;
        LC_NUMERIC = config.my.locale.formatsLocale;
        LC_PAPER = config.my.locale.formatsLocale;
        LC_TELEPHONE = config.my.locale.formatsLocale;
        LC_TIME = config.my.locale.formatsLocale;
      };
    };

    console.keyMap = config.my.locale.keymap.consoleKeyMap;

    services.xserver.xkb = {
      layout = config.my.locale.keymap.xkbLayout;
      variant = "";
    };

    users.users.${userName} = {
      isNormalUser = true;
      description = config.my.profile.fullName;
      extraGroups = [
        "networkmanager"
        "wheel"
        "audio"
        "video"
      ];
      shell = pkgs.bashInteractive;
    };

    networking.networkmanager.enable = true;

    programs.git.enable = true;
    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;

    security.sudo.wheelNeedsPassword = true;

    environment.systemPackages = with pkgs; [
      age
      btop
      curl
      fd
      file
      gnupg
      jq
      man-pages
      neovim
      nh
      ripgrep
      tree
      unzip
      wget
    ];

    services.openssh.enable = lib.mkDefault (!config.my.desktop.enable);

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    nixpkgs.config.allowUnfree = true;
  };
}
