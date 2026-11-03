{ osConfig, ... }:
let
  userName = osConfig.my.profile.userName;
  homeDir = "/home/${userName}";
in
{
  home.username = userName;
  home.homeDirectory = homeDir;
  home.stateVersion = osConfig.my.stateVersion;

  programs.home-manager.enable = true;

  programs.foot = {
    enable = osConfig.my.desktop.enable;
    server.enable = true;
    settings = {
      main.font = "JetBrainsMono Nerd Font:size=11";
      colors = {
        alpha = "0.92";
      };
    };
  };

  xdg.configFile."quickshell/shell.qml".source = ../home/.config/quickshell/shell.qml;
  xdg.configFile."quickshell/components/TopBar.qml".source = ../home/.config/quickshell/components/TopBar.qml;
  xdg.configFile."quickshell/components/Launcher.qml".source = ../home/.config/quickshell/components/Launcher.qml;
  xdg.configFile."quickshell/components/PanelCurtain.qml".source = ../home/.config/quickshell/components/PanelCurtain.qml;
  xdg.configFile."quickshell/components/Osd.qml".source = ../home/.config/quickshell/components/Osd.qml;
  xdg.configFile."quickshell/components/NotificationCurtain.qml".source = ../home/.config/quickshell/components/NotificationCurtain.qml;

  home.file.".local/state/theme/state".text = "light\n";
}
