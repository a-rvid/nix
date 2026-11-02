{ config, inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.nixos-hardware.nixosModules.asus-zephyrus-ga401
    ./hardware.nix
    ./disko.nix
    ../../modules/nixos
  ];

  networking.hostName = "nvidia";
  system.stateVersion = "26.05";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  my = {
    username = "user";
    userDescription = "Arvid Andersson";
    timeZone = "Europe/Stockholm";
    desktop.enable = true;
    gaming.enable = true;
    nvidia.enable = true;
    preservation.enable = true;
    secrets.enable = true;
  };
}
