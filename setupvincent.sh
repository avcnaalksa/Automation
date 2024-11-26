#!/bin/bash

# Memulai konfigurasi Ubuntu DHCP Server dan VLAN
echo "Konfigurasi Ubuntu DHCP Server dan NAT dimulai..."

# 1. Update Repository
cat <<EOF | sudo tee /etc/apt/sources.list
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-updates main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-security main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-backports main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-proposed main restricted universe multiverse
EOF
sudo apt update -y

# 2. Konfigurasi Network (Netplan)
cat <<EOT | sudo tee /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: yes
    eth1:
      dhcp4: no
  vlans:
    eth1.10:
      id: 10
      link: eth1
      addresses:
        - 192.168.6.1/24
EOT
sudo netplan apply

# 3. Instalasi ISC DHCP Server
sudo apt install isc-dhcp-server -y

# 4. Konfigurasi DHCP Server
cat <<EOF | sudo tee /etc/dhcp/dhcpd.conf
subnet 192.168.6.0 netmask 255.255.255.0 {
  range 192.168.6.2 192.168.6.254;
  option domain-name-servers 8.8.8.8;
  option subnet-mask 255.255.255.0;
  option routers 192.168.6.1;
  option broadcast-address 192.168.6.255;
  default-lease-time 600;
  max-lease-time 7200;
}
EOF

# 5. Aktifkan DHCP untuk VLAN
echo 'INTERFACESv4="eth1.10"' | sudo tee /etc/default/isc-dhcp-server
sudo systemctl restart isc-dhcp-server

# 6. Aktifkan IP Forwarding dan NAT Masquerading
sudo sed -i '/^#net.ipv4.ip_forward=1/s/^#//' /etc/sysctl.conf
sudo sysctl -p
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo apt install iptables-persistent -y

echo "Konfigurasi Ubuntu selesai!"
