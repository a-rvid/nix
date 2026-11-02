{ ... }:
{
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;
  hardware.bluetooth.enable = true;

  boot.initrd.availableKernelModules = [
    "nvme"
    "rtsx_pci_sdmmc"
    "sd_mod"
    "usb_storage"
    "usbhid"
    "xhci_pci"
  ];

  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" ];

  # NVIDIA PRIME bus IDs, open modules, modesetting, dynamic boost and asusd
  # come from nixos-hardware.nixosModules.asus-zephyrus-ga401.
}
