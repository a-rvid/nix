{ lib, ... }:
{
  options.my = {
    stateVersion = lib.mkOption {
      type = lib.types.str;
      default = "26.05";
      description = "NixOS state version for this host.";
    };

    profile = {
      userName = lib.mkOption {
        type = lib.types.str;
        default = "user";
        description = "Primary user account name.";
      };

      fullName = lib.mkOption {
        type = lib.types.str;
        default = "User";
        description = "Primary user account full name.";
      };
    };

    locale = {
      uiLocale = lib.mkOption {
        type = lib.types.str;
        default = "en_US.UTF-8";
        description = "UI locale used by defaultLocale.";
      };

      formatsLocale = lib.mkOption {
        type = lib.types.str;
        default = "sv_SE.UTF-8";
        description = "Locale used for date/time/number formatting.";
      };

      timeZone = lib.mkOption {
        type = lib.types.str;
        default = "Europe/Stockholm";
        description = "System time zone.";
      };

      keymap = {
        xkbLayout = lib.mkOption {
          type = lib.types.str;
          default = "se";
          description = "XKB layout for desktop sessions.";
        };

        consoleKeyMap = lib.mkOption {
          type = lib.types.str;
          default = "sv-latin1";
          description = "Console keymap.";
        };
      };
    };

    desktop = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the desktop stack.";
      };

      greeter = lib.mkOption {
        type = lib.types.enum [ "sddm" ];
        default = "sddm";
        description = "Display manager to use when desktop is enabled.";
      };

      session = {
        compositor = lib.mkOption {
          type = lib.types.enum [ "swayfx" ];
          default = "swayfx";
          description = "Compositor backend.";
        };

        shell = lib.mkOption {
          type = lib.types.enum [ "quickshell" ];
          default = "quickshell";
          description = "Shell layer implementation.";
        };

        animationDurationMs = lib.mkOption {
          type = lib.types.ints.positive;
          default = 250;
          description = "SwayFX animation duration in milliseconds.";
        };
      };
    };

    features = {
      gaming.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable gaming stack and persistence entries.";
      };

      development.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable development tooling and persistence entries.";
      };

      spotify.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Spotify client and persistence entries.";
      };
    };

    browser = {
      librewolf.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable LibreWolf through the Firefox policies module.";
      };

      disableNova = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Force-disable browser.nova.enabled when supported.";
      };
    };

    persistence.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable impermanence/preservation behavior.";
    };

    hardware = {
      nvidiaLaptop.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable NVIDIA laptop tuning.";
      };
    };
  };
}
