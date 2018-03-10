#!/bin/bash



# Archlinux:


unset NFSLIST
unset NfsCloudSH="NasCloud.sh"
unset Local
unset IP
unset MPE
unset CloudAlias
# PKG_OK=$(dpkg-query -l nfs-client|grep "ii"); [ -z $PKG_OK  ] 
# echo Checking for somelib: $PKG_OK
# if [ "" == "$PKG_OK" ]; then
#   echo "No somelib. Setting up somelib."
#   sudo apt-get --force-yes --yes install the.package.name
#fi


function init_nfs_data()
{
    X=0
    sel=0
    IP=""
    
    if [ ! -f $NfsCloudSH ]; then
        touch $NfsCloudSH
        chmod +x $NfsCloudSH
    fi
    
    function init_root_locations()
    {
        TITRE="(Données initiales [$CL_ERR$DISTNAME$CL_WINBCK\033[38m])"
        question "Adresse IP du Nuage:" 16 "Point de montage racine locale:" 40
    
        IP=${REPONSE[1]}
        Local=${REPONSE[2]}
        if [ -z "$IP" ] || [ -z "$Local" ]; then 
            Done " Configuration du nuage avorté." "NO"
            return 1
#         elif [ -z "$Local" ]; then 
#             Done " Configuration du nuage avorté." "NO"
#             return 1
        fi
        
        question "Est-il souhaité de renseigner /etc/host ? Donner l'alias ou [ENTER] pour passer" 40
        CloudAlias=${REPONSE[1]}
        if [ -n "$CloudALias" ]; then
            echo "$IP   $CloudAlias" >>/etc/hosts
            Done "etc/hosts est renseigné." "OK"
        fi
        
        if [ ! -d $Local ]; then 
            if ! mkdir -p  $Local; then
                Erreur " Le répertoire racine de montage ne peut être créé."
                return 1
            fi
            Done " Le répertoire racine de montage a été créé." "OK"
        else 
            Done " Répertoire racine de montage existe déjà" "OK"
        fi

        return 0
    }
    
    function set_binds()
    {
        sel=0
        while [ $sel -ne 2 ]
        do
            menu "Ajouter un emplacement" Terminé
            sel=${REPONSE[0]}
            case $sel in 
            1)
                question "Donner l'emplacement:$IP:/" 40 "Monté dans le sous-dossier $Local/" 40
                if [ -n ${REPONSE[1]} ]; then
                    NFSLIST[$X]="$IP:/${REPONSE[1]}"
                    MPE[$X]="$Local/${REPONSE[2]}" # Il y a ici un fort risque de duplicat du point de montage locale...
                    if [! -d "MPE[$X]" ]           # Il faudra prévenir les duplicats dans le tableau MPE. D'ailleurs, il faut
                    then                           # faire la même chose pour le tableau NFSLIST...
                        mkdir -p MPE[$X]
                    fi
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
    
    init_root_locations
    if [ $? = 1 ]; then  return 1
    
    TITRE=" Définition des points de montage NFS:"
    
    

}


function generate_script()
{
    X=0
    printf "Génération du script montage NFS pour NetworkManager::Dispacher:\n"
    echo "#.bin/sh"                         >  NfsCloud.sh
    echo ""                                >> NfsCloud.sh
    echo "if [ \""\$2\"" = \"up\" ]; then"  >> NfsCloud.sh
    echo ""                                >> NfsCloud.sh
    X=0
    for F in ${NFSLIST[@]}
    do
        echo "    mount -t nfs $F  ${MPE[$X]}" >> NfsCloud.sh
        [ $((++X)) ]
    done
    echo ""                                >> NfsCloud.sh
   
   X=0
    echo "elif [ \""\$2\"" = \"down\" ]; then"  >> NfsCloud.sh
    echo ""                                    >> NfsCloud.sh
    for F in ${NFSLIST[@]}
    do
        echo "    umount ${MPE[$X]}"        >> NfsCloud.sh 
        [ $((++X)) ]
    done
    echo ""                                >> NfsCloud.sh
    echo "fi"                               >> NfsCloud.sh
    echo ""                                >> NfsCloud.sh
}


function nfs_progs()
{
    QCommand["debian"]="PKG=\$(dpkg-query -l nfs-client|grep \"ii\")"
    QCommand["ubuntu"]="PKG=\$(dpkg-query -l nfs-client|grep \"ii\")"
    QCommand["archlinux"]="PKG=\$(pacman -Qs nfs-utils)"
    QCommand["default"]="PKG=\$(pacman -Qs nfs-utils)"
    
    ICommand["debian"]="sudo apt-get --force-yes --yes install nfs-client"
    ICommand["ubuntu"]="sudo apt-get --force-yes --yes install nfs-client"
    ICommand["fedora"]="sudo dnf -y install nfs-utils"
    ICommand["redhat"]="sudo dnf -y install nfs-utils"
    ICommand["archlinux"]="sudo pacman --noconfirm -S nfs-utils"
    ICommand["default"]="sudo pacman --noconfirm -S nfs-utils"

    $QCommand[$DISTNAME]
    
    if [ -n $PKG ]
    then
        Status " Le package du client nfs est déjà installé." "OK"
    else
        sel=0
        TITRE="Sélectionner la commande associée avec la distribution(ou dérivée) :"
        menu "($DISTNAME) ${ICommand[*]}" Passer
        [ ${REPONSE[1] == "Passer" ] || [ ${REPONSE[0]} >= ${#ICommand[@]} ] &&  return 1
        
        let sel=$sel-1
        if  ! ${ICommand[$sel]} 
        then
            Erreur " Commande échouée."
            return 1
        else
            Done " Le package du client NFS a été installé correctement" "OK"
        fi
    fi
    return 0
}

function set_nfs_services()
{
    question "Le service NetworkManager doit-il être activé [O;N]? (Non par déf.) " 2
    if [ ${REPONSE[1]} == "O" ]; then
        sudo systemctl enable NetworkManager
        sudo systemctl start NetworkManager
        printf "Services actives. - "
        printf "Delais intentionnel de 2 secondes...\n"
        sleep 2
    fi
    return 0
}

get_locations
if [ $? -eq 1 ]; then
    Done "La configuration interractive a échoué ou a été avortée par l'usager" "NO"
    return 0
fi


TITRE="Sélectionner le point de montage à monter ou passer:"
sel=0

menu ${NFSLIST[*]} Tous Passer
sel=${REPONSE[0]}
Done " --> ${REPONSE[1]} --> Terminé" "OK"
return

#x=`pacman -Qs nfs-utils`
#[ -z "$x" ] && sudo pacman --noconfirm -S nfs-utils || printf " Le support nfs est déjà installé :)\n\n"


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
