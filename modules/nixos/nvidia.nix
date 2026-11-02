{ config, lib, ... }:
{
  config = lib.mkIf config.my.nvidia.enable {
    # NixOS still uses this option to select the NVIDIA driver for Wayland.
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia.modesetting.enable = true;

    # PRIME bus IDs, open kernel modules and dynamic boost are host-specific.
    # nixos-hardware profiles (for example asus-zephyrus-ga401) set them.
  };
}
