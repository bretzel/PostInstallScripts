#!/bin/sh
cd ~
echo "Verifications: `pwd`"

TDAY=`date '+%d-%m-%Y.%Hh.%Mm.%Ss'`
Archive="h.$TDAY.tar.gz"
echo "Fichier finale de l'archive:$Archive"

echo  "Destination finale: /Nuage/A/Linux/Arch-Linux-Stuff/PostInstallScripts/$Archive"
echo "Archivage:"
tar zcvf "/Nuage/A/Linux/Arch-Linux-Stuff/PostInstallScripts/$Archive" .oh-my-zsh .zsh_favlist .zsh_history .zshrc .zsh-update .gitconfig .fonts .themes .icons .vim .vimrc > /dev/null

echo "retour:"
cd -

