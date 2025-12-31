{ config, lib, ... }:

{
  # 外部インターフェース（LAN等）でのSSHポートを閉じ、WireGuard (wg0) のみ許可する
  # ただし、救済のために 192.168.0.0/24 からの SSH は許可する
  networking.firewall.allowedTCPPorts = lib.mkForce [];
  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 22 ];

  networking.firewall.extraCommands = ''
    # Allow SSH from LAN for rescue
    iptables -A INPUT -p tcp -s 192.168.0.0/24 --dport 22 -j ACCEPT
  '';
}
