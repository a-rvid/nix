{ config, lib, pkgs, ... }:
let
  userName = config.my.profile.userName;

  themeToggle = pkgs.writeShellScriptBin "theme-toggle" ''
    set -eu

    state_dir="$HOME/.local/state/theme"
    state_file="$state_dir/state"
    generated_dir="$state_dir/generated"

    mkdir -p "$generated_dir"

    if [ ! -f "$state_file" ]; then
      echo "light" > "$state_file"
    fi

    current="$(cat "$state_file")"
    if [ "$current" = "light" ]; then
      next="dark"
      scheme=1
    else
      next="light"
      scheme=2
    fi

    echo "$next" > "$state_file"

    # Persisted theme marker consumed by shell and app hooks.
    printf "mode=%s\n" "$next" > "$generated_dir/theme.env"

    # xdg-desktop-portal appearance setting: 1 dark, 2 light.
    gsettings set org.gnome.desktop.interface color-scheme "prefer-$next" || true

    # Foot server live reload for already running clients.
    pkill -HUP foot || true

    # Reload sway and quickshell so shell components re-read state.
    swaymsg reload >/dev/null 2>&1 || true
    pkill -USR1 qs >/dev/null 2>&1 || true
  '';

  osdUpdate = pkgs.writeShellScriptBin "qs-osd-update" ''
    set -eu

    kind="''${1:-}"
    value="''${2:-}"

    state_dir="$HOME/.local/state/theme/generated"
    mkdir -p "$state_dir"

    printf "kind=%s\nvalue=%s\n" "$kind" "$value" > "$state_dir/osd.env"
    pkill -USR1 qs >/dev/null 2>&1 || true
  '';

  volumeStep = pkgs.writeShellScriptBin "qs-volume-step" ''
    set -eu

    direction="''${1:-up}"
    if [ "''${direction}" = "up" ]; then
      wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
    else
      wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
    fi

    vol="$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ | ${pkgs.gnugrep}/bin/grep -o '[0-9]\+\.[0-9]\+' | head -n1 || echo 0)"
    pct="$(${pkgs.gawk}/bin/awk -v v="$vol" 'BEGIN { print int(v*100) }')"
    ${osdUpdate}/bin/qs-osd-update volume "$pct"
    ${pkgs.libnotify}/bin/notify-send -r 9910 "Volume" "$pct%"
  '';

  brightnessStep = pkgs.writeShellScriptBin "qs-brightness-step" ''
    set -eu

    direction="''${1:-up}"
    if [ "''${direction}" = "up" ]; then
      brightnessctl set +5% >/dev/null
    else
      brightnessctl set 5%- >/dev/null
    fi

    current="$(brightnessctl g)"
    max="$(brightnessctl m)"
    pct="$(${pkgs.gawk}/bin/awk -v c="$current" -v m="$max" 'BEGIN { if (m == 0) print 0; else print int((c/m)*100) }')"
    ${osdUpdate}/bin/qs-osd-update brightness "$pct"
    ${pkgs.libnotify}/bin/notify-send -r 9911 "Brightness" "$pct%"
  '';
in
{
  config = lib.mkIf config.my.desktop.enable {
    services.xserver.enable = true;

    services.displayManager.sddm = {
      enable = config.my.desktop.greeter == "sddm";
      wayland.enable = true;
    };

    programs.dconf.enable = true;

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    services.gnome.gnome-keyring.enable = true;

    security.pam.services = {
      login.enableGnomeKeyring = true;
      sddm.enableGnomeKeyring = true;
      swaylock = {};
    };

    security.polkit.enable = true;
    services.power-profiles-daemon.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true;
    };

    services.blueman.enable = true;

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];

    programs.sway = {
      enable = true;
      package = pkgs.swayfx;
      extraPackages = with pkgs; [
        foot
        grim
        slurp
        wl-clipboard
        swaybg
        swayidle
        swaylock
        brightnessctl
        playerctl
        pavucontrol
        networkmanagerapplet
        libnotify
        clipman
        wf-recorder
        quickshell
      ];
      wrapperFeatures.gtk = true;
      extraSessionCommands = ''
        export XDG_CURRENT_DESKTOP=sway
        export XDG_SESSION_TYPE=wayland
      '';
      extraOptions = [ "--unsupported-gpu" ];
    };

    environment.etc."sway/config".text = ''
      set $mod Mod4
      set $term footclient
      set $menu qs -p launcher

      font pango:JetBrainsMono Nerd Font 11

      xwayland enable
      workspace_layout tabbed

      smart_borders on
      titlebar_padding 8 4
      titlebar_border_thickness 2

      default_border pixel 2
      default_floating_border pixel 2
      corner_radius 10
      shadows on
      shadow_blur_radius 20
      shadow_color #00000066
      blur enable
      blur_radius 10
      blur_passes 3
      blur_xray on

      animation_duration_ms ${toString config.my.desktop.session.animationDurationMs}

      # Layer-shell namespace effect mapping for Quickshell surfaces.
      layer_effects "qs-bar" blur enable; corner_radius 14
      layer_effects "qs-panel" blur enable; corner_radius 16
      layer_effects "qs-launcher" blur enable; corner_radius 18
      layer_effects "qs-osd" blur enable; corner_radius 14
      layer_effects "qs-notify" blur enable; corner_radius 14

      input type:keyboard {
        xkb_layout ${config.my.locale.keymap.xkbLayout}
      }

      bindsym $mod+Return exec $term
      bindsym $mod+d exec $menu
      bindsym $mod+b exec xdg-open https://duckduckgo.com
      bindsym $mod+t exec ${themeToggle}/bin/theme-toggle

      bindsym $mod+section exec pkill -USR2 qs

      bindsym $mod+h focus left
      bindsym $mod+j focus down
      bindsym $mod+k focus up
      bindsym $mod+l focus right

      bindsym $mod+Shift+h move left
      bindsym $mod+Shift+j move down
      bindsym $mod+Shift+k move up
      bindsym $mod+Shift+l move right

      bindsym $mod+w layout tabbed
      bindsym $mod+e layout toggle split
      bindsym $mod+f fullscreen toggle
      bindsym $mod+Shift+space floating toggle
      bindsym $mod+q kill

      bindsym $mod+x scratchpad show
      bindsym $mod+Shift+x move scratchpad

      bindsym Escape exec swaylock -f

      bindsym Print exec grim -g "$(slurp)" - | wl-copy
      bindsym Shift+Print exec grim - | wl-copy
      bindsym $mod+Print exec pkill wf-recorder || wf-recorder -f "$HOME/Videos/$(date +%F_%H-%M-%S).mp4"

      bindsym XF86AudioRaiseVolume exec ${volumeStep}/bin/qs-volume-step up
      bindsym XF86AudioLowerVolume exec ${volumeStep}/bin/qs-volume-step down
      bindsym XF86AudioMute exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bindsym XF86MonBrightnessUp exec ${brightnessStep}/bin/qs-brightness-step up
      bindsym XF86MonBrightnessDown exec ${brightnessStep}/bin/qs-brightness-step down
      bindsym XF86AudioPlay exec playerctl play-pause
      bindsym XF86AudioNext exec playerctl next
      bindsym XF86AudioPrev exec playerctl previous

      ${lib.concatStringsSep "\n" (map (n: "bindsym $mod+${toString n} workspace number ${toString n}") (lib.range 1 9))}
      ${lib.concatStringsSep "\n" (map (n: "bindsym $mod+Shift+${toString n} move container to workspace number ${toString n}") (lib.range 1 9))}

      exec_always --no-startup-id qs
      exec_always --no-startup-id nm-applet --indicator
      exec_always --no-startup-id clipman store --no-persist
      exec_always --no-startup-id swayidle -w timeout 300 'swaylock -f' before-sleep 'swaylock -f'
    '';

    services.libinput.enable = true;

    environment.systemPackages = [
      themeToggle
      osdUpdate
      volumeStep
      brightnessStep
      pkgs.mako
    ];

    systemd.user.services.quickshell = {
      description = "Quickshell";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.quickshell}/bin/qs";
        Restart = "on-failure";
        RestartSec = 1;
      };
    };

    assertions = [
      {
        assertion = config.my.desktop.session.compositor == "swayfx";
        message = "Only swayfx compositor is currently implemented.";
      }
      {
        assertion = config.my.desktop.session.shell == "quickshell";
        message = "Only quickshell shell is currently implemented.";
      }
    ];
  };
}
