#!/bin/bash

# Fungsi cetak teks di tengah layar
print_center() {
  termwidth=$(tput cols)
  padding=$(printf '%0.1s' " "{1..500})
  while IFS= read -r line; do
    printf '%*.*s%s\n' 0 $(((termwidth - ${#line}) / 2)) "$padding" "$line"
  done <<< "$1"
}

# ASCII Art dari input
ascii_art="
____   ___.__                            __   
\\   \\ /   |__| ____   ____  ____   _____/  |_ 
 \\   Y   /|  |/    \\_/ ____/ __ \\ /    \\   __\\
  \\     / |  |   |  \\  \\__\\  ___/|   |  |  |  
   \\___/  |__|___|  /\\___  \\___  |___|  |__|  
                  \\/     \\/    \\/     \\/      
"

# Clear screen and display ASCII art
clear
print_center "$ascii_art"
print_center "           TAMPIL KECE 😹 VINCENT              "
print_center "+-------------------------------------------+"
print_center "|            CONFIGURE UBUNTU 20.04         |"
print_center "|       DHCP + VLAN + NAT + Kartolo         |"
print_center "+-------------------------------------------+"
print_center ""

echo "Halo Vincent! Siap setup Ubuntu gaya hacker elite? Let's go! 😹"

# Pastikan skrip dijalankan dengan sudo
if [[ $EUID -ne 0 ]]; then
   echo "Jalankan skrip ini sebagai root atau dengan sudo. 😹"
   exit 1
fi

# Config IP, VLAN, dan lain-lain
echo "Mengkonfigurasi IP, VLAN, lan nambah Kartolo Repo kanggo Ubuntu 20.04... 😹"

# Konfigurasi jaringan
echo "
auto eth1
iface eth1 inet static
address 192.168.6.1
netmask 255.255.255.0
" >> /etc/network/interfaces

echo "
auto eth1.10
iface eth1.10 inet static
address 192.168.6.1
netmask 255.255.255.0
vlan-raw-device eth1
" >> /etc/network/interfaces

# Install DHCP server
echo "Menginstal DHCP server... 😹"
apt update
apt install -y isc-dhcp-server

cat <<EOT > /etc/dhcp/dhcpd.conf
subnet 192.168.6.0 netmask 255.255.255.0 {
    range 192.168.6.50 192.168.6.100;
    option routers 192.168.6.1;
    option domain-name-servers 8.8.8.8, 8.8.4.4;

    # Konfigurasi fix IP untuk VPC Fantasia
    host fantasia {
        hardware ethernet 00:11:22:33:44:55; # Ganti dengan MAC address
        fixed-address 192.168.6.10;
    }
}
EOT

# DHCP server untuk eth1
sed -i 's/INTERFACESv4=""/INTERFACESv4="eth1"/' /etc/default/isc-dhcp-server

# Forwarding dan NAT
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables-save > /etc/iptables/rules.v4

# Tambahkan Kartolo repo
echo "Nambah Kartolo Repo... 😹"
cat <<EOF >> /etc/apt/sources.list
# Kartolo Repo untuk Ubuntu 20.04
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-updates main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-security main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-backports main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-proposed main restricted universe multiverse
EOF

# Update sistem
echo "Update sistem nganggo repo Kartolo... 😹"
apt update

# Restart layanan
echo "Restarting networking dan DHCP services... 😹"
systemctl restart networking
systemctl restart isc-dhcp-server

echo "Konfigurasi rampung, Vincent! Sekarang jaringannya udah siap tempur! 😹"
