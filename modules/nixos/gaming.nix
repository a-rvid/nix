{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.my.features.gaming.enable {
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    programs.gamemode.enable = true;

    environment.systemPackages = with pkgs; [
      mangohud
      protonup-qt
    ];
  };
}
