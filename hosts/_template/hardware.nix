{ ... }:
{
  # Replace these with values from `nixos-generate-config` or nixos-facter
  # on the target machine.
  hardware.enableRedistributableFirmware = true;

  boot.initrd.availableKernelModules = [
    "nvme"
    "sd_mod"
    "usbhid"
    "usb_storage"
    "xhci_pci"
  ];
}
