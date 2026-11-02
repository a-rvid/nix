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
hosts/nvidia/             first host: ASUS ROG Zephyrus G14
hosts/_template/          copy this to add a device (not built)
home/.config/             Quickshell source and Firefox configuration assets
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
nix build .#nixosConfigurations.nvidia.config.system.build.toplevel
nix run .#qs                            # run Quickshell directly
nix shell nixpkgs#nh -c nh search hyprland # nh is available, but optional
```

The desktop starts Hyprland from greetd after login. XWayland is disabled; this
configuration runs Wayland applications only.

## Hyprland config

The Hyprland config is declared in Nix at
`modules/nixos/desktop.nix` and installed as
`/etc/hypr/hyprland.conf` (a NixOS-managed symlink into the store).

The Quickshell bar runs from `home/.config/quickshell/` in the
Nix store. Run it manually with `nix run .#qs`; the desktop starts the same
package on login. Its theme selection is stored in the user's state directory.
It uses
JetBrainsMono Nerd Font, reserves a 28 px top panel on each monitor, and
temporarily reveals the bar with `Super+X`. `Super+D` opens a searchable
Quickshell launcher for installed desktop applications; `Super+Space` toggles
the focused window's floating state. `Super+Return` opens Foot through its
session server. `Super+T` opens the persistent Gruvbox Light / Nord selector;
the backgrounds are solid-color placeholders. The panel itself remains
transparent. NetworkManager uses its GNOME connectivity-check endpoint to
distinguish Internet access from a local-only connection. Layer rules are not
required.

The Hyprland configuration is a Nix store derivation exposed through
`/etc/hypr/hyprland.conf` and read by the session launcher. Rebuild and
activate the system after editing either configuration.

## Firefox theme

The Quickshell appearance picker (`Super+T`) also sets the desktop color-scheme
preference. NixOS generates Firefox's managed policies at
`/etc/firefox/policies/policies.json` and enables profile custom stylesheets.
The custom Firefox package symlinks
`home/.config/firefox/userChrome.css` into Firefox's default profile
template, so newly created profiles inherit the Gruvbox Light / Nord Dark
browser-chrome styles. Existing profiles need the stylesheet linked into their
`chrome/` directory once. Firefox follows the system light/dark preference;
restart it after editing the stylesheet.

The policies install uBlock Origin, Decentraleyes, FoxyProxy Basic,
SponsorBlock, Dark Reader, and Consent-O-Matic; set DuckDuckGo as the search
engine and homepage; enable tracking protection and HTTPS-only mode; and turn
off telemetry, studies, form history, Pocket, search suggestions, and app
updates. Firefox updates are delivered by NixOS system updates. FoxyProxy is
installed as FoxyProxy Basic and its settings are supplied automatically via
Firefox's managed extension storage from
`home/.config/firefox/foxyproxy-basic.json`. No manual import is needed.
The proxy entry is named `Burp` and points to `127.0.0.1:8080`. The supplied
configuration's mode is `disable`, so FoxyProxy loads the entry but does not
route traffic until you enable/select it in the extension.

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
| `my.desktop.enable` | Hyprland, greetd, portals, Firefox and desktop utilities |
| `my.gaming.enable` | Steam, gamemode, gamescope, 32-bit graphics |
| `my.nvidia.enable` | NVIDIA driver and modesetting |
| `my.preservation.enable` | ephemeral RAM root with selected paths preserved to `/persist` |
| `my.secrets.enable` | agenix secrets |

Command-line tools remain available on every host; Firefox and Wayland desktop
utilities are installed only when `my.desktop.enable` is enabled.

When enabled on `nvidia`, `/` and `/home` are volatile tmpfs. `/persist` and
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
the first activation; never commit or share it. For `nvidia`, place it at
`/persist/home/user/.ssh/id_ed25519` with owner `user` and mode `0600` so it is
available before agenix starts. Builds do not need the private key.

For another host or administrator, add its SSH public key to
`agenix-rules.nix`, then re-encrypt secrets using `nix run .#agenix -- -r`.

## Installing later

The disko layouts are destructive and are not used by any command in this repo.
When you are ready to install on a target:

```sh
nix run github:nix-community/nixos-anywhere -- \
  --flake .#nvidia --target-host root@<target>
```

This runs the host's disko layout and **erases the target disk**. Set the user's
password afterwards (for example via `nixos-enter --root /mnt -c 'passwd user'`
or a temporary `initialPassword`). Do not run disko against the current Fedora
machine.

## Notes

- NixOS 26.05 reaches end of life on 2026-12-31; 26.11 is expected around the end
  of November 2026. Update `nixpkgs` and rebuild before installing later.
- Hyprland comes from the pinned NixOS 26.05 channel; XWayland is disabled.
- `my.preservation.enable` is opt-in. The NVIDIA Disko layout includes a
  persistent `/persist` subvolume, tmpfs root, and a disk-backed `@volatile`
  subvolume mounted at `/volatile`.
- `services.xserver.videoDrivers` is still used to select the NVIDIA driver in
  NixOS, but the desktop does not enable an X server or XWayland.
- The NVIDIA bus IDs and ASUS quirks for `nvidia` come from
  `nixos-hardware`'s GA401 profile; do not duplicate them in shared modules.
- Only `x86_64-linux` is supported for now.
