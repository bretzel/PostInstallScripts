#!/bin/sh

Clear
gotoxy 1 7

question "Êtes-vous certain de vouloir décompresser l'archive de sauvegarde dans $H ? [O/N] " 2
if [ -z ${REPONSE[1]} ]; then
    return
fi

Clear
gotoxy 1 7

echo "Désarchivage..."
pushd .
cd ~
echo "Vérification du répertoire de destination:"
H=`pwd`
echo $H

#tar xfz /Nuage/A/Linux/Arch-Linux-Stuff/PostinstallScripts/h*.gz
ls /Nuage/A/Linux/Arch-Linux-Stuff/PostInstallScripts/h*.gz
read
popd
Clear


