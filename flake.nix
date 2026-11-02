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

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    preservation.url = "github:nix-community/preservation";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
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
          modules = [
            ./hosts/${hostName}
            ./modules/nixos
          ];
        };

      linkDotfiles = pkgs.writeShellApplication {
        name = "link-dotfiles";
        runtimeInputs = [
          pkgs.bash
          pkgs.coreutils
          pkgs.stow
        ];
        text = ''
          exec ${pkgs.bash}/bin/bash ${./scripts/link-dotfiles.sh} "$@"
        '';
      };
    in
    {
      nixosConfigurations = lib.genAttrs hostNames mkHost;

      packages.${system} = {
        hyprland = pkgs.hyprland;
      };

      apps.${system} = {
        link = {
          type = "app";
          program = "${linkDotfiles}/bin/link-dotfiles";
        };
      };

      formatter.${system} = pkgs.nixfmt-rfc-style;

      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          age
          nixd
          nixfmt-rfc-style
          nh
          hyprland
          sops
          stow
        ];
      };
    };
}
