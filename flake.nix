{
  description = "Fresh multi-host NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    preservation = {
      url = "github:nix-community/preservation";
    };

    swayfx = {
      url = "github:wlrfx/swayfx/0.6";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;

      hostNames = builtins.attrNames (
        lib.filterAttrs (name: type: type == "directory" && !(lib.hasPrefix "_" name)) (
          builtins.readDir ./hosts
        )
      );

      mkHost =
        hostName:
        lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs self; };
          modules = [
            {
              nixpkgs.overlays = [
                (
                  final: prev:
                  let
                    swayfx-unwrapped = inputs.swayfx.packages.${final.stdenv.hostPlatform.system}.default;
                  in
                  {
                    swayfx = prev.sway.override {
                      sway-unwrapped = swayfx-unwrapped;
                    };
                  }
                )
              ];
            }
            ./hosts/${hostName}
          ];
        };
    in
    {
      nixosConfigurations = lib.genAttrs hostNames mkHost;

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;

      devShells.${system}.default = nixpkgs.legacyPackages.${system}.mkShell {
        packages = with nixpkgs.legacyPackages.${system}; [
          git
          nixd
          nixfmt
          nh
        ];
      };
    };
}
