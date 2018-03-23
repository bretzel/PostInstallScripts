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
printf "applications/src \n.oh-my-zsh \n.zsh_favlist \n.zsh_history \n.zshrc \n.zsh-update \n.gitconfig \n.fonts \n.themes \n.icons \n.SpaceVim \n.SpaceVim.d \n.bash_it \n.bashrc\n"
tar zcf "/Nuage/A/Linux/Arch-Linux-Stuff/PostInstallScripts/$Archive" applications/src .oh-my-zsh .zsh_favlist .zsh_history .zshrc .zsh-update .gitconfig .fonts .themes .icons .SpaceVim .SpaceVim.d .bash_it .bashrc

Status "Archivage des données et configurations usager " "OK"
cd -
Done "terminé.\n"
