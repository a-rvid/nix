# Hosts

Each directory here is a buildable `nixosConfigurations.<name>` unless it starts
with `_`.

## Add a device

1. Copy the template:

   ```sh
   cp -r hosts/_template hosts/<name>
   ```

2. In `hosts/<name>/default.nix`:
   - rename the directory and set `networking.hostName`;
   - set `system.stateVersion` to the release used at first install;
   - set `my.username`, `my.userDescription`, and `my.timeZone`;
   - enable only the features the device actually has
     (`my.desktop`, `my.gaming`, `my.nvidia`, `my.preservation`,
     `my.secrets`);
   - import a matching `nixos-hardware` profile if one exists, for example:

     ```nix
     imports = [
       inputs.nixos-hardware.nixosModules.asus-zephyrus-ga401
       # ...
     ];
     ```

3. Fill in `hosts/<name>/hardware.nix` from the target machine's
   `nixos-generate-config` output or a nixos-facter report.

4. If the device will be installed with disko:

   ```sh
   cp hosts/<name>/disko.nix.example hosts/<name>/disko.nix
   ```

   Edit the disk by-id path, then add `./disko.nix` to the imports. **Disko
   erases the target disk.** With `my.preservation.enable`, root is a RAM
   filesystem; only declared paths under `/persist` survive reboots.

5. If the host uses agenix secrets, ensure the matching private key is available
   before first activation (under `/persist/home/<user>/.ssh/` when preservation
   is enabled, otherwise `/home/<user>/.ssh/`), and add its SSH public key to
   `agenix-rules.nix`. Re-encrypt existing secrets with `nix run .#agenix -- -r`.

The new host appears automatically:

```sh
nix eval .#nixosConfigurations.<name>.config.networking.hostName
nix build .#nixosConfigurations.<name>.config.system.build.toplevel
```

## Bootloaders

The shared modules do not choose a bootloader. Set it per host. The template and
`hosts/nvidia` use systemd-boot; a BIOS/legacy device can use GRUB instead.
