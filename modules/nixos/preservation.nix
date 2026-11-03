{ config, lib, ... }:
{
  config = lib.mkIf config.my.preservation.enable {
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
    fileSystems."/home/${config.my.username}/Downloads" = {
      device = "/volatile/home/${config.my.username}/Downloads";
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
        "home-${config.my.username}-Downloads.mount"
      ];
      wantedBy = [ "local-fs.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        install -d -o root -g root -m 1777 /volatile/tmp
        install -d \
          -o ${config.my.username} \
          -g ${config.users.users.${config.my.username}.group} \
          -m 0755 \
          /volatile/home/${config.my.username}/Downloads \
          /home/${config.my.username}/Downloads
        find /volatile/tmp -mindepth 1 -delete
        find /volatile/home/${config.my.username}/Downloads -mindepth 1 -delete
      '';
    };

    systemd.services.systemd-machine-id-commit = {
      enable = false;
    };

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

        users.${config.my.username}.directories = [
          {
            directory = ".ssh";
            mode = "0700";
          }
        ]
        ++ lib.optionals config.my.desktop.enable [
          ".emacs.d"
          ".config/mozilla"
          ".config/spotify"
          ".cache/spotify"
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
        ++ lib.optionals config.my.gaming.enable [
          ".local/share/Steam"
          ".steam"
        ];
      };
    };
  };
}
