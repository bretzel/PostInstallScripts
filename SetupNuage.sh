#!/bin/bash



# Archlinux:


unset NFSLIST
NfsCloudSH="NasCloud.sh"
unset Local
unset IP
unset MPE
unset HostAlias

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
        TITRE="(Données initiales [$CL_ERR$DISTNAME$CL_WINBCK])"
        question "Adresse IP du Nuage:" 16 "Point de montage racine locale:" 40 "Alias:" 40
            
        IP=${REPONSE[1]}
        Local=${REPONSE[2]}
        HostAlias=${REPONSE[3]}
    
        if [ -z "$IP" ] || [ -z "$Local" ]; then 
            Done " Configuration du nuage avorté." "NO"
            return 1
        fi

        AddTitleLine "clear" " Initialisation des données du Nuage sous le protocole NFS:"
        AddTitleLine "..........................................................."
        AddTitleLine "Adresse IP: $IP" "Chemin racine locale: $Local" "Alias du nom: $HostAlias"
        
        DisplayTitleLines
        
#        Status "Terminé. Appuyer pour retourner." "OK"        
#        return 1
        
        O=`grep "$IP" /etc/hosts` # Isoler la sortie de grep dans une variable ( $O ). 
        if [ -z  "$O" ]; then     # Pour pouvoir isoler ici la chaîne de caractères en une seule pour éviter une erreur de surplus d'arguments.
            question "Est-il souhaité de renseigner /etc/hosts [O/n] ?" 2
            if [ -z ${REPONSE[1]} ] || [ ${REPONSE[1]} == "O" ] || [ ${REPONSE[1]} == "o" ]; then      
                if [ -z "$O" ]; then
                    echo "$IP   $HostAlias" >>/etc/hosts
                    if [ $? = 1 ]; then 
                        Erreur "/etc/hosts ne peut être renseigné." "NO"
                        return 1
                    else 
                        Done "/etc/hosts est renseigné [$O]." "OK"
                    fi
                fi
            fi
        fi 
        
        if [ ! -d $Local ]; then 
            if ! mkdir -p  $Local 2>/dev/null; then
                Erreur " Le répertoire racine de montage ne peut être créé."
                return 1
            fi
            Done " Le répertoire racine de montage a été créé." "OK"
        else 
            Done " Le répertoire racine de montage existe déjà" "OK"
        fi
        
        return 0
    }
    
        
    function set_binds()
    {
        sel=0
        while [ $sel -ne 2 ]
        do
            TITRE=" Définition des points de montage NFS (Préparation du script):"
            menu "Ajouter un emplacement" Terminé
            sel=${REPONSE[0]}
            case $sel in 
            1)
                question "Donner l'emplacement:$HostAlias:/" 40 "-> Monté dans le sous-dossier $Local/" 40
                if [ -n ${REPONSE[1]} ]; then
                    NFSLIST[$X]="$HostAlias:/${REPONSE[1]}"
                    MPE[$X]="$Local/${REPONSE[2]}" # Il y a ici un fort risque de duplicat du point de montage locale...
                    if [ ! -d "${MPE[$X]}" ]           # Il faudra prévenir les duplicats dans le tableau MPE. D'ailleurs, il faut
                    then                           # faire la même chose pour le tableau NFSLIST...
                        mkdir -p "${MPE[$X]}"
                        Done "${MPE[$X]} cree" "OK"
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

    function generate_script()
    {
        X=0
        Status "Génération du script montage NFS pour NetworkManager::Dispacher:" "OK"
        echo "#.bin/sh"                             >  $NfsCloudSH
        echo ""                                     >> $NfsCloudSH
        echo "if [ \""\$2\"" = \"up\" ]; then"      >> $NfsCloudSH
        echo ""                                     >> $NfsCloudSH
        X=0
        for F in ${NFSLIST[@]}
        do
            echo "    mount -t nfs $F  ${MPE[$X]}"  >> $NfsCloudSH
            [ $((++X)) ]
        done
        echo ""                                     >> $NfsCloudSH
    
        X=0
        echo "elif [ \""\$2\"" = \"down\" ]; then"  >> $NfsCloudSH
        echo ""                                     >> $NfsCloudSH
        for F in ${NFSLIST[@]}
        do
            echo "    umount ${MPE[$X]}"            >> $NfsCloudSH
            [ $((++X)) ]
        done
        echo ""                                     >> $NfsCloudSH
        echo "fi"                                   >> $NfsCloudSH
        echo ""                                     >> $NfsCloudSH
        
        TITRE="Script du montage du nuage en NFS généré."
        question "Est-il désiré de copier le script sous /etc/NetworkManager/dispacher.d/ ?[O/n]" 2
        if [ -z ${REPONSE[1]} ] || [ ${REPONSE[1]} == "O" ] || [ ${REPONSE[1]} == "o" ]; then 
            if ! cp $NfsCloudSH /etc/NetworkManager/dispatcher.d; then
                Erreur " La copie du script vers /etc/NetworkManager/dispacher.d/ a échoué."
                return 1
            fi
            Done " Copie effectuée aavec succes" "OK"
        else 
            Done " Copie annulée." "OK"
        fi
        return 0
    }

#        Output=`mount | grep "$Local"`
#        if [ -z $Output ]; then
#            TITRE="Connection temporaire au nuage:"
#            question "Donner
#        fi

    
    
    init_root_locations
    [ $? -eq 1 ] && return 1
    set_binds
    [ $? -eq 1 ] && return 1
    generate_script
    return 0
}




function nfs_progs()
{
    QCommand["debian"]="PKG=\$(dpkg-query -l nfs-client|grep \"ii\")"
    QCommand["ubuntu"]="PKG=\$(dpkg-query -l nfs-client|grep \"ii\")"
    QCommand["arch"]="PKG=\$(pacman -Qs nfs-utils)"
    QCommand["default"]="PKG=\$(pacman -Qs nfs-utils)"
    
    ICommand["debian"]="sudo apt-get --force-yes --yes install nfs-client"
    ICommand["ubuntu"]="sudo apt-get --force-yes --yes install nfs-client"
    ICommand["fedora"]="sudo dnf -y install nfs-utils"
    ICommand["redhat"]="sudo dnf -y install nfs-utils"
    ICommand["arch"]="sudo pacman --noconfirm -S nfs-utils"
    ICommand["default"]="sudo pacman --noconfirm -S nfs-utils"

    $QCommand[$DISTNAME]
    
    if [ -n $PKG ]
    then
        Status " Le package du client nfs est déjà installé." "OK"
    else
        sel=0
        TITRE="Sélectionner la commande associée avec la distribution(ou dérivée) :"
        menu "($DISTNAME) ${ICommand[*]}" Passer
        if [ ${REPONSE[1]} == "Passer" ] || [ ${REPONSE[0]} >= ${#ICommand[@]} ]
        then 
            Done "Selection annulée." "NO"
            return 1
        fi
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

# function set_nfs_services()
# {
#     question "Le service NetworkManager doit-il être activé [O;N]? (Non par déf.) " 2
#     if [ ${REPONSE[1]} == "O" ]; then
#         sudo systemctl enable NetworkManager
#         sudo systemctl start NetworkManager
#         printf "Services actives. - "
#         printf "Delais intentionnel de 2 secondes...\n"
#         sleep 2
#     fi
#     return 0
# }


function NFSMain()
{
    let sel=0
    
    #gotoxy ${CloudFields[Ip]}
    #AA=${CloudNFSData[Ip]}
    #printf "IP: $AA\n"
    #CloudNFSData[Ip]="192.168.2.62"
    #AA=${CloudNFSData[Ip]}    
    #Status " testing cloudfields terminé[$AA]: Appuyer pour retourner.." "OK"
    #return 1
    
    while [ $sel -ne 4 ]
    do
        TITRE="Configuration du Nuage protocole nfs:"
        menu "Configuration Initale" "Support logiciel NFS" "Service Système (systemctl)" "Retour/Terminé"
        
        sel=${REPONSE[0]}
        case $sel in 
        1)
            init_nfs_data
            [ $? -eq 1 ] && return 1
        ;;
        2)
            nfs_progs
            [ $? -eq 1 ] && return 1
        ;;
        3)
            break
        ;;
        4)
            break
        ;;
        esac
    done
    
    return  0
}

NFSMain

    
# 
# 
# TITRE="Sélectionner le point de montage à monter ou passer:"
# sel=0
# 
# menu ${NFSLIST[*]} Tous Passer
# sel=${REPONSE[0]}
# Done " --> ${REPONSE[1]} --> Terminé" "OK"
# return
# 
# #x=`pacman -Qs nfs-utils`
# #[ -z "$x" ] && sudo pacman --noconfirm -S nfs-utils || printf " Le support nfs est déjà installé :)\n\n"
# 
# 
# printf "Connexion au Nuage:\n"
# question "Donner l'emplacement du Nuage (NSF):" 40
# sudo mount -t nfs 192.168.2.62:/nfs/bretzelus /Nuage/A 2>/dev/null
# if [ $? == 0 ]; then
#    printf " Nuage/A monté.\n"
#    sudo mount -t nfs 192.168.2.62:/nfs/Public /Nuage/B
# else
#   Erreur " connexion NFS au Nuage avortée \n"
#   return 1
# fi
# 
# printf "Copie du script de connexion dans etc:\n"
# sudo cp  nfs.sh /etc/NetworkManager/dispatcher.d/
# if [ $? == 0 ]; then
#   echo " Copié.\n"
# else
#   Erreur " Copie de nfs.sh avortée...Appuyer sur CTRL-C pour avorter le script."
#   return 1
# fi
# 
# printf " hosts: \n"
# x=`grep "WD.Nuage" /etc/hosts`
# if [ ${#x} -gt 0 ] ; then
#   printf " le fichier hosts est déjà renseigné sur Nuage... \n"
# else
#   printf " Renseignement du Nuage dans le fichier hosts:\n"
#   cp /etc/hosts .
#   echo "192.168.2.62       WD.Nuage        Nuage" >> hosts
#   sudo cp hosts /etc/hosts
# fi
# 
# printf " Test: ping Nuage:"
# ping -c 3 Nuage
# 
# Done "Terminé. Appuyer sur [ENTER] pour retourner au menu."
