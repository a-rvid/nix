{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.my.desktop.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = false;
    };

    environment.etc."hypr/hyprland.conf".text = ''
      $mod = SUPER

      monitor = ,preferred,auto,1

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

      $terminal = alacritty
      $menu = fuzzel

      bind = $mod, Return, exec, $terminal
      bind = $mod, Q, killactive
      bind = $mod SHIFT, Q, exit
      bind = $mod, Space, exec, $menu

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

    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd '${pkgs.hyprland}/bin/start-hyprland -- --config /etc/hypr/hyprland.conf'";
        user = "greeter";
      };
    };

    hardware.graphics.enable = true;

    xdg.portal.enable = true;
    xdg.portal.config.hyprland = {
      default = "gtk";
      "org.freedesktop.impl.portal.ScreenCast" = "hyprland";
      "org.freedesktop.impl.portal.Screenshot" = "hyprland";
    };

    environment.systemPackages = [ pkgs.xdg-utils ];
  };
}
