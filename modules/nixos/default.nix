{ inputs, ... }:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
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
