# DESTRUCTIVE: this layout erases /dev/disk/by-id/nvme-INTEL_SSDPEKNU010TZ_PHKA121201T41P0B.
# It is intended only for installing NixOS.
{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-INTEL_SSDPEKNU010TZ_PHKA121201T41P0B";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptroot";
            settings.allowDiscards = true;
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "@root" = {
                  mountpoint = "/";
                  mountOptions = [
                    "compress=zstd:3"
                    "discard=async"
                    "noatime"
                    "ssd"
                  ];
                };
                "@persist" = {
                  mountpoint = "/persist";
                  mountOptions = [
                    "compress=zstd:3"
                    "discard=async"
                    "noatime"
                    "ssd"
                  ];
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd:3"
                    "discard=async"
                    "noatime"
                    "ssd"
                  ];
                };
                "@volatile" = {
                  mountpoint = "/volatile";
                  mountOptions = [
                    "compress=zstd:3"
                    "discard=async"
                    "noatime"
                    "ssd"
                  ];
                };
              };
            };
          };
        };
      };
    };
  };
}
