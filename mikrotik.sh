#!/bin/bash

# IP dan port MikroTik
MT_IP="192.168.157.200"
MT_PORT="30023"  # Port Telnet sesuai topologi

# User dan password MikroTik
MT_USER="admin"
MT_PASS=""  # Kosongkan jika default, ganti sesuai kebutuhan

# Pastikan 'expect' terinstal
command -v expect > /dev/null || {
    echo "Expect tidak ditemukan! Silakan instal dengan: sudo apt install expect"
    exit 1
}

# Konfigurasi MikroTik melalui Telnet
expect <<EOF
spawn telnet $MT_IP $MT_PORT
set timeout 20

# Login ke MikroTik
expect "Login:" { send "$MT_USER\r" }
expect {
    "Password:" { send "$MT_PASS\r" }
    ">" {}
}

# Konfigurasi MikroTik
send "/interface vlan add name=vlan10 vlan-id=10 interface=ether1\r"
send "/ip address add address=192.168.6.1/24 interface=vlan10\r"
send "/ip pool add name=dhcp_pool10 ranges=192.168.6.2-192.168.6.254\r"
send "/ip dhcp-server add name=dhcp_vlan10 interface=vlan10 address-pool=dhcp_pool10\r"
send "/ip dhcp-server network add address=192.168.6.0/24 gateway=192.168.6.1\r"
send "/ip dhcp-server enable dhcp_vlan10\r"

# Keluar dari MikroTik
send "/quit\r"
expect eof
EOF

# Cek status
[ $? -eq 0 ] && echo "Konfigurasi MikroTik berhasil!" || echo "Konfigurasi MikroTik gagal! Periksa koneksi Telnet dan ulangi."
