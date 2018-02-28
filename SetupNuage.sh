#!/bin/sh
echo "Configuration du Nuage :"
sudo mkdir -p /Nuage/A /Nuage/B
sudo pacman -S nfs-utils
sudo mount -t nfs 192.168.2.62:/nfs/bretzelus /Nuage/A
sudo mount -t nfs 192.168.2.62:/nfs/Public /Nuage/B
sudo cp  /Nuage/A/Linux/Arch-Linux-Stuff/PostInstal/nfs.sh /etc/NetworkManager/dispatcher.d

sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager

