#!/bin/bash

#AddUser="useradd"

_USER=""
_R=""

function InstallZSH()
{
    if ! pacman -Qs zsh >/dev/null; then
        Clear
        gotoxy 1 7
        pacman -S zsh zsh-{completions,doc,lovers,syntax-highlighting,theme-powerlevel9k} zshdb --noconfirm >/dev/null
        Clear
    fi
}

function InstallExtraBash()
{

    if ! pacman -Qs bash-completion >/dev/null; then
        Clear
        gotoxy 1 7
        pacman  -S bash-completion --noconfirm >/dev/null
        Clear
    fi
}


newuser()
{
    Clear
    TITRE="Création d'un nouvel usager:"
    HOME_DIR_SWITCH="-m"
    _SHELL="/bin/bash"
    
    question "Usager standard:[O/n]:" 2 "Nom de l'usager  :" 20 "\"Répertoire de base\" (optionel, sans le '/'):" 40 "Shell: [B]ash;  [Z]sh ? " 2
    case ${REPONSE[1]} in
    [oO])
        _USRTYPE="wheel"
        ;;
    [nN])
        _USRTYPE="wheel,storage,audio,video,power,adm"
        ;;
    *)
        _USRTYPE="wheel"
        ;;
    esac
        
    _USER=${REPONSE[2]}
    if [ -z $_USER ]; then 
        Done " Création d'un usager annulée."
        return 1
    fi
    
    HOME_BASE=${REPONSE[3]}
    
    [ -n "$HOME_BASE" ] && HOME_DIR_SWITCH="-m -b /$HOME_BASE"
    
    question " L'usager $_USER sera créé. Correcte ? [O/n]" 1
    if [ -z ${REPONSE[1]} ] 
    then
        echo ""
    elif [ ${REPONSE[1]} == "n" ] || [ ${REPONSE[1]} == "N" ] 
    then 
        Done " Création d'un usager annulée."
        return 1
    fi
    
    
    case ${REPONSE[4]} in
    [bB])
#         _SHELL="/bin/bash"
         InstallExtraBash
       ;;
    [zZ])
        _SHELL="/bin/zsh"
        InstallZSH
        ;;
    *)
#        _SHELL="/bin/bash"
        InstallExtraBash
        ;;
    esac
    
#     Done " Debug -- Shell: $_SHELL, Location switch: $HOME_DIR_SWITCH, User: $_USER, Admin: $_USRTYPE"
#     return 1
    
    if [ -n $HOME_BASE ] 
    then
        if [ ! -d /$HOME_BASE ]
        then
            if ! mkdir /$HOME_BASE; then
                Erreur " Erreur lors de la tentative de créer le répretoire /$HOME_BASE."
                return 1
            fi
            Done " Le répertoire spécifique $CL_DTA$HOME_BASE$CL_RESET a été créé."
        fi
    fi
    
    if ! grep -w ^$_USER /etc/passwd &>/dev/null; then 
        #[ ! -d $_HOME ] && mkdir -p $_HOME
        if ! /usr/sbin/useradd $HOME_DIR_SWITCH  -g users -G $_USRTYPE -s $_SHELL $_USER; then
            Erreur "$CL_ERR -- Erreur:... Impossible de créer le compte utilisateur $CL_DTA$_USER$CL_RESET!\n   "
            return 1
        fi
        Erreur "\033[0mCompte-usager $CL_DTA$_USER \033[0mcréé avec succès!\n"
        UPDATEUSR="o"
        return 0
    else
        Erreur "\033[0;1;31mLe compte $CL_DTA$_USER $CL_ERR existe déjà!\033[0m\n"
        return 1
    fi
    
    Done "L'usager $_USER a été créé avec succès"
}



_deleteuser()
{
    if ! /usr/sbin/userdel $1 $2 &>/dev/null; then
        Erreur "$CL_ERR --- La destruction du compte $CL_DTA$_USER $CL_ERR échoué...\033[0m"
        return 1
    else
        Erreur "\033[0m Compte $CL_DTA$_USER \033[0mdétruit"
    fi 
    UPDATEUSR="o"
    Done "L'usager $_USER a été détruit"
}

deluser()
{
    Clear
#    list_users 18 passwd
    TITRE="Détruire un usager:\n"
    question "Nom de l'usager  :" 20 "Detruire son répertoire[o/N] :" 1
    _USER=${REPONSE[1]}
    _R=${REPONSE[2]}
    [ -z $_USER ] && return 1
    if ! grep -w ^$_USER /etc/passwd &>/dev/null;then
        Erreur "$CL_ERR --- Erreur: l'usager $CL_DTA$_USER $CL_ERR n'existe pas!\033[0m\n"
        return 1
    fi
    if [ -z $_R ] || [ $_R == "N" ] || [ $_R == "n" ]; then  
        if  ! userdel $_USER &>/dev/null 
        then 
            Done " Échec de la destruction du compte $CL_DTA$_USER$CL_RESET !"
            return 1
        else
            Done " L<usager $CL_DTA$_USER$CL_RESET a été détruit!"
        fi
    else 
        if  ! userdel -r $_USER
        then 
            Done " Échec de la destruction du compte $CL_DTA$_USER$CL_RESET !"
            return 1
        else
            Done " L'usager $CL_DTA$_USER$CL_RESET a été détruit!"
        fi
    fi
    UPDATEUSR="o"
    return  0
}
    
chpass()
{
    Clear
    TITRE="Changer le mot de passe d'un utilisateur:"
    question "Nom de l'usager   :" 20 "Nouveau mot de passe:" 16
    _USER=${REPONSE[1]}
    [ -z $_USER ] && return 1
    if ! grep -w ^$_USER /etc/passwd &>/dev/null;then 
        Done "$CL_ERR -- Erreur:$CL_RESET l'usager $_CL_DTA $_USER $CL_ERR n'existe pas!" "NO"
        return 1
    fi
    if ! echo "$_USER:${REPONSE[2]}" | chpasswd; then #2>/dev/null ; then
       Done "$CL_ERR -- Erreur:$CL_RESET Le changement de mot passe pour l'usager $CL_DTA$_USER$CL_RESET a échoué!" "NO"
    else
       Done "Le mot de passe de l'usager $CL_DTA$_USER$CL_RESET a été changé avec succès" "OK"
    fi
    
    return 0
}

execute()
{
    #Menu Utilisateurs:

    REPONSE[0]=0
    while [ ${REPONSE[0]} != "4" ]
    do
        TITRE="   Gestion Utilisateurs:   "
        menu "Créer un usager" "Détruire un usager" "Changer le mot de passe d'un usager" "Menu prédecant"
        sel=${REPONSE[0]}
        case $sel in
        1)
            newuser
        ;;
        2)
            deluser
        ;;
        3)
            chpass
        ;;
        4)
        break;;
        esac
    done

    return 0

}


execute

