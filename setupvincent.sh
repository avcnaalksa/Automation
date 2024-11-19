#!/bin/bash

# Warna kanggo gaya lek
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

# Tampilkan ASCII Art
clear
echo -e "${CYAN}${ascii_art}${RESET}"
echo -e "${CYAN}+-------------------------------------------+${RESET}"
echo -e "${CYAN}|           FIX CONFIGURE UBUNTU 20.04      |${RESET}"
echo -e "${CYAN}|         DHCP + VLAN + NAT + Kartolo       |${RESET}"
echo -e "${CYAN}+-------------------------------------------+${RESET}"
echo ""

echo -e "${CYAN}Yo lek, ayo tak betulin DHCP server sing rewel iki! 😹${RESET}"

# Update sistem lan pasang DHCP server
echo -e "${BLUE}Update sistem lek... ojo mandek nang tengah dalan! 😹${RESET}"
apt update
apt install -y isc-dhcp-server sshpass iptables iptables-persistent

# Konfigurasi DHCP
echo -e "${GREEN}Yo lek, tak pasang DHCP server kanggo VLAN mu sing ngganjel! 😹${RESET}"
cat <<EOT > /etc/dhcp/dhcpd.conf
subnet 192.168.6.0 netmask 255.255.255.0 {
    range 192.168.6.50 192.168.6.100;
    option routers 192.168.6.1;
    option domain-name-servers 8.8.8.8, 8.8.4.4;
}
EOT

# Pas konfigurasi interface kanggo DHCP
echo -e "${YELLOW}Tak atur interface DHCP lek, ojo salah kabel ya! 😹${RESET}"
cat <<EOT > /etc/default/isc-dhcp-server
INTERFACESv4="eth1" # Pastikan eth1 iku interface VLAN-mu
INTERFACESv6=""
EOT

# Aktifno forwarding lan NAT
echo -e "${CYAN}Aktifno NAT lan forwarding... biar kabeh client iso browsing 💨😹${RESET}"
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables-save > /etc/iptables/rules.v4

# Restart layanan DHCP
echo -e "${GREEN}Restart DHCP server lek, nunggu dhisik yo... 🚀😹${RESET}"
systemctl restart networking
systemctl restart isc-dhcp-server

# Cek status DHCP server
echo -e "${BLUE}Ngecek status DHCP server mu lek... 😹${RESET}"
systemctl status isc-dhcp-server

if systemctl is-active --quiet isc-dhcp-server; then
  echo -e "${GREEN}MANTAP, DHCP server wes ngacir lek! Gas pol! 😹${RESET}"
else
  echo -e "${RED}Aduh lek, DHCP servermu gagal run 😿. Cek log nang /var/log/syslog!${RESET}"
fi
