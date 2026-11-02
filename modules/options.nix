{ lib, ... }:
{
  options.my = {
    username = lib.mkOption {
      type = lib.types.str;
      default = "user";
      description = "Primary login name for this host.";
    };

    userDescription = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Description (GECOS field) for the primary user.";
    };

    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "UTC";
      description = "System time zone.";
    };

    desktop.enable = lib.mkEnableOption "the Hyprland Wayland desktop";
    gaming.enable = lib.mkEnableOption "Steam and gaming support";
    nvidia.enable = lib.mkEnableOption "NVIDIA GPU support";
    preservation.enable = lib.mkEnableOption "ephemeral root with preserved state";
    secrets.enable = lib.mkEnableOption "SOPS-Nix secrets";
  };
}
