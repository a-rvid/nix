{ config, lib, ... }:
{
  config = lib.mkIf config.my.secrets.enable {
    sops.defaultSopsFile = ../../secrets/networkmanager.yaml;
    sops.age.sshKeyPaths = [
      (
        if config.my.preservation.enable then
          "/persist/home/${config.my.username}/.ssh/id_ed25519"
        else
          "/home/${config.my.username}/.ssh/id_ed25519"
      )
    ];
    sops.secrets.user-password-hash = {
      key = "userPasswordHash";
      neededForUsers = true;
    };

    users.users.${config.my.username}.hashedPasswordFile = config.sops.secrets.user-password-hash.path;
  };
}
