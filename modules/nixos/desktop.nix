{
  config,
  lib,
  pkgs,
  ...
}:
let
  qs = import ../packages/quickshell.nix { inherit pkgs; };
  applyUiTheme = pkgs.writeShellApplication {
    name = "apply-ui-theme";
    runtimeInputs = [ pkgs.bash pkgs.coreutils pkgs.gnused pkgs.gnugrep ];
    text = ''
      set -euo pipefail

      theme="''${1:-nord}"
      case "$theme" in
        nord)
          foot_bg="2e3440"
          foot_fg="d8dee9"
          foot_regular0="3b4252"
          foot_regular1="bf616a"
          foot_regular2="a3be8c"
          foot_regular3="ebcb8b"
          foot_regular4="81a1c1"
          foot_regular5="b48ead"
          foot_regular6="88c0d0"
          foot_regular7="e5e9f0"
          foot_bright0="4c566a"
          foot_bright1="bf616a"
          foot_bright2="a3be8c"
          foot_bright3="ebcb8b"
          foot_bright4="81a1c1"
          foot_bright5="b48ead"
          foot_bright6="8fbcbb"
          foot_bright7="eceff4"
          btop_theme="nord"
          firefox_surface="#2E3440"
          firefox_foreground="#D8DEE9"
          firefox_panel="#3B4252"
          firefox_accent="#88C0D0"
          firefox_widget="#434C5E"
          firefox_highlight="#E5E9F0"
          firefox_border="#4C566A"
          vscodium_theme="Default Dark+"
          vscodium_bg="#2E3440"
          vscodium_fg="#D8DEE9"
          vscodium_sbar="#3B4252"
          vscodium_tab="#3B4252"
          vscodium_activity="#3B4252"
          vscodium_selection="#88C0D0"
          vscodium_hover="#434C5E"
          emacs_theme="nord"
          ;;
        gruvbox)
          foot_bg="fbf1c7"
          foot_fg="3c3836"
          foot_regular0="fbf1c7"
          foot_regular1="cc241d"
          foot_regular2="98971a"
          foot_regular3="d79921"
          foot_regular4="458588"
          foot_regular5="b16286"
          foot_regular6="689d6a"
          foot_regular7="3c3836"
          foot_bright0="f9f5d7"
          foot_bright1="fb4934"
          foot_bright2="b8bb26"
          foot_bright3="fabd2f"
          foot_bright4="83a598"
          foot_bright5="d3869b"
          foot_bright6="8ec07c"
          foot_bright7="282828"
          btop_theme="gruvbox"
          firefox_surface="#FBF1C7"
          firefox_foreground="#3C3836"
          firefox_panel="#F5E8B5"
          firefox_accent="#B57614"
          firefox_widget="#E6D3A0"
          firefox_highlight="#3C3836"
          firefox_border="#D5C4A1"
          vscodium_theme="Default Light+"
          vscodium_bg="#FBF1C7"
          vscodium_fg="#3C3836"
          vscodium_sbar="#F5E8B5"
          vscodium_tab="#F5E8B5"
          vscodium_activity="#F5E8B5"
          vscodium_selection="#B57614"
          vscodium_hover="#E6D3A0"
          emacs_theme="gruvbox-light"
          ;;
        *)
          echo "Unsupported theme: $theme" >&2
          exit 1
          ;;
      esac

      mkdir -p "$HOME/.config/foot" "$HOME/.config/btop" "$HOME/.config/VSCodium/User" "$HOME/.mozilla/firefox"

      cat > "$HOME/.config/foot/foot.ini" <<FOOT
[main]
font=JetBrainsMono Nerd Font:size=11
term=xterm-256color
dpi-aware=yes
initial-window-size-pixels=1280x720
initial-window-mode=windowed
pad=8x8

[colors-$( [ "$theme" = "gruvbox" ] && echo light || echo dark )]
alpha=1.0
foreground=$foot_fg
background=$foot_bg
regular0=$foot_regular0
regular1=$foot_regular1
regular2=$foot_regular2
regular3=$foot_regular3
regular4=$foot_regular4
regular5=$foot_regular5
regular6=$foot_regular6
regular7=$foot_regular7
bright0=$foot_bright0
bright1=$foot_bright1
bright2=$foot_bright2
bright3=$foot_bright3
bright4=$foot_bright4
bright5=$foot_bright5
bright6=$foot_bright6
bright7=$foot_bright7

[mouse]
hide-when-typing=yes
FOOT

      cat > "$HOME/.config/btop/btop.conf" <<BTOP
color_theme = "$btop_theme"
theme_background = False
truecolor = True
force_tty = False
prefer_codec = "UTF-8"
vim_keys = False
update_ms = 250
show_cpu_freq = True
show_memory_graph = True
show_swap_graph = True
show_disks = True
show_battery = True
show_network = True
show_proc_command = True
show_uptime = True
show_system = True
show_mem = True
show_gpu = False
show_program_path = True
show_legend = True
show_time = True
proc_sorting = "cpu_usage"
rounded_corners = True
log_level = "WARNING"
BTOP

      profile_dir="$(find "$HOME/.mozilla/firefox" -maxdepth 2 -type d \( -name '*.default*' -o -name '*.default-release*' \) 2>/dev/null | head -n 1 || true)"
      if [ -n "''${profile_dir:-}" ] && [ -d "$profile_dir" ]; then
        mkdir -p "$profile_dir/chrome"
        cat > "$profile_dir/chrome/userChrome.css" <<CSS
:root {
  color-scheme: light dark;
  --theme-surface: $firefox_surface;
  --theme-foreground: $firefox_foreground;
  --theme-panel: $firefox_panel;
  --theme-accent: $firefox_accent;
  --theme-widget: $firefox_widget;
  --theme-highlight: $firefox_highlight;
  --theme-border: $firefox_border;
}

@media (prefers-color-scheme: light) {
  :root {
    --theme-surface: $firefox_surface;
    --theme-foreground: $firefox_foreground;
    --theme-panel: $firefox_panel;
    --theme-accent: $firefox_accent;
    --theme-widget: $firefox_widget;
    --theme-highlight: $firefox_highlight;
    --theme-border: $firefox_border;
  }
}

#main-window,
#appcontent > #content,
#tabbrowser-tabpanels,
browser,
browser[type="content-primary"],
browser[type="content"] {
  background: var(--theme-surface) !important;
}

#navigator-toolbox,
#TabsToolbar,
#nav-bar,
#PersonalToolbar,
#urlbar-background,
#searchbar {
  background-color: var(--theme-surface) !important;
  color: var(--theme-foreground) !important;
  border-color: var(--theme-accent) !important;
}

.toolbarbutton-1,
.tab-background,
.tabbrowser-tab[selected="true"] .tab-background,
.tabbrowser-tab:hover .tab-background,
menupopup,
panel,
#context-navigation,
#context-sep-navigation {
  background: var(--theme-panel) !important;
  color: var(--theme-foreground) !important;
}

#urlbar:not([focused="true"]) .urlbar-input-box,
#urlbar[focused="true"] .urlbar-input-box {
  color: var(--theme-foreground) !important;
}

#titlebar-buttonbox-container,
#titlebar-min,
#titlebar-max,
#titlebar-close {
  display: none !important;
}
CSS
      fi

      write_vscodium_settings() {
        local settings_path="$1"
        cat > "$settings_path" <<JSON
{
  "window.autoDetectColorScheme": true,
  "window.titleBarStyle": "custom",
  "chat.disableAIFeatures": false,
  "workbench.colorTheme": "$vscodium_theme",
  "workbench.preferredDarkColorTheme": "Default Dark+",
  "workbench.preferredLightColorTheme": "Default Light+",
  "workbench.colorCustomizations": {
    "[Default Dark+]": {
      "editor.background": "$vscodium_bg",
      "editor.foreground": "$vscodium_fg",
      "sideBar.background": "$vscodium_bg",
      "sideBar.foreground": "$vscodium_fg",
      "activityBar.background": "$vscodium_activity",
      "activityBar.foreground": "$vscodium_fg",
      "titleBar.activeBackground": "$vscodium_bg",
      "titleBar.activeForeground": "$vscodium_fg",
      "tab.activeBackground": "$vscodium_tab",
      "tab.activeForeground": "$vscodium_fg",
      "tab.inactiveBackground": "$vscodium_bg",
      "tab.inactiveForeground": "$vscodium_selection",
      "editorGroupHeader.tabsBackground": "$vscodium_bg",
      "statusBar.background": "$vscodium_sbar",
      "statusBar.foreground": "$vscodium_fg",
      "list.activeSelectionBackground": "$vscodium_selection",
      "list.activeSelectionForeground": "$vscodium_bg",
      "list.hoverBackground": "$vscodium_hover",
      "scrollbarSlider.background": "$vscodium_bg",
      "scrollbarSlider.hoverBackground": "$vscodium_selection"
    },
    "[Default Light+]": {
      "editor.background": "$vscodium_bg",
      "editor.foreground": "$vscodium_fg",
      "sideBar.background": "$vscodium_bg",
      "sideBar.foreground": "$vscodium_fg",
      "activityBar.background": "$vscodium_activity",
      "activityBar.foreground": "$vscodium_fg",
      "titleBar.activeBackground": "$vscodium_bg",
      "titleBar.activeForeground": "$vscodium_fg",
      "tab.activeBackground": "$vscodium_tab",
      "tab.activeForeground": "$vscodium_fg",
      "tab.inactiveBackground": "$vscodium_bg",
      "tab.inactiveForeground": "$vscodium_selection",
      "editorGroupHeader.tabsBackground": "$vscodium_bg",
      "statusBar.background": "$vscodium_sbar",
      "statusBar.foreground": "$vscodium_fg",
      "list.activeSelectionBackground": "$vscodium_selection",
      "list.activeSelectionForeground": "$vscodium_bg",
      "list.hoverBackground": "$vscodium_hover",
      "scrollbarSlider.background": "$vscodium_bg",
      "scrollbarSlider.hoverBackground": "$vscodium_selection"
    }
  }
}
JSON
      }

      if [ -d "$HOME/.config/VSCodium/User" ]; then
        write_vscodium_settings "$HOME/.config/VSCodium/User/settings.json"
      fi

      if [ -d "$HOME/.config/VSCodium/User/profiles/default" ]; then
        write_vscodium_settings "$HOME/.config/VSCodium/User/profiles/default/settings.json"
      fi

      mkdir -p "$HOME/.local/state/theme"
      printf '%s\n' "$emacs_theme" > "$HOME/.local/state/theme/current-theme"
      printf '%s\n' "$theme" > "$HOME/.local/state/theme/current-ui-theme"

      if command -v emacsclient >/dev/null 2>&1; then
        emacsclient -e "(progn (dolist (theme custom-enabled-themes) (disable-theme theme)) (load-theme (intern \"$emacs_theme\") t))" >/dev/null 2>&1 || true
      fi
    '';
  };
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

    plugin = ${pkgs.hyprlandPlugins.hy3}/lib/libhy3.so

    $terminal = ${pkgs.foot}/bin/footclient

    bind = $mod, Return, exec, $terminal
    bind = $mod, Q, killactive
    bind = $mod SHIFT, Q, exit
    bind = $mod, F, fullscreen
    bind = $mod, Space, togglefloating
    bind = $mod, left, movewindow, l
    bind = $mod, right, movewindow, r
    bind = $mod, up, movewindow, u
    bind = $mod, down, movewindow, d
    #bind = $mod SHIFT, Space, togglesplit
    #bind = $mod, W, toggletab
    bind = CTRL, W, hy3:changegroup, toggletab
    bind = $mod, D, exec, ${qs}/bin/qs ipc call shell toggleLauncher
    bind = $mod, X, exec, ${qs}/bin/qs ipc call shell toggleBar
    bind = $mod, T, exec, ${qs}/bin/qs ipc call shell toggleThemePicker
    bind = $mod, L, exec, ${pkgs.hyprlock}/bin/hyprlock
    exec-once = ${qs}/bin/qs
    exec-once = ${pkgs.foot}/bin/foot --server

    # deprecated.
    #windowrulev2 = workspace 2 silent, class:^(firefox|Firefox)$
    #windowrulev2 = workspace 3 silent, class:^(emacs|Emacs)$
    #windowrulev2 = workspace 3 silent, class:^(codium|VSCodium)$
    #windowrulev2 = workspace 4 silent, class:^(spotify|Spotify)$

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

    environment.sessionVariables = {
      XCURSOR_THEME = "Bibata-Modern-Ice";
      XCURSOR_SIZE = "24";
    };

    services.xserver.enable = false;
    services.xserver.desktopManager.xterm.enable = false;
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

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
      config = {
        common.default = [ "gtk" ];
        hyprland = {
          default = [ "gtk" ];
          "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
          "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
          "org.freedesktop.impl.portal.RemoteDesktop" = [ "hyprland" ];
        };
      };
    };

    environment.systemPackages = [
      pkgs.bibata-cursors
      pkgs.gsettings-desktop-schemas
      pkgs.xdg-utils
      pkgs.ffmpeg
      pkgs.mpv
      qs
      applyUiTheme
      pkgs.foot
      pkgs.cloc
      pkgs.gimp
      pkgs.hyprlock
      pkgs.spotify
    ];
  };
}
