{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.my.gaming.enable {
    programs.steam.enable = true;
    programs.gamemode.enable = true;
    programs.gamescope.enable = true;

    hardware.steam-hardware.enable = true;
    hardware.graphics.enable32Bit = true;

    environment.systemPackages = with pkgs; [
      mangohud
    ];
  };
}
