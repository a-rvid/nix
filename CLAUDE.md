# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

A flake-based, multi-host NixOS configuration. It is **config-only**: do not
install NixOS, run disko, or modify the running Fedora system. The first host is
`hosts/mobile`; added hosts are discovered automatically.

## Commands

```sh
# Evaluate the config without building (fast option/type check)
nix eval --raw .#nixosConfigurations.mobile.config.networking.hostName

# Full system build (several GB on first run)
nix build .#nixosConfigurations.mobile.config.system.build.toplevel

# Stow dotfiles into $HOME
nix run .#link -- mobile

# Format Nix files (nixfmt-rfc-style)
nix fmt

# Update all flake inputs
nix flake update

# Shell-script syntax check
bash -n scripts/link-dotfiles.sh
```

There is no test suite, VM, or ISO by design. The system verification path is
the full system build. Do not add VM or ISO outputs without being asked.

### Nix on this Fedora host

The Fedora Nix RPM requires a SELinux label for the daemon socket:

```sh
sudo semanage fcontext -a -t var_run_t '/nix/var/nix/daemon-socket(/.*)?'
sudo restorecon -Rv /nix/var/nix/daemon-socket
sudo systemctl reset-failed nix-daemon.socket
sudo systemctl start nix-daemon.socket
```

Without it, `nix-daemon.socket` fails with `Permission denied`.

## Architecture

### Host discovery and composition

`flake.nix` discovers every directory under `hosts/` whose name does not start
with `_`. Each becomes `nixosConfigurations.<name>` via `mkHost`, which evaluates
`./hosts/<name>` plus `./modules/nixos` with `specialArgs = { inherit inputs; }`.

`hosts/_template` is documentation and is **not** a buildable host. Copy it to add
a device. A host's `default.nix` owns only:

- imports of `nixos-hardware` profiles and the disko module;
- the bootloader, hostname, and `system.stateVersion`;
- `imports = [ ./hardware.nix ./disko.nix ../../modules/nixos ]`;
- its `my.*` values.

Shared modules must not contain machine-specific assumptions. Hardware details
(NVIDIA bus IDs, kernel modules, firmware) belong in `hosts/<name>/`.

### Feature toggling

`modules/options.nix` defines the feature switches: `my.desktop`,
`my.gaming`, `my.nvidia`, `my.preservation`, `my.secrets`, plus `my.username`
and `my.timeZone`. Shared modules use
`config = lib.mkIf config.my.<feature>.enable { ... };`. Add new optional
behavior here rather than creating per-host conditionals inside shared modules.

- `core.nix`: Nix settings/GC, NetworkManager, time zone, user/groups, PipeWire,
  libinput, upower, fwupd, power-profiles-daemon, zram, fonts.
- `desktop.nix`: greetd + tuigreet, Hyprland Wayland compositor, portals, and
  the Nix-managed `/etc/hypr/hyprland.conf`.
- `preservation.nix`: optional tmpfs root and state declarations on `/persist`.
  `hosts/mobile/disko.nix` provides disk-backed `/persist`, `/nix`, and
  `/volatile` subvolumes. `/tmp` and `/home/<user>/Downloads` bind to paths
  within `/volatile`, which are cleared by a service ordered before those mounts.
- `gaming.nix`, `nvidia.nix`, `secrets.nix`: gated features.
- `boot.nix`: generic boot settings only; bootloaders are per host.

The GA401 profile (`inputs.nixos-hardware.nixosModules.asus-zephyrus-ga401`)
already sets PRIME bus IDs, open kernel modules, modesetting, dynamic boost, and
`asusd` — do not duplicate those in shared modules.

### Dotfiles

No Home Manager. `home/common/` is a GNU Stow package that mirrors `$HOME`;
optional `home/<host>/` packages are stowed after it. `scripts/link-dotfiles.sh`
uses `stow --no-folding --restow` and only adopts files with an explicit
`--adopt`.

The Hyprland config is declared in `modules/nixos/desktop.nix` and installed
through NixOS at `/etc/hypr/hyprland.conf`; rebuild to apply changes.

### Secrets

Secrets use agenix. `agenix-rules.nix` contains the SSH public-key recipients;
the matching private key must be available before first activation. With
preservation enabled, agenix reads it directly from
`/persist/home/<user>/.ssh/id_ed25519`; otherwise it reads
`/home/<user>/.ssh/id_ed25519`.

### Disko

`hosts/mobile/disko.nix` describes a destructive whole-disk layout (ESP + LUKS +
btrfs) for the machine's NVMe. It is only for installation; never run disko or
apply this config on the current Fedora system.

## Important gotchas

- Flakes in a Git repo only see **tracked or staged** files. After creating a new
  host or module, `git add` it (or `git add -N`) before `nix` commands.
- NixOS 26.05 reaches EOL on 2026-12-31; 26.11 is expected around end of November
  2026. Update the nixpkgs input and rebuild before installing.
- `my.username` is `user` on `mobile` and is only a placeholder.
- The repo deliberately has no flake-parts, Home Manager, `just`, VM/ISO outputs,
  or validation app; preserve that unless the user asks otherwise.
- Agenix secrets are encrypted to SSH public keys in `agenix-rules.nix`; private
  keys must remain outside the repository.
