#!/bin/sh
Clear
gotoxy 1 7

source RemoteDestination.bash
question "Destination [$RemoteDestination] : Correcte ? [O|N]" 2

Resp=${REPONSE[1]}
O=${Resp^^}
Expect "O" "o"
Expected $O
O=${REPONSE[0]}

if [ $O == "NO" ] || [ -z "$O" ]; then 
    Status "Archivage annulé. Appuyer pour retourner." "OK" 
    return 1
fi

Status "Archivage confirmé. [Test terminé:] Appuyer pour retourner." "OK" 
return 0


cd ~
echo "Verifications: `pwd`"

TDAY=`date '+%d-%m-%Y.%Hh.%Mm.%Ss'`
Archive="home.$TDAY.tar.gz"
echo "Fichier finale de l'archive:$Archive"

echo  "Destination finale: /Nuage/A/Linux/Arch-Linux-Stuff/PostInstallScripts/$Archive"
echo "Archivage:"
printf "Compression dans $RemoteDestination...\n"

tar zcf "/Nuage/A/Linux/Arch-Linux-Stuff/PostInstallScripts/$Archive" applications/src Projects Repositories Public Pictures Images Documents Downloads .oh-my-zsh .zsh_favlist .zsh_history .zshrc .zsh-update .gitconfig .fonts .themes .icons .SpaceVim .SpaceVim.d .bash_it .bashrc

Status "Archivage des données et configurations usager " "OK"
cd -
Done "terminé.\n" "OK"

