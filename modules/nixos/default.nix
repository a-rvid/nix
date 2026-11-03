{ ... }:
{
  imports = [
    ../options.nix
    ./boot.nix
    ./core.nix
    ./preservation.nix
    ./nvidia.nix
    ./desktop.nix
    ./gaming.nix
    ./packages.nix
  ];
}
