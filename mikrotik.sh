#!/bin/bash

# Konfigurasi MikroTik via SSH
MKT_HOST="192.168.6.3"  # IP MikroTik sesuai topologi
MKT_USER="admin"        # Default username MikroTik (tanpa password)

# Instal sshpass jika belum ada
sudo apt install sshpass -y

# Eksekusi perintah MikroTik
echo "Menghubungkan ke MikroTik dan melakukan konfigurasi..."
sshpass -p "" ssh -o StrictHostKeyChecking=no $MKT_USER@$MKT_HOST << EOF
/interface vlan
add interface=ether1 name=vlan10 vlan-id=10
/ip address
add address=192.168.6.254/24 interface=vlan10
/ip dhcp-client
add interface=ether2 disabled=no
/ip firewall nat
add chain=srcnat out-interface=ether2 action=masquerade
EOF

echo "Konfigurasi MikroTik selesai!"
