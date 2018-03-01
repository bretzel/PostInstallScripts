#!/bin/sh
Clear
gotoxy 1 7
cd ~
echo "Verifications: `pwd`"

TDAY=`date '+%d-%m-%Y.%Hh.%Mm.%Ss'`
Archive="home.$TDAY.tar.gz"
echo "Fichier finale de l'archive:$Archive"

echo  "Destination finale: /Nuage/A/Linux/Arch-Linux-Stuff/PostInstallScripts/$Archive"
echo "Archivage:"
tar zcf "/Nuage/A/Linux/Arch-Linux-Stuff/PostInstallScripts/$Archive" .oh-my-zsh .zsh_favlist .zsh_history .zshrc .zsh-update .gitconfig .fonts .themes .icons .SpaceVim .SpaceVim.d .bash_it .bashrc 

echo "retour:"
cd -

