{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    ./hardware.nix
    ../../modules/nixos
  ];

  # Rename the directory, then change this to the device's hostname.
  networking.hostName = "CHANGEME";
  system.stateVersion = "26.05";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  my = {
    username = "user";
    userDescription = "";
    timeZone = "UTC";
    desktop.enable = false;
    gaming.enable = false;
    nvidia.enable = false;
    preservation.enable = false;
    secrets.enable = false;
  };
}
