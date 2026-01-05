{ ... }: {
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST9250320AS_5SW1VK4F";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
            };
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
      data1 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WD800BEVS-22RST0_WD-WXC907053724";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "tank-80gb";
              };
            };
          };
        };
      };
      data2 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WD800JD-19MSA1_WD-WMAM9R024946";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "tank-80gb";
              };
            };
          };
        };
      };
    };
    zpool = {
      tank-80gb = {
        type = "zpool";
        mode = "mirror";
        mountpoint = "/mnt/tank-80gb";
        mountOptions = [ "nofail" ];
      };
    };
  };
}
