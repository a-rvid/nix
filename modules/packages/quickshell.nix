{ pkgs }:
pkgs.writeShellApplication {
  name = "qs";
  runtimeInputs = [
    pkgs.glib
    pkgs.quickshell
  ];
  text = ''
    state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/quickshell"
    mkdir -p "$state_dir"
    exec ${pkgs.quickshell}/bin/quickshell \
      -p ${../../home/.config/quickshell}/shell.qml "$@"
  '';
}
