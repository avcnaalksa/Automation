#!/bin/bash

# Warna untuk output
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
CYAN='\033[36m'
RESET='\033[0m'

# ASCII Art
ascii_art="\

____   ____.__                            __   
\   \ /   /|__| ____   ____  ____   _____/  |_ 
 \   Y   / |  |/    \_/ ___\/ __ \ /    \   __\
  \     /  |  |   |  \  \__\  ___/|   |  \  |  
   \___/   |__|___|  /\___  >___  >___|  /__|  
                   \/     \/    \/     \/      

"

# Tampilkan ASCII art
clear
echo -e "${CYAN}${ascii_art}${RESET}"
echo -e "${CYAN}+-------------------------------------------+${RESET}"
echo -e "${CYAN}|         FIX CONFIGURE UBUNTU 20.04        |${RESET}"
echo -e "${CYAN}|       DHCP + VLAN + NAT + Kartolo         |${RESET}"
echo -e "${CYAN}+-------------------------------------------+${RESET}"
echo ""

echo -e "${CYAN}Memulai konfigurasi ulang Ubuntu Server... 😹${RESET}"

# Update sistem dan install DHCP server
echo -e "${BLUE}Mengupdate sistem dan menginstal DHCP server... 😹${RESET}"
apt update
apt install -y isc-dhcp-server sshpass iptables iptables-persistent

# Konfigurasi DHCP
echo -e "${GREEN}Mengonfigurasi DHCP server untuk VLAN... 😹${RESET}"
cat <<EOT > /etc/dhcp/dhcpd.conf
subnet 192.168.6.0 netmask 255.255.255.0 {
    range 192.168.6.50 192.168.6.100;
    option routers 192.168.6.1;
    option domain-name-servers 8.8.8.8, 8.8.4.4;
}
EOT

# Pastikan interface DHCP sudah disesuaikan
echo -e "${YELLOW}Mengatur interface untuk DHCP... 😹${RESET}"
cat <<EOT > /etc/default/isc-dhcp-server
INTERFACESv4="eth1" # Pastikan eth1 sesuai dengan VLAN interface
INTERFACESv6=""
EOT

# Aktifkan forwarding dan NAT
echo -e "${CYAN}Mengaktifkan IP forwarding dan NAT... 😹${RESET}"
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables-save > /etc/iptables/rules.v4

# Restart layanan DHCP
echo -e "${GREEN}Merestart layanan jaringan dan DHCP server... 😹${RESET}"
systemctl restart networking
systemctl restart isc-dhcp-server

# Cek status DHCP server
echo -e "${BLUE}Mengecek status DHCP server... 😹${RESET}"
systemctl status isc-dhcp-server

if systemctl is-active --quiet isc-dhcp-server; then
  echo -e "${GREEN}DHCP server berhasil berjalan! Semua siap tempur! 😹${RESET}"
else
  echo -e "${RED}Gagal memulai DHCP server. Silakan cek log di /var/log/syslog 😿${RESET}"
fi
