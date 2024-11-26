from netmiko import ConnectHandler

# Konfigurasi perangkat Cisco
cisco_device = {
    "device_type": "cisco_ios",
    "ip": "192.168.6.2",  # IP Cisco sesuai topologi
    "username": "",        # Kosong karena tidak pakai autentikasi
    "password": "",        # Kosong karena tidak ada password
    "secret": "",          # Kosong karena tidak ada 'enable password'
}

try:
    print("Menghubungkan ke Cisco Switch...")
    connection = ConnectHandler(**cisco_device)
    connection.enable()  # Masuk mode enable (tidak perlu password kalau kosong)
    
    print("Mengonfigurasi VLAN 10...")
    connection.send_config_set([
        "vlan 10",
        "name VLAN10",
        "interface e0/0",
        "switchport trunk encapsulation dot1q"
        "switchport mode trunk",
        "interface e0/1",
        "switchport mode access",
        "switchport access vlan 10",
    ])
    
    print("Menyimpan konfigurasi...")
    connection.send_command("write memory")
    
    print("Konfigurasi selesai!")
    connection.disconnect()
except Exception as e:
    print(f"Error: {e}")
