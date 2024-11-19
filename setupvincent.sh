#!/bin/bash

# Fungsi cetak teks di tengah layar
print_center() {
  termwidth=$(tput cols)
  padding=$(printf '%0.1s' " "{1..500})
  while IFS= read -r line; do
    printf '%*.*s%s\n' 0 $(((termwidth - ${#line}) / 2)) "$padding" "$line"
  done <<< "$1"
}

# ASCII Art
ascii_art="\

░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓███████▓▒░ ░▒▓██████▓▒░░▒▓████████▓▒░▒▓███████▓▒░▒▓████████▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░     
 ░▒▓█▓▒▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░     
 ░▒▓█▓▒▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓██████▓▒░ ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░     
  ░▒▓█▓▓█▓▒░ ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░     
  ░▒▓█▓▓█▓▒░ ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░     
   ░▒▓██▓▒░  ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░     
                                                                                     
                                                                                     


"

# Clear screen and display ASCII art
clear
print_center "$ascii_art"
print_center "           TAMPIL KECE WAKKKK! 😹              "
print_center "+-------------------------------------------+"
print_center "|         CONFIGURE UBUNTU 20.04            |"
print_center "|       DHCP + VLAN + NAT + Kartolo         |"
print_center "+-------------------------------------------+"
print_center ""

echo "Halo Vincent! Siap setup Ubuntu gaya hacker elite? Let's go! 😹"

# Pastikan skrip dijalankan dengan sudo
if [[ $EUID -ne 0 ]]; then
   echo "Jalankan skrip ini sebagai root atau dengan sudo. 😹"
   exit 1
fi

# Variabel
VLAN_INTERFACE="eth1.10"
VLAN_ID=10
IP_ADDR="192.168.6.1/24"
DHCP_CONF="/etc/dhcp/dhcpd.conf"

# Konfigurasi Interface VLAN
echo "Konfigurasi interface VLAN $VLAN_INTERFACE... 😹"
cat <<EOL >> /etc/network/interfaces
auto eth1
iface eth1 inet manual

auto $VLAN_INTERFACE
iface $VLAN_INTERFACE inet static
  address 192.168.6.1
  netmask 255.255.255.0
  vlan-raw-device eth1
EOL
ifup eth1
ifup $VLAN_INTERFACE

# Install DHCP dan Dependencies
echo "Menginstal DHCP server dan dependencies... 😹"
apt update
apt install -y isc-dhcp-server iptables iptables-persistent

# Konfigurasi DHCP Server
echo "Konfigurasi DHCP server untuk $VLAN_INTERFACE... 😹"
cat <<EOT > $DHCP_CONF
subnet 192.168.6.0 netmask 255.255.255.0 {
    range 192.168.6.50 192.168.6.100;
    option routers 192.168.6.1;
    option domain-name-servers 8.8.8.8, 8.8.4.4;
}
EOT

# Update default DHCP interface
sed -i 's/INTERFACESv4=""/INTERFACESv4="eth1.10"/' /etc/default/isc-dhcp-server

# Aktifkan IP Forwarding
echo "Mengaktifkan IP forwarding... 😹"
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf

# Konfigurasi NAT
echo "Konfigurasi NAT untuk akses internet... 😹"
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables-save > /etc/iptables/rules.v4

# Tambahkan Kartolo Repo
echo "Menambahkan repositori Kartolo... 😹"
cat <<EOF > /etc/apt/sources.list.d/kartolo.list
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-updates main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-security main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-backports main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-proposed main restricted universe multiverse
EOF

apt update

# Restart layanan jaringan dan DHCP
echo "Restart layanan jaringan dan DHCP server... 😹"
systemctl restart networking
systemctl restart isc-dhcp-server

# Tes konektivitas
echo "Menguji konektivitas ke 8.8.8.8... 😹"
if ping -c 3 8.8.8.8 &>/dev/null; then
    echo "Ping sukses! Jaringan sudah siap dipakai 😹"
else
    echo "Ping gagal! Periksa konfigurasi jaringan 😹"
fi

echo "Konfigurasi selesai, lek Vincent! Sekarang siap tempur! 😹"
