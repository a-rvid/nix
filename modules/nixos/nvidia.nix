{ config, lib, ... }:
{
  config = lib.mkIf config.my.hardware.nvidiaLaptop.enable {
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      open = true;
      nvidiaSettings = true;
    };

    hardware.graphics.enable = true;
  };
}
