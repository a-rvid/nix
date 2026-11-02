{ inputs, ... }:
{
  imports = [
    inputs.preservation.nixosModules.default
    ../options.nix
    ./boot.nix
    ./core.nix
    ./desktop.nix
    ./gaming.nix
    ./nvidia.nix
    ./packages.nix
    ./preservation.nix
    ./secrets.nix
  ];
}
