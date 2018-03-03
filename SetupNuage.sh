#!/bin/bash


Clear
gotoxy 1 7


echo "Configuration du Nuage :"
echo "os-release:"
source /etc/os-release

DistribCMD["Arch Linux"]="sudo pacman --noconfirm -S nfs-utils"
DistribCMD[1]="Debian"
DistribCMD[2]="Ubuntu"
DistribCMD[3]="Fedora"
DistribCMD[4]="Fedora"

echo "Répertoire /Nuage :"
[ -d /Nuage ] || sudo mkdir -p /Nuage/A /Nuage/B
echo "Vérification du package nfs :"


#Ubuntu* Debian*
# dpkg -s nfs-client 2>/dev/null >/dev/null || sudo apt-get -y install nfs-client

#Fedora*
#if rpm -q nfs-utils
#then
#   echo " nfs est installé"
#else
#    sudo yum install nfs-utils
#fi

# Archlinux:
x=`pacman -Qs nfs-utils`
[ -z "$x" ] && ${DistribCMD[$Name]} || printf " nfs-utils est déjà installé :)\n\n"

sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager

printf " Delais intentionnel de 2 secondes...\n"
sleep 2

sudo mount -t nfs 192.168.2.62:/nfs/bretzelus /Nuage/A
sudo mount -t nfs 192.168.2.62:/nfs/Public /Nuage/B
sudo cp  /Nuage/A/Linux/Arch-Linux-Stuff/PostInstal/nfs.sh /etc/NetworkManager/dispatcher.d
sudo echo "192.168.2.62       WD.Nuage        Nuage" >> /etc/hosts

echo "Terminé. Appuyer sur [ENTER] pour retourner au menu."
