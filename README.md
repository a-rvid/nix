# NixOS configuration

A multi-host NixOS flake. Shared modules live in `modules/`; everything
machine-specific lives in `hosts/<name>/`. Hosts are discovered automatically, so
adding a directory under `hosts/` (without a leading `_`) adds a
`nixosConfigurations.<name>` output.

This is currently a **configuration repository only** — nothing is installed and
the current Fedora system is untouched.

## Layout

```
flake.nix                 inputs, host discovery, apps, devShell
modules/options.nix       my.* options (user, time zone, feature toggles)
modules/nixos/            shared NixOS modules
hosts/mobile/             first host: ASUS ROG Zephyrus G14
hosts/_template/          copy this to add a device (not built)
home/common/              plain dotfiles, deployed with GNU Stow
scripts/link-dotfiles.sh  stow wrapper
secrets/                  agenix-encrypted secrets
```

## Bootstrap Nix on Fedora

The Fedora Nix package is installed but its daemon is not running, and the store
is empty:

```sh
sudo systemctl enable --now nix-daemon.socket
nix store ping
nix run nixpkgs#hello
```

Fedora's Nix RPMs do not ship an SELinux policy. If the socket fails with
`Failed to create listening socket ... Permission denied`, label the socket
directory and restart the unit:

```sh
sudo semanage fcontext -a -t var_run_t '/nix/var/nix/daemon-socket(/.*)?'
sudo restorecon -Rv /nix/var/nix/daemon-socket
sudo systemctl reset-failed nix-daemon.socket
sudo systemctl start nix-daemon.socket
```

If it is still denied, inspect `ausearch -m avc -ts recent`.

## Common commands

```sh
nix flake show
nix flake update                       # refresh flake.lock
nix build .#nixosConfigurations.mobile.config.system.build.toplevel
nix run .#link -- mobile               # stow dotfiles into $HOME
nix shell nixpkgs#nh -c nh search hyprland # nh is available, but optional
```

The desktop starts Hyprland from greetd after login. XWayland is disabled; this
configuration runs Wayland applications only.

## Hyprland config

The Hyprland config is declared in Nix at
`modules/nixos/desktop.nix` and installed as
`/etc/hypr/hyprland.conf` (a NixOS-managed symlink into the store).

Rebuild and activate the system after editing the Nix config.

## Adding a host

```sh
cp -r hosts/_template hosts/<name>
# edit hosts/<name>/default.nix: hostname, my.* settings
# edit hosts/<name>/hardware.nix from nixos-generate-config/nixos-facter
# optional: cp hosts/<name>/disko.nix.example hosts/<name>/disko.nix
#           and add ./disko.nix to the imports
nix eval .#nixosConfigurations.<name>.config.networking.hostName
```

Shared behavior is controlled with `my.*`:

| option | meaning |
| --- | --- |
| `my.username` | primary login |
| `my.timeZone` | system time zone |
| `my.desktop.enable` | Hyprland Wayland compositor, greetd and portals |
| `my.gaming.enable` | Steam, gamemode, gamescope, 32-bit graphics |
| `my.nvidia.enable` | NVIDIA driver and modesetting |
| `my.preservation.enable` | ephemeral RAM root with selected paths preserved to `/persist` |
| `my.secrets.enable` | agenix secrets |

Per-host dotfiles can be added under `home/<name>/`; the link script stows it
after `home/common/`.

When enabled on `mobile`, `/` and `/home` are volatile tmpfs. `/persist` and
`/nix` are disk-backed. Preservation keeps machine identity, system state,
SSH keys, and (when gaming is enabled) Steam data across boots.
The `@volatile` Btrfs subvolume is mounted at `/volatile`; `/tmp` and
`/home/<user>/Downloads` bind to `/volatile/tmp` and
`/volatile/home/<user>/Downloads`. Those contents are cleared at boot.
Everything else under `/home` is lost at reboot.
Enabling preservation does not migrate existing files into `/persist`; copy
anything needed before switching an existing installation to this layout.

## Secrets

The agenix recipient in `agenix-rules.nix` is the supplied SSH Ed25519 public
key. Encrypt or edit a secret with:

```sh
nix run .#agenix -- -e secrets/common.age
```

On NixOS, agenix decrypts with `/home/<user>/.ssh/id_ed25519`; with preservation
enabled, it reads the persistent source at `/persist/home/<user>/.ssh/id_ed25519`
directly. The matching private key must be securely copied to the target before
the first activation; never commit or share it. For `mobile`, place it at
`/persist/home/user/.ssh/id_ed25519` with owner `user` and mode `0600` so it is
available before agenix starts. Builds do not need the private key.

For another host or administrator, add its SSH public key to
`agenix-rules.nix`, then re-encrypt secrets using `nix run .#agenix -- -r`.

## Installing later

The disko layouts are destructive and are not used by any command in this repo.
When you are ready to install on a target:

```sh
nix run github:nix-community/nixos-anywhere -- \
  --flake .#mobile --target-host root@<target>
```

This runs the host's disko layout and **erases the target disk**. Set the user's
password afterwards (for example via `nixos-enter --root /mnt -c 'passwd user'`
or a temporary `initialPassword`). Do not run disko against the current Fedora
machine.

## Notes

- NixOS 26.05 reaches end of life on 2026-12-31; 26.11 is expected around the end
  of November 2026. Update `nixpkgs` and rebuild before installing later.
- Hyprland comes from the pinned NixOS 26.05 channel; XWayland is disabled.
- `my.preservation.enable` is opt-in. The mobile Disko layout includes a
  persistent `/persist` subvolume, tmpfs root, and a disk-backed `@volatile`
  subvolume mounted at `/volatile`.
- `services.xserver.videoDrivers` is still used to select the NVIDIA driver in
  NixOS, but the desktop does not enable an X server or XWayland.
- The NVIDIA bus IDs and ASUS quirks for `mobile` come from
  `nixos-hardware`'s GA401 profile; do not duplicate them in shared modules.
- Only `x86_64-linux` is supported for now.
