{ config, ... }: {
  mikrotik."ipv6/settings".accept-router-advertisements = true;

  mikrotik."interface/list" = {
    _table = true;
    wan = { };
    lan = { };
  };

  mikrotik."ip/neighbor/discovery-settings" = {
    _after = [ "interface/list" ];
    discover-interface-list = config.mikrotik."interface/list".lan._name;
  };

  mikrotik."interface/bridge" = {
    _table = true;
    bridge = { };
  };

  mikrotik."ip/address" = {
    _key = "comment";
    _after = [ "interface/bridge" ];
    bridge = {
      network = "192.168.88.0";
      address = "192.168.88.1/24";
      interface = config.mikrotik."interface/bridge".bridge._name;
    };
  };

  mikrotik."ipv6/address" = {
    _key = "comment";
    _after = [ "interface/bridge" ];
    bridge = {
      address = "::1";
      from-pool = "v6-dhcp-pool";
      interface = config.mikrotik."interface/bridge".bridge._name;
    };
  };

  mikrotik."interface/bridge/port" = {
    _prefix = "";
    _key = "interface";
    _after = [ "interface/bridge" ];
    ether1.bridge = config.mikrotik."interface/bridge".bridge._name;
    ether3.bridge = config.mikrotik."interface/bridge".bridge._name;
    ether4.bridge = config.mikrotik."interface/bridge".bridge._name;
    ether5.bridge = config.mikrotik."interface/bridge".bridge._name;
    ether6.bridge = config.mikrotik."interface/bridge".bridge._name;
    ether7.bridge = config.mikrotik."interface/bridge".bridge._name;
    ether8.bridge = config.mikrotik."interface/bridge".bridge._name;
    sfp-sfpplus1.bridge = config.mikrotik."interface/bridge".bridge._name;
  };

  mikrotik."ip/pool" = {
    _table = true;
    default-dhcp.ranges = "192.168.88.100-192.168.88.254";
  };

  mikrotik."ip/dhcp-server" = {
    _table = true;
    _after = [
      "ip/pool"
      "interface/bridge"
    ];
    default = {
      address-pool = config.mikrotik."ip/pool".default-dhcp._name;
      interface = config.mikrotik."interface/bridge".bridge._name;
    };
  };

  mikrotik."ip/dhcp-server/network" = {
    _key = "comment";
    _after = [
      "ip/dhcp-server"
      "ip/address"
    ];
    default = {
      address = "192.168.88.0/24";
      dns-server = "192.168.88.1";
      gateway = "192.168.88.1";
    };
  };

  mikrotik."ip/dhcp-server/lease" = {
    _key = "comment";
    _after = [ "ip/dhcp-server" ];
    ap = {
      address = "192.168.88.2";
      mac-address = "8C:30:66:60:71:EC";
      server = config.mikrotik."ip/dhcp-server".default._name;
    };
    youko = {
      address = "192.168.88.10";
      mac-address = "74:56:3C:BF:44:72";
      server = config.mikrotik."ip/dhcp-server".default._name;
    };
    youko-kvm = {
      address = "192.168.88.11";
      mac-address = "44:B7:D0:D5:58:CB";
      server = config.mikrotik."ip/dhcp-server".default._name;
    };
    reolink = {
      address = "192.168.88.20";
      mac-address = "EC:71:DB:3F:C8:8A";
      server = config.mikrotik."ip/dhcp-server".default._name;
    };
  };

  mikrotik."interface/vlan" = {
    _table = true;
    wan-vlan = {
      interface = "ether2";
      vlan-id = 35;
    };
  };

  # TODO: The config doesn't define IPv6 DHCP client because of circular dependency
  #       ppp profile needs pool -> pool needs pppoe interface -> interface needs profile -> ...

  mikrotik."ipv6/dhcp-server" = {
    _table = true;
    _after = [
      "interface/bridge"
      "interface/pppoe-client"
    ];
    dhcpv6-pd = {
      address-pool = "v6-dhcp-pool";
      interface = config.mikrotik."interface/bridge".bridge._name;
    };
  };

  mikrotik."ppp/profile" = {
    _table = true;
    default-v6 = {
      change-tcp-mss = true;
      dhcpv6-pd-pool = "v6-dhcp-pool";
    };
  };

  mikrotik."interface/pppoe-client" = {
    _table = true;
    _after = [
      "interface/vlan"
      "ppp/profile"
    ];
    pppoe-v4 = {
      add-default-route = true;
      disabled = false;
      interface = config.mikrotik."interface/vlan".wan-vlan._name;
      max-mru = 1500;
      max-mtu = 1500;
      # TODO: user and pass when secret handling is implemented
    };
    pppoe-v6 = {
      add-default-route = true;
      disabled = false;
      interface = config.mikrotik."interface/vlan".wan-vlan._name;
      max-mru = 1500;
      max-mtu = 1500;
      profile = config.mikrotik."ppp/profile".default-v6._name;
      # TODO: user and pass when secret handling is implemented
    };
  };

  mikrotik."interface/list/member" = {
    _key = "comment";
    _after = [
      "interface/bridge"
      "interface/pppoe-client"
      "interface/list"
    ];
    lan = {
      interface = config.mikrotik."interface/bridge".bridge._name;
      list = config.mikrotik."interface/list".lan._name;
    };
    wan-v4 = {
      interface = config.mikrotik."interface/pppoe-client".pppoe-v4._name;
      list = config.mikrotik."interface/list".wan._name;
    };
    wan-v6 = {
      interface = config.mikrotik."interface/pppoe-client".pppoe-v6._name;
      list = config.mikrotik."interface/list".wan._name;
    };
  };

  mikrotik."interface/ethernet" = {
    _key = "default-name";
    _managed = false;
    ether1.advertise = "1G-baseT-half,1G-baseT-full,2.5G-baseT";
    ether7.poe-out = "off";
  };

  mikrotik."ip/firewall/nat" = {
    _key = "comment";
    _after = [ "interface/pppoe-client" ];
    http = {
      action = "dst-nat";
      chain = "dstnat";
      protocol = "tcp";
      dst-port = "80,443";
      in-interface = config.mikrotik."interface/pppoe-client".pppoe-v4._name;
      to-address = "192.168.88.10";
    };
  };
  mikrotik."ipv6/firewall/filter" = {
    _key = "comment";
    http = {
      action = "accept";
      chain = "forward";
      protocol = "tcp";
      dst-port = "80,443";
      dst-address = "2a01:113f:4012:6200:6950:dfae:a58b:37e0/128";
    };
  };

  mikrotik."ip/dns" = {
    allow-remote-requests = true;
    # Quad9 upstream
    servers = "9.9.9.10,149.112.112.10";
  };
  mikrotik."ip/dns/adlist" = {
    _prefix = "";
    _key = "url";
    "https://raw.githubusercontent.com/IgorKha/mikrotik-adlist/refs/heads/main/hosts/steven_blacks_list.txt".ssl-verify =
      false;
  };

  mikrotik."ip/service" = {
    _managed = false;
    telnet.disabled = true;
    ftp.disabled = true;
    www.address = "192.168.88.0/24";
    api.disabled = true;
    winbox.disabled = true;
    api-ssl.disabled = true;
  };

  mikrotik."ip/upnp".enabled = true;
  mikrotik."ip/upnp/interfaces" = {
    _prefix = "";
    _after = [
      "interface/bridge"
      "interface/pppoe-client"
    ];
    _key = "interface";
    bridge = {
      type = "internal";
      interface = config.mikrotik."interface/bridge".bridge._name;
    };
    pppoe = {
      type = "external";
      interface = config.mikrotik."interface/pppoe-client".pppoe-v4._name;
    };
  };

  mikrotik."system/clock".time-zone-name = "Europe/Warsaw";
}
