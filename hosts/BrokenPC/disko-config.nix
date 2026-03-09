{ ... }: {
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            swap = {
              priority = 1;
              size = "32G";
              content = {
                type = "swap";
                discardPolicy = "both";
              };
            };
            root = {
              priority = 2;
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
            ESP = {
              priority = 3;
              size = "2G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "fmask=0077" "dmask=0077" ];
              };
            };
          };
        };
      };
    };
  };
}
