{ pkgs, lib, ... }:

{
  imports = [
    ./nix.nix
    ../services/update-hub/client.nix
    ./local-network.nix
    ./time.nix
    ./wireguard.nix
  ];

  # Emergency Fix: Pin kernel version to 6.18 for all hosts to avoid unbootable issue with kernel 6.19.4 regression
  # Use mkForce to override host-specific or tower-server-specific defaults
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_18;

  # Prioritize IPv4 over IPv6 in glibc (RFC 3484/6724)
  environment.etc."gai.conf".text = ''
    precedence  ::ffff:0:0/96  100
  '';

  environment.systemPackages = with pkgs; [
    # Core CLI Utilities
    bat
    direnv
    eza
    fd
    file
    fzf
    git
    ripgrep
    tealdeer
    tmux
    vim
    which
    zoxide

    # System Monitoring & Hardware
    btop
    duf
    dust
    fastfetch
    htop
    hwinfo
    hwloc
    lm_sensors
    nvme-cli
    pciutils
    smartmontools
    usbutils

    # Networking
    bandwhich
    curl
    dnsutils
    lsof
    mtr
    nmap
    rsync
    tcpdump
    wget

    # Data & Archives
    jq
    p7zip
    unzip
    xz
    yq-go
    zip
    zstd

    # Nix Ecosystem
    nh
    nix-du
    nix-index
    nix-output-monitor
    nix-tree
    nixfmt-rfc-style

    # Security
    age
    gnupg
    sops
  ];
}