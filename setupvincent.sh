#!/bin/bash

# Variabel progres
PROGRES=("Menambahkan Repository Kartolo" "Melakukan update paket" "Mengonfigurasi netplan" "Menginstal DHCP server" \
         "Mengonfigurasi DHCP server" "Mengaktifkan IP Forwarding" "Mengonfigurasi Masquerade" \
         "Menginstal iptables-persistent" "Menyimpan konfigurasi iptables" "Menginstal Expect")
STEP=0

# Fungsi untuk menampilkan progres
function show_progress {
    STEP=$((STEP + 1))
    echo "Progres [$STEP/${#PROGRES[@]}]: ${PROGRES[STEP-1]}"
}

# Otomasi Dimulai
echo "Otomasi Dimulai"

# Menambahkan Repository Kartolo
show_progress
REPO="http://kartolo.sby.datautama.net.id/ubuntu/"
if ! grep -q "$REPO" /etc/apt/sources.list; then
    cat <<EOF | sudo tee /etc/apt/sources.list > /dev/null
deb ${REPO} focal main restricted universe multiverse
deb ${REPO} focal-updates main restricted universe multiverse
deb ${REPO} focal-security main restricted universe multiverse
deb ${REPO} focal-backports main restricted universe multiverse
deb ${REPO} focal-proposed main restricted universe multiverse
EOF
fi

# Update Paket
show_progress
sudo apt update -y

# Konfigurasi Netplan
show_progress
cat <<EOT | sudo tee /etc/netplan/01-netcfg.yaml > /dev/null
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
        - 192.168.20.1/24
EOT
sudo netplan apply

# Instalasi ISC DHCP Server
show_progress
sudo apt install -y isc-dhcp-server

# Konfigurasi DHCP Server
show_progress
sudo bash -c 'cat > /etc/dhcp/dhcpd.conf' << EOF
subnet 192.168.6.0 netmask 255.255.255.0 {
  range 192.168.6.2 192.168.20.254;
  option domain-name-servers 8.8.8.8;
  option subnet-mask 255.255.255.0;
  option routers 192.168.6.1;
  option broadcast-address 192.168.6.255;
  default-lease-time 600;
  max-lease-time 7200;
}
EOF
echo 'INTERFACESv4="eth1.10"' | sudo tee /etc/default/isc-dhcp-server > /dev/null
sudo systemctl restart isc-dhcp-server

# Aktifkan IP Forwarding
show_progress
sudo sed -i '/^#net.ipv4.ip_forward=1/s/^#//' /etc/sysctl.conf
sudo sysctl -p

# Konfigurasi Masquerade dengan iptables
show_progress
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Instalasi iptables-persistent
show_progress
sudo apt install -y iptables-persistent

# Menyimpan Konfigurasi iptables
show_progress
sudo sh -c "iptables-save > /etc/iptables/rules.v4"
sudo sh -c "ip6tables-save > /etc/iptables/rules.v6"

# Instalasi Expect
show_progress
sudo apt install -y expect

# Selesai
echo "Otomasi selesai!"
