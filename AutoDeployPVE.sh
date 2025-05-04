#!/bin/bash
#
# This script used as first-boot script. 
# It download some qcow2 images (Windows10) and Debian 11 (Cloud Init)
#

# First of all - we need to configure our PVE

echo "Removing old sources..."
rm -f /etc/apt/sources.list.d/pve-enterprise.list
rm -f /etc/apt/sources.list.d/ceph.list
rm -f /etc/apt/sources.list

echo "Adding new sources list..."
tee /etc/apt/sources.list > /dev/null <<EOF
deb http://ftp.debian.org/debian bookworm main contrib
deb http://ftp.debian.org/debian bookworm-updates main contrib

# Proxmox VE pve-no-subscription repository provided by proxmox.com,
# NOT recommended for production use
deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription

# security updates
deb http://security.debian.org/debian-security bookworm-security main contrib
EOF

echo "Updating package list..."
apt update

debconf-set-selections <<EOF
iptables-persistent iptables-persistent/autosave_v4 boolean true
iptables-persistent iptables-persistent/autosave_v6 boolean true
EOF
apt install -y iptables-persistent

# Create Virtual Bridge For VMs
cat <<EOL | tee -a /etc/network/interfaces
auto vmbr100
iface vmbr100 inet static
    address 192.168.100.1
    netmask 255.255.255.0
    bridge_ports none
EOL

echo "Restart interfaces..."
systemctl restart networking

echo "net.ipv4.ip_forward=1" | tee -a /etc/sysctl.conf
sysctl -p

echo "Configuring NAT..."
iptables -t nat -A POSTROUTING -o vmbr0 -j MASQUERADE

echo "Save iptables rules..."
iptables-save | tee /etc/iptables/rules.v4
echo "Base PVE configuration complete"

# Second - We need to get our QCOW2 Images with pre-installed base system

wget -O /var/lib/vz/images/deb11.qcow2 https://cdn.yourtld.lan/someimgdata/deb11.qcow2
wget -O /var/lib/vz/images/win10.qcow2 https://cdn.yourtld.lan/someimgdata/win10.qcow2

sleep 1m

# Create Debian Machine
qm create 100 --name ISP --memory 2048 --balloon 0 \
--cpu cputype=host --cores 2 --sockets 1 --numa 1 \
--net0 virtio,bridge=vmbr100 --bios seabios \
--scsihw virtio-scsi-single --virtio0 local-zfs:0,import-from=/var/lib/vz/images/deb11.qcow2 \
--boot c --bootdisk virtio0 --onboot 1

# Create Windows CLI Machine
qm create 200 --name CLI --bios seabios \
--ostype win10 --memory 3072 --balloon 0 \
--cpu cputype=host --cores 2 --sockets 1 --numa 1 \
--net0 e1000,bridge=vmbr100 --sata0 local-zfs:0,import-from=/var/lib/vz/images/win10.qcow2 \
--boot c --bootdisk sata0 --onboot 1


# Reboot PVE
reboot