# NixOS Rebuild Specification

This repository is a clean rebuild focused on modularity, readability, and correctness.

## 1. Architecture Overview

The system is split into host definitions and reusable modules.

- `hosts/<name>/default.nix`: host composition and feature selection.
- `modules/options.nix`: the new `my.*` schema.
- `modules/nixos/*.nix`: feature modules for boot/core/preservation/desktop/browser/gaming/NVIDIA.
- `modules/home-manager.nix`: user-space config deployment and shell assets.
- `home/.config/quickshell/*`: Quickshell UI sources.

The flake auto-discovers buildable hosts under `hosts/` except directories prefixed with `_`.

## 2. New `my` Schema

The schema is intentionally explicit and feature-oriented.

- `my.profile.userName`
- `my.profile.fullName`
- `my.locale.uiLocale`
- `my.locale.formatsLocale`
- `my.locale.timeZone`
- `my.locale.keymap.{xkbLayout,consoleKeyMap}`
- `my.desktop.enable`
- `my.desktop.greeter`
- `my.desktop.session.{compositor,shell,animationDurationMs}`
- `my.features.{gaming.enable,development.enable,spotify.enable}`
- `my.browser.{librewolf.enable,disableNova}`
- `my.persistence.enable`
- `my.hardware.nvidiaLaptop.enable`

## 3. Host Profiles

- `hosts/nvidia`: desktop workstation profile with NVIDIA + disko + preservation.
- `hosts/headless`: desktop disabled profile proving clean headless behavior.
- `hosts/_template`: copyable skeleton.

## 4. Preservation and Impermanence

When `my.persistence.enable = true`:

- Root is `tmpfs`.
- `/persist` is mandatory and used by preservation.
- `/tmp` and `~/Downloads` bind from `/volatile` and are wiped on boot.
- `/etc/machine-id` and required system/user state paths are persisted.

New persisted paths for this rebuild:

- `~/.local/share/keyrings`
- `~/.local/state/theme`
- `~/.local/state/theme/generated`

## 5. Desktop and Shell Contract

Desktop stack is SwayFX + Quickshell.

- Compositor package is overlaid from SwayFX flake input.
- Sway config is emitted to `/etc/sway/config`.
- Layer-shell namespaces are reserved for Quickshell surfaces:
  - `qs-bar`
  - `qs-panel`
  - `qs-launcher`
  - `qs-osd`
  - `qs-notify`
- SwayFX `layer_effects` rules target these namespaces.

### Animation Quality Requirements

This is a hard requirement, not optional polish.

- Curtain-style transitions for launcher/panels/notifications where applicable.
- Coherent easing/duration across shell surfaces.
- No rectangular alpha artifacts behind rounded surfaces.
- No jitter/tearing/stuck animation states.

## 6. Runtime Theming

The toggle command (`Win+t`) writes runtime state and triggers reload flows.

- state file root: `~/.local/state/theme`
- generated artifacts: `~/.local/state/theme/generated`
- expected behavior: no rebuild required for switching

## 7. Browser and Privacy Baseline

Browser target is LibreWolf.

- Required extension set is preserved except Dark Reader.
- `browser.nova.enabled` is forced off through policy preferences.
- Privacy baseline includes RFP and strict tracking/cookie partitioning settings.

## 8. OSD and Notifications

Volume/brightness actions are routed through helper scripts that publish transient UI state and signal Quickshell refresh hooks.

- OSD state sink: `~/.local/state/theme/generated/osd.env`
- notification curtain surface: `qs-notify`

Note: final visual behavior must still be verified in a running Wayland session.

## 9. Validation Checklist

Minimum checks for every implementation pass:

1. `nix flake check`
2. `nix build .#nixosConfigurations.headless.config.system.build.toplevel --no-link`
3. `nix build .#nixosConfigurations.nvidia.config.system.build.toplevel --no-link`

For desktop-specific verification (manual/hardware):

1. Run `nixos-rebuild build` for target host.
2. Start session and verify Quickshell animations and namespace blur behavior.
3. Verify OSD and notification UX during brightness/volume changes.
4. Verify lock/keyring/portal/screen-share flows.
5. Verify Swedish layout behavior for the section key.

## 10. Switch-Readiness Requirement

The implementation goal is switch-readiness for the target machine.

- The agent never runs `nixos-rebuild switch`.
- The final configuration must be safe for the user to run `nixos-rebuild switch`.
- Rollback path and known risks must be documented before handoff.
