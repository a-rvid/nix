{
  config,
  lib,
  pkgs,
  ...
}:
let
  qs = import ../packages/quickshell.nix { inherit pkgs; };
  hyprlandConfig = pkgs.writeText "hyprland.conf" ''
    $mod = SUPER
    $iconFont = JetBrainsMono Nerd Font

    monitor = ,preferred,auto,1

    misc {
        font_family = $iconFont
    }

    input {
        kb_layout = se
    }

    general {
        gaps_in = 5
        gaps_out = 5
        border_size = 2
        col.active_border = rgba(6dade3ff)
        col.inactive_border = rgba(bbbbbbff)
    }

    $terminal = ${pkgs.foot}/bin/footclient

    bind = $mod, Return, exec, $terminal
    bind = $mod, Q, killactive
    bind = $mod SHIFT, Q, exit
    bind = $mod, Space, togglefloating
    bind = $mod, D, exec, ${pkgs.quickshell}/bin/quickshell ipc call shell toggleLauncher
    bind = $mod, X, exec, ${pkgs.quickshell}/bin/quickshell ipc call shell reveal
    bind = $mod, T, exec, ${pkgs.quickshell}/bin/quickshell ipc call shell toggleThemePicker
    bind = $mod, L, exec, ${pkgs.hyprlock}/bin/hyprlock
    exec-once = ${pkgs.foot}/bin/foot --server
    exec-once = ${qs}/bin/qs

    bind = $mod, 1, workspace, 1
    bind = $mod, 2, workspace, 2
    bind = $mod, 3, workspace, 3
    bind = $mod, 4, workspace, 4
    bind = $mod, 5, workspace, 5
    bind = $mod, 6, workspace, 6
    bind = $mod, 7, workspace, 7
    bind = $mod, 8, workspace, 8
    bind = $mod, 9, workspace, 9

    bind = $mod SHIFT, 1, movetoworkspace, 1
    bind = $mod SHIFT, 2, movetoworkspace, 2
    bind = $mod SHIFT, 3, movetoworkspace, 3
    bind = $mod SHIFT, 4, movetoworkspace, 4
    bind = $mod SHIFT, 5, movetoworkspace, 5
    bind = $mod SHIFT, 6, movetoworkspace, 6
    bind = $mod SHIFT, 7, movetoworkspace, 7
    bind = $mod SHIFT, 8, movetoworkspace, 8
    bind = $mod SHIFT, 9, movetoworkspace, 9
  '';
  hyprlandSession = pkgs.writeShellApplication {
    name = "hyprland-session";
    runtimeInputs = [ pkgs.hyprland ];
    text = ''
      exec ${pkgs.hyprland}/bin/start-hyprland -- --config /etc/hypr/hyprland.conf "$@"
    '';
  };
in
{
  config = lib.mkIf config.my.desktop.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = false;
    };

    programs.dconf.enable = true;

    networking.networkmanager.settings.connectivity = {
      uri = "http://nmcheck.gnome.org/check_network_status.txt";
      interval = 300;
      response = "NetworkManager is online";
    };

    environment.etc."hypr/hyprland.conf".source = hyprlandConfig;

    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd '${hyprlandSession}/bin/hyprland-session'";
        user = "greeter";
      };
    };

    hardware.graphics.enable = true;
    fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

    xdg.portal.enable = true;
    xdg.portal.config.hyprland = {
      default = "gtk";
      "org.freedesktop.impl.portal.ScreenCast" = "hyprland";
      "org.freedesktop.impl.portal.Screenshot" = "hyprland";
    };

    environment.systemPackages = [
      pkgs.gsettings-desktop-schemas
      pkgs.xdg-utils
      qs
      pkgs.foot
      pkgs.hyprlock
    ];
  };
}
