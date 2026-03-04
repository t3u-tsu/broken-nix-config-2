{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    bandwhich
    curl
    dnsutils
    lsof
    mtr
    nmap
    rsync
    tcpdump
    wget
  ];
}
