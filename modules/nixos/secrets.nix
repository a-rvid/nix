{ config, lib, ... }:
{
  config = lib.mkIf config.my.secrets.enable {
    age.identityPaths = [
      (
        if config.my.preservation.enable then
          "/persist/home/${config.my.username}/.ssh/id_ed25519"
        else
          "/home/${config.my.username}/.ssh/id_ed25519"
      )
    ];
    age.secrets.common.file = ../../secrets/common.age;
  };
}
