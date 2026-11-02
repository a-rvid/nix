{ config, lib, ... }:
{
  config = lib.mkIf config.my.secrets.enable {
    sops = {
      defaultSopsFile = ../../secrets/common.yaml;
      age.keyFile = "/var/lib/sops-nix/key.txt";
    };

    # Add secrets here, for example:
    # sops.secrets.example = {
    #   owner = config.my.username;
    # };
  };
}
