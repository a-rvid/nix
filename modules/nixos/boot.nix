{ config, lib, ... }:
{
  config = {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.systemd-boot.configurationLimit = 10;

    # Required on several NVIDIA setups to keep Wayland DRM paths stable.
    boot.kernelParams = lib.mkIf config.my.hardware.nvidiaLaptop.enable [
      "nvidia_drm.modeset=1"
      "nvidia_drm.fbdev=1"
    ];
  };
}
