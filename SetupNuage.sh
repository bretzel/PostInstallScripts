#!/bin/bash


Clear
gotoxy 1 7


echo "Configuration du Nuage :"
echo "os-release:"
source /etc/os-release
echo " Nom: $Name\n"


#DistribCMD["Arch Linux"]="sudo pacman --noconfirm -S nfs-utils"
#DistribCMD[1]="Debian"
#DistribCMD[2]="Ubuntu"
#DistribCMD[3]="Fedora"
#DistribCMD[4]="Fedora"

echo "Répertoire du montage /Nuage :"
[ -d /Nuage ] || sudo mkdir -p /Nuage/A /Nuage/B
echo "Vérification du package nfs :"


#Ubuntu* Debian*
# dpkg -s nfs-client 2>/dev/null >/dev/null || sudo apt-get -y install nfs-client

#Fedora*
#if rpm -q nfs-utils
#then
#   echo " nfs est installé"
#else
##    sudo yum install nfs-utils
#fi

# Archlinux:


unset NFSLIST
unset NfsCloud
unset Local 
unset MPE

function get_locations()
{
    X=0
    sel=0
    IP=""
    question "Adresse IP (ou préfixe) du Nuage:" 16 "Point de montage racine locale:" 40
    
    IP=${REPONSE[1]}
    Local=${REPONSE[2]}

    TITRE=" Définition des points de montage NFS:"
    while [ $sel -ne 2 ]
    do
        menu "Ajouter un emplacement" Terminé
        sel=${REPONSE[0]}
        case $sel in 
        1)
            question "Donner l'emplacement:$IP:/" 40 "Monté dans le sous-dossier $Local/" 40
            if [ -n ${REPONSE[1]} ]; then
                NFSLIST[$X]="$IP:/${REPONSE[1]}"
                MPE[$X]="$Local/${REPONSE[2]}"
                [ $((++X)) ]
            else 
                Done " Ajout annulé." "NO"
                return
            fi
        ;;
        *) break
        ;;
        esac
    done
    gotoxy 1 10
#    for F in "${NsfList[@]}"
#    do
#        printf "$F\n"
#    done
    Done "Liste des points montage NFS complétée\n: --:${#NFSLIST[@]}:--:${NFSLIST[*]}:--" "OK"
    
}


get_locations
Done "Test terminé..." "NO"
return 
x=`pacman -Qs nfs-utils`
[ -z "$x" ] && sudo pacman --noconfirm -S nfs-utils || printf " Le support nfs est déjà installé :)\n\n"

question "Le service NetworkManager doit-il être activé [O;N]? (Non par déf.) " 2
if [ ${REPONSE[1]} == "O" ]; then
  sudo systemctl enable NetworkManager
  sudo systemctl start NetworkManager
  printf "Services actives. - "
  printf "Delais intentionnel de 2 secondes...\n"
  sleep 2
fi

printf "Connexion au Nuage:\n"
question "Donner l'emplacement du Nuage (NSF):" 40
sudo mount -t nfs 192.168.2.62:/nfs/bretzelus /Nuage/A 2>/dev/null
if [ $? == 0 ]; then
   printf " Nuage/A monté.\n"
   sudo mount -t nfs 192.168.2.62:/nfs/Public /Nuage/B
else
  Erreur " connexion NFS au Nuage avortée \n"
  return 1
fi

printf "Copie du script de connexion dans etc:\n"
sudo cp  nfs.sh /etc/NetworkManager/dispatcher.d/
if [ $? == 0 ]; then
  echo " Copié.\n"
else
  Erreur " Copie de nfs.sh avortée...Appuyer sur CTRL-C pour avorter le script."
  return 1
fi

printf " hosts: \n"
x=`grep "WD.Nuage" /etc/hosts`
if [ ${#x} -gt 0 ] ; then
  printf " le fichier hosts est déjà renseigné sur Nuage... \n"
else
  printf " Renseignement du Nuage dans le fichier hosts:\n"
  cp /etc/hosts .
  echo "192.168.2.62       WD.Nuage        Nuage" >> hosts
  sudo cp hosts /etc/hosts
fi

printf " Test: ping Nuage:"
ping -c 3 Nuage

Done "Terminé. Appuyer sur [ENTER] pour retourner au menu."
