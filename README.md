# NixOS Configuration Rebuild

This branch contains a clean rewrite of the system configuration.

## Goals

- Feature-oriented modularization.
- Host-level composability through a new `my.*` schema.
- Impermanence/preservation semantics retained where required.
- SwayFX + Quickshell desktop with runtime theming and animated shell UX.
- Switch-ready correctness for the target machine.

## Quick Start

- Build all checks: `nix flake check`
- Build headless host: `nix build .#nixosConfigurations.headless.config.system.build.toplevel --no-link`
- Build nvidia host: `nix build .#nixosConfigurations.nvidia.config.system.build.toplevel --no-link`

## Docs

- Architecture and implementation contract: [SPEC.md](SPEC.md)
- Keybind reference: [KEYBINDS.md](KEYBINDS.md)
- Host conventions: [hosts/README.md](hosts/README.md)
