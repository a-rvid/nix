{
  config,
  lib,
  pkgs,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "@wheel"
    ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nix.optimise.automatic = true;

  networking.networkmanager.enable = true;

  time.timeZone = config.my.timeZone;
  console.keyMap = "se";

  users.users.${config.my.username} = {
    isNormalUser = true;
    description = config.my.userDescription;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "input"
    ]
    ++ lib.optionals config.my.gaming.enable [ "gamemode" ];
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.libinput.enable = true;
  services.upower.enable = true;
  services.fwupd.enable = true;
  services.power-profiles-daemon.enable = true;

  zramSwap.enable = true;
  zramSwap.memoryPercent = 50;

  fonts.packages = with pkgs; [
    dejavu_fonts
    liberation_ttf
    noto-fonts
  ];
}
