{ config, lib, pkgs, ... }:
{
  home.username = "user";
  home.homeDirectory = "/home/user";
  home.stateVersion = "26.05";

  home.shellAliases = {
    nh = "cd /home/user/Projects/nix && nh";
  };

  programs.nh = {
    enable = true;
    flake = "/home/user/Projects/nix";
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "a-rvid";
        email = "arvid@ndersson";
      };
      gpg = {
        format = "ssh";
      };
      commit = {
        gpgSign = true;
      };
    };
    signing = {
      key = "/home/user/.ssh/id_ed25519";
      signByDefault = true;
    };
  };

  programs.firefox = {
    enable = true;
    profiles.default = {
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.cache.disk.enable" = false;
        "browser.cache.disk.capacity" = 0;
        "browser.cache.disk.smart_size.enabled" = false;
        "browser.cache.offline.enable" = false;
      };
    };
  };

  programs.foot.enable = true;

  programs.bash = {
    enable = true;
  };

  programs.vscodium.enable = true;

  home.file.".emacs.d/init.el".source = ../home/.config/emacs/init.el;

  home.file.".config/quickshell" = {
    source = ../home/.config/quickshell;
    recursive = true;
    force = true;
  };

  xdg.configFile."btop/themes/nord.theme" = {
    source = ../home/.config/btop/themes/nord.theme;
    force = true;
  };
}
