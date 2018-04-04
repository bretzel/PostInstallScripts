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
<<<<<<< HEAD
tar zcf "/Nuage/A/Linux/Arch-Linux-Stuff/PostInstallScripts/$Archive" applications/src Projects Repositories Public Pictures Documents Downloads .oh-my-zsh .zsh_favlist .zsh_history .zshrc .zsh-update .gitconfig .fonts .themes .icons .SpaceVim .SpaceVim.d .bash_it .bashrc
=======
tar zcf "/Nuage/A/Linux/Arch-Linux-Stuff/PostInstallScripts/$Archive" applications/src .oh-my-zsh .zsh_favlist .zsh_history .zshrc .zsh-update .gitconfig .fonts .themes .icons .SpaceVim .SpaceVim.d .bash_it .bashrc
>>>>>>> 7c758bddb4dc4eb1457923826ea327e326453ab7

Status "Archivage des données et configurations usager " "OK"
cd -
Done "terminé.\n"
