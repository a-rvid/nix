{ config, lib, inputs, ... }:
let
  userName = config.my.profile.userName;
  userGroup = config.users.users.${userName}.group;
in
{
  imports = [ inputs.preservation.nixosModules.preservation ];

  config = lib.mkIf config.my.persistence.enable {
    fileSystems."/" = lib.mkForce {
      device = "none";
      fsType = "tmpfs";
      options = [
        "defaults"
        "mode=755"
        "size=50%"
      ];
    };

    fileSystems."/persist".neededForBoot = true;

    boot.tmp.useTmpfs = lib.mkForce false;

    fileSystems."/tmp" = {
      device = "/volatile/tmp";
      fsType = "none";
      options = [ "bind" ];
    };

    fileSystems."/home/${userName}/Downloads" = {
      device = "/volatile/home/${userName}/Downloads";
      fsType = "none";
      options = [ "bind" ];
    };

    systemd.services.volatile-directories = {
      description = "Prepare and clear volatile disk-backed directories";
      unitConfig.DefaultDependencies = false;
      unitConfig.RequiresMountsFor = [ "/volatile" ];
      before = [
        "local-fs.target"
        "tmp.mount"
        "home-${userName}-Downloads.mount"
      ];
      wantedBy = [ "local-fs.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        install -d -o root -g root -m 1777 /volatile/tmp
        install -d -o ${userName} -g ${userGroup} -m 0755 \
          /volatile/home/${userName}/Downloads \
          /home/${userName}/Downloads

        find /volatile/tmp -mindepth 1 -delete
        find /volatile/home/${userName}/Downloads -mindepth 1 -delete
      '';
    };

    systemd.services.systemd-machine-id-commit.enable = false;

    preservation = {
      enable = true;
      preserveAt."/persist" = {
        files = [
          {
            file = "/etc/machine-id";
            inInitrd = true;
          }
        ];

        directories = [
          {
            directory = "/var/lib/nixos";
            inInitrd = true;
          }
          "/var/lib/NetworkManager"
          "/var/lib/bluetooth"
          "/var/lib/systemd"
          "/var/log"
        ];

        users.${userName}.directories = [
          {
            directory = ".ssh";
            mode = "0700";
          }
          {
            directory = ".local/share/keyrings";
            mode = "0700";
          }
          {
            directory = ".local/state/theme";
            mode = "0700";
          }
          {
            directory = ".local/state/theme/generated";
            mode = "0700";
          }
        ]
        ++ lib.optionals config.my.desktop.enable [
          ".config/mozilla"
          ".config/librewolf"
          ".bash_history"
          ".config/VSCodium"
          ".vscode-oss"
          ".local/state/VSCodium"
          "Projects"
          "Documents"
          "Pictures"
          "Videos"
          "Music"
        ]
        ++ lib.optionals config.my.features.development.enable [
          ".emacs.d"
        ]
        ++ lib.optionals config.my.features.spotify.enable [
          ".config/spotify"
          ".cache/spotify"
        ]
        ++ lib.optionals config.my.features.gaming.enable [
          ".local/share/Steam"
          ".steam"
        ];
      };
    };
  };
}
