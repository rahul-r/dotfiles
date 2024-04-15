# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "xhci_pci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/7f0ddf4e-cb0c-4881-8e97-dd85250c92e4";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  #fileSystems."/home" =
  #  { device = "/dev/disk/by-uuid/7f0ddf4e-cb0c-4881-8e97-dd85250c92e4";
  #    fsType = "btrfs";
  #    options = [ "subvol=home" ];
  #  };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/765b2210-df32-44d8-9ffd-c22fcd576ba7";
      fsType = "btrfs";
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/7f0ddf4e-cb0c-4881-8e97-dd85250c92e4";
      fsType = "btrfs";
      options = [ "subvol=nix" "noatime" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/0F03-BFE2";
      fsType = "vfat";
    };

  swapDevices = [ { device = "/swap/swapfile"; } ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
