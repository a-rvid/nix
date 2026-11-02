{
  description = "Multi-host NixOS configuration";

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

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    preservation.url = "github:nix-community/preservation";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = nixpkgs.lib;

      # Hosts are every directory under ./hosts that does not start with "_".
      # `_template` is documentation, not a buildable host.
      hostNames = builtins.attrNames (
        lib.filterAttrs (name: type: type == "directory" && !(lib.hasPrefix "_" name)) (
          builtins.readDir ./hosts
        )
      );

      mkHost =
        hostName:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [ ./hosts/${hostName} ];
        };

      qs = import ./modules/packages/quickshell.nix { inherit pkgs; };
    in
    {
      nixosConfigurations = lib.genAttrs hostNames mkHost;

      packages.${system} = {
        inherit qs;
        agenix = inputs.agenix.packages.${system}.agenix;
      };

      apps.${system} = {
        agenix = {
          type = "app";
          program = "${inputs.agenix.packages.${system}.agenix}/bin/agenix";
        };
        qs = {
          type = "app";
          program = "${qs}/bin/qs";
        };
      };

      formatter.${system} = pkgs.nixfmt-tree;

      devShells.${system}.default = pkgs.mkShell {
        packages =
          with pkgs;
          [
            age
            nixd
            nixfmt
            nh
            hyprland
          ]
          ++ [
            inputs.agenix.packages.${system}.agenix
          ];
      };
    };
}
