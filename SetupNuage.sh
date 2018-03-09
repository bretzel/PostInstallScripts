#!/bin/bash



# Archlinux:


unset NFSLIST
unset NfsCloudSH
unset Local 
unset MPE


function get_locations()
{
    X=0
    sel=0
    IP=""
    question "(Données initiales) Adresse IP du Nuage:" 16 "Point de montage racine locale:" 40
    
    IP=${REPONSE[1]}
    Local=${REPONSE[2]}

    TITRE=" Définition des points de montage NFS:"
    
    if [ ! -d $Local ]; then 
        if ! mkdir -p  $Local; then
            Erreur " Le répertoire racine de montage ne peut être créé."
            return 1
        fi
        Done " Le répertoire racine de montage a été créé." "OK"
    else 
        Done " Répertoire racine de montage existe déjà" "OK"
    fi
    
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
                return 1
            fi
        ;;
        *) break
        ;;
        esac
    done
    
    X=0
    
    for F in ${NFSLIST[@]}
    do
        Status "$F : ${MPE[$X]}" "OK"
        [ $((++X)) ]
    done
    return 0
}


get_locations
if [ $? -eq 1 ]
then
    Done "La configuration interractive a échoué" "NO"
    return 0
fi

return 

echo "#.bin/sh"                         >  NfsCloud.sh
echo " "                                >> NfsCloud.sh
echo "if [ \""\$2\"" = \"up\" ]; then"  >> NfsCloud.sh
echo " "                                >> NfsCloud.sh
X=0
for F in ${NFSLIST[@]}
do
    echo "    mount -t nfs $F  ${MPE[$X]}" >> NfsCloud.sh
    [ $((++X)) ]
done
echo " "                                >> NfsCloud.sh
X=0
echo "elif [ \""\$2\"" = \"down\" ]; then"  >> NfsCloud.sh
echo " "                                    >> NfsCloud.sh
for F in ${NFSLIST[@]}
do
    echo "    umount ${MPE[$X]}"        >> NfsCloud.sh 
    [ $((++X)) ]
done
echo " "                                >> NfsCloud.sh
echo "fi"                               >> NfsCloud.sh
echo " "                                >> NfsCloud.sh



Done "Test terminé...  Dernier test ici..." "NO"
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
