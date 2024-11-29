#!/bin/bash

# IP dan Port Mikrotik
MKT_HOST="192.168.157.129"  # IP Mikrotik di topologi
MKT_PORT="30023"            # Port SSH Mikrotik
MKT_USER="admin"            # Default username Mikrotik
MKT_PASS=""                 # Password kosong

# Pastikan `sshpass` terinstal
command -v sshpass > /dev/null || {
  echo "sshpass tidak ditemukan. Instal dengan: sudo apt install sshpass"
  exit 1
}

# SSH ke Mikrotik dan konfigurasi
echo "Menghubungkan ke Mikrotik dan melakukan konfigurasi..."
sshpass -p "$MKT_PASS" ssh -p "$MKT_PORT" -o StrictHostKeyChecking=no $MKT_USER@$MKT_HOST << EOF
# Tambahkan VLAN 10 di interface trunk
/interface vlan
add name=vlan10 vlan-id=10 interface=ether1

# Tambahkan IP di interface VLAN 10
/ip address
add address=192.168.6.1/24 interface=vlan10

# Konfigurasi NAT untuk akses internet
/ip firewall nat
add chain=srcnat out-interface=ether1 action=masquerade

# Aktifkan DHCP Server di VLAN 10
/ip dhcp-server
add name=dhcp_vlan10 interface=vlan10 lease-time=10m
/ip pool
add name=pool_vlan10 ranges=192.168.6.2-192.168.6.254
/ip dhcp-server network
add address=192.168.6.0/24 gateway=192.168.6.1 dns-server=8.8.8.8

# Aktifkan interface trunk dan VLAN
/interface enable ether1
/interface enable vlan10

# Selesai konfigurasi
EOF

# Periksa hasil
if [ $? -eq 0 ]; then
  echo -e "\033[0;32mKonfigurasi Mikrotik berhasil!\033[0m"
else
  echo -e "\033[0;31mKonfigurasi Mikrotik gagal!\033[0m"
  exit 1
fi
