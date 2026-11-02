{ ... }:
{
  boot.tmp.useTmpfs = true;
  boot.tmp.cleanOnBoot = true;

  boot.supportedFilesystems = [
    "btrfs"
    "vfat"
    "exfat"
    "ntfs"
  ];
}
