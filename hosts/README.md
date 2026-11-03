# Hosts

Each directory in `hosts/` (except names starting with `_`) is a buildable NixOS host.

## Included examples

- `nvidia`: desktop + gaming + preservation + NVIDIA laptop profile.
- `headless`: desktop disabled example (clean server mode).

## Adding a new host

1. Copy `hosts/_template/default.nix` to `hosts/<name>/default.nix`.
2. Adjust `my.*` options to enable only the needed features.
3. For disk installs, add a host-local `disko.nix` and import it from that host.
