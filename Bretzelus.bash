#!/bin/sh
# (C) 2001-2018, Serge Lussier
PROGRAM="Scripts de configuration Bretzelus pour Arclinux"
TITRE=""
MESSAGE="   "
Choix=""

Files[0]="Arch.Home.sh"
Files[1]="UnArchiveHome.sh"
Files[2]="FixQtMicroScrollBug.sh"
Files[3]="SetupNuage.sh"
Files[4]="Archive.etc.sh"

CSUP="A"
CSDOWN="B"

IN_FIELD="\033[44;1;33m"
CL_ERR="\033[1;31m"
CL_DTA="\033[1;33m"
CL_MENUNORMAL="\033[44;1;33m"
CL_MENUSELECT="\033[42;0;33m"
CL_WINBCK="\033[47;1;47m"
CL_RESET="\033[0m"
CL_QUESTION="\033[0;30;46m"
CL_QUESTION_SEL="\033[0;34;46m"

USERNAME=`id -u -n`

export IN_FIELD CL_ERR CL_DTA CL_MENUNORMAL CL_MENUSELECT CL_WINBCK CL_RESET CL_QUESTION CL_QUESTION_SEL
export REPONSE=" "

if [ -z $COLUMNS ] ; then
    export COLUMNS=80 LINES=25
fi

Status()
{
    let x=$(expr $COLUMNS - 5)
    let y=$(expr $LINES - 1)
    gotoxy 1 $y
    printf "\033[1;37m$1"
    gotoxy $x $y
    [ $2 == "NO" ] && printf "\033[1;37m[\033[1;31mNO\033[1;37m]\n\n"
    [ $2 == "OK" ] && printf "\033[1;37m[\033[1;32mOK\033[1;37m]\n\n"
}

x_pos=0
y_pos=0
#export LINES COLUMNS
export x_pos y_pos grp_starty=1
export ligne=`printf "%$(expr $COLUMNS - 10)s"`


function Erreur()
{
    Status "$1 - \033[0;1;5;33mAppuyer pour continuer...$CL_RESET" "NO"
    read -n 1 -t 50 dummy
}

export -f Erreur

function Done()
{
    Status "$1 - \033[0;1;5;33mAppuyer pour continuer...$CL_RESET" "OK"
    read -n 1 -t 50 dummy
}

export -f Done

# Fonction center_str:
# Calcule la position horizontale au centre de l'ecran
# Parametres:
#  $1:
#      '-v' : l'argument est la valeur numerique de la longueur
#      chaine : la longeur est lue par ${#p2}
center_str()
{
    len=0
    p=$1
    if [ "$1" = "-v" ]; then
        len=$2
    else
        len=${#p}
    fi

    x_pos=$(expr $(expr $COLUMNS - $len) / 2)
    if [ -z $3 ]; then
        y_pos=0
        return $x_pos
    fi
    y_pos=$(expr $LINES - $3)
    y_pos=$(expr $y_pos / 2)

    return $x_pos
}

function  gotoxy()
{
  if [ $# -lt 2 ];then
      printf "\033[;$1f"
  elif [ $# -eq 2 ] ; then
      printf "\033[$2;$1f"
  fi
}

export -f gotoxy



# Fonction Clear:
# Efface l'ecran et affiche un titre...
function Clear()
{
    clear

    longueur=$(expr $COLUMNS - 4)
    c=0

    center_str -v $longueur

    while [ $c -lt 6 ]
    do
       gotoxy $x_pos $(expr $c + 1)
        printf "$CL_WINBCK$ligne"
        [ $((c++)) ]
    done
    let c=1
    while [ $c -le 3 ]
    do
        gotoxy $(expr $x_pos + 2) $(expr $c + 1)
        printf "$IN_FIELD${ligne:0:$(expr $longueur - 12)}"
        if [ $c -gt 1 ]; then
        printf "\033[0;40m "
    fi
    [ $((c++)) ]
    done
    printf $CL_RESET
    # Ligne d'ombrage

    gotoxy $(expr $x_pos + 3) $(expr $c + 1)

    echo -e "\033[0;40m${ligne:0:$(expr $longueur - 12)}"

    # text du titre du programme:
    txt="$IN_FIELD\033[1;37m $PROGRAM Pour \033[1;33m`echo $HOSTNAME|cut -d. -f1` (\033[31m$USERNAME$IN_FIELD)$CL_RESET"
    center_str -v $(expr ${#txt} - 84)

    gotoxy $x_pos 3
    echo -e $txt #"$IN_FIELD\033[1;37m $PROGRAM Pour \033[1;33m`echo $HOSTNAME|cut -d. -f1` (\033[31m$USERNAME$IN_FIELD)$CL_RESET"
    gotoxy 1 1
}



question()
{
    Clear

    let nbQuestions=$(expr $# / 2)

    let lenp=0
    let arg=0
    let longueur=0
    let len=0
    let pos_prompt=0

    # Trouver la largeur :
    for par in "$@"
    do  # Arguments pairs: texte de la question
        if [ $arg -eq 0 ]; then
        let len=${#par}
        if [ $pos_prompt -lt $len ]; then
            pos_prompt=$(expr $len + 1)
        fi
        let arg=1

    else # Arguments impairs: longueur de la zone de saisie
        let arg=0
        if [ $lenp -lt $par ]; then
            let lenp=$par
        fi
    fi
    done
    let longueur=$pos_prompt+$lenp

    let nblignes=$(expr $nbQuestions + 4)
    let arg=0
    center_str -v $(expr $longueur + 5) $(expr $nblignes + 4) #Pas tout-a-fait au centre verticale de l'ecran...
    if [ $y_pos -lt 8 ];then
        let y_pos=8
    fi
    gotoxy $x_pos $y_pos
    let c=0
    # affichier le fond de la fenetre en gris pale
    while [ $c -lt $nblignes ]
    do
        gotoxy $x_pos $(expr $c + $y_pos)
    printf "\033[0;47m${ligne:0:$(expr $longueur + 5)}\n"
    [ $((++c)) ]0
    done
    gotoxy $x_pos $y_pos
    printf "\033[30m$TITRE\n"
    gotoxy $x_pos $(expr $y_pos + 1)
    let c=1
    # afficher le fond de la zone de question en CYAN
    while [ $c -le $nbQuestions ]
    do
    gotoxy $(expr $x_pos + 2)  $(expr $c + $y_pos)
    printf "\033[0;46m${ligne:0:$(expr $longueur + 1)}"
    [ $((++c)) ]
    if [  $c -eq 2 ]; then
        continue
    fi
    printf "\033[0m "
    done
    # Ligne noir pour effet d'ombrage:
    gotoxy $(expr $x_pos + 3)  $(expr $c + $y_pos)
    printf "\033[0m${ligne:0:$(expr $longueur + 1)}"

    # maintenant qu'on a la longueur totale de la region,
    # on re-parcour les parametres pour les afficher:
    let c=1
    let arg=0
    for par in "$@"
    do
    if [ $arg -eq 0 ];then
        # Argument est le texte du prompt:
        pos=$(expr $x_pos + $pos_prompt - ${#par} + 2)
        gotoxy $pos $(expr $c + $y_pos)
        printf "\033[0;30;46m$par"
        arg=1
        else
        arg=0
        gotoxy $(expr $x_pos + $pos_prompt + 2) $(expr $c + $y_pos)
        printf "$IN_FIELD${ligne:0:$par}\n"
        field_len[$c]=$par
        [ $((++c)) ]
    fi
    done
    copyright="(C)2001-$(date '+%Y'), Serge Lussier"
    len=${#copyright}
    gotoxy $(expr $x_pos + $longueur - $len + 2) $(expr $y_pos + $nblignes - 1)
    printf "\033[30;47m$copyright\033[0m\n"
    let c=1
    # on a nbQuestions: boucle pour le nombre de question:
    while [ $c -le $nbQuestions ]
    do
        gotoxy $(expr $x_pos + $pos_prompt + 2) $(expr $c + $y_pos)
        printf $IN_FIELD
        REPONSE[$c]=""
        read -t 30 REPONSE[$c]
        #[ -z ${REPONSE[$c]} ] && break;
        [ $((++c)) ]
    done
    printf "\033[0m \n"
 }

export -f question Clear center_str


# Fonction Menu:
#  -- Affiche et execute un menu interactif
#  -- Le nombre d'items maximum est de 9 pour sélectionner
#     l'item avec le chiffre mais on peut afficher plus de 9 items
#     et en vérifier la sélection avec ${REPONSE[1]} qui contient le texte
#     originale de l'item....
#  -- Retourne deux résultats:
#  --  ${REPONSE[0]} contient le numéro de sélection
#  --  ${REPONSE[1]} contient le texte ( titre ) de l'item du menu.
#
#      SYNTAXE:   menu "item 1" "item 2" "item 3" .. "item 9"
menu()
{
    Clear

    let nbItems=$#
    [ $nbItems -gt 9 ] && let nbItems=9
    let arg=0
    let longueur=0
    let len=0
    let pos_item=0
    let current_item=0
    let w_menu=0
# Trouver la largeur :
    let c=0
    let i=1

    for par in "$@"
    do
        [ $c -gt 9 ] && break
        len=${#par}
        mitem[$c]="$i-$par"
        item[$c]=$par
        [ $((++c)) ]
        [ $((++i)) ]
        if [ $len -gt $longueur ];then
            longueur=$len
        fi
    done

    hl="[u|U]-HAUT | [j|J]-BAS[ENTER]-Selectionner"
    let len=${#hl}
    [ $longueur -lt $len ] && let longueur=$len

#Obtenir la coordonée (x,y) au centre de l'écran
    let w_menu=$longueur+4
    let w_win=$w_menu+5
    let w_dy_menu=$nbItems+3
    let c=0

	center_str -v $w_menu $(expr $LINES - $(expr $w_dy_menu + 10))
# Imprimer le fond de l'écran
    while [ $c -lt $(expr $w_dy_menu + 5) ]
    do
        gotoxy $x_pos $(expr $c + $y_pos)
        printf "$CL_WINBCK${ligne:0:$w_win}"
        [ $((++c)) ]
    done
    gotoxy $x_pos $y_pos
    printf "\033[0;30;47m$TITRE"
# Imprimer le fond du menu
    let c=1
    while [ $c -lt $w_dy_menu ]
    do
        gotoxy $(expr $x_pos + 2) $(expr $c + $y_pos)
        printf "$CL_MENUNORMAL${ligne:0:$w_menu}"
        [ ! $c = 1 ] && printf "\033[0m \n"
        [ $((++c)) ]
    done
    gotoxy $(expr 3 + $x_pos) $(expr $w_dy_menu + $y_pos)
    printf "\033[0m${ligne:0:w_menu}"
    copyright="(C)2001-$(date '+%Y'), Serge Lussier"
    len=${#copyright}
    gotoxy $(expr $w_win - $len + $x_pos - 1) $(expr $w_dy_menu + 4 + $y_pos)
    printf "\033[30;47m$copyright\033[0m\n"
# Imprimer les items du menu
    let c=0
    while [ $c -lt $nbItems ]
    do
        gotoxy $(expr 3 + $x_pos) $(expr $c + 2 + $y_pos)
        printf "$CL_MENUNORMAL${mitem[$c]}"
        [ $((++c)) ]
    done
    gotoxy $x_pos $(expr $w_dy_menu + 4 + $y_pos)
# Fonction Select:
# Affiche l'item courant du menu selon son etat
    function Select()
    {
        case $1 in
            normal)
        gotoxy $(expr 2 + $x_pos)  $(expr $current_item + 2 + $y_pos)
            printf "$CL_MENUNORMAL${ligne:0:$w_menu}"
        gotoxy $(expr 3 + $x_pos)  $(expr $current_item + 2 + $y_pos)
        printf "$CL_MENUNORMAL${mitem[$current_item]}"
        gotoxy $(expr 2 + $x_pos)  $(expr $current_item + 2 + $y_pos)
    ;;
        selected)
            gotoxy $(expr 2 + $x_pos)  $(expr $current_item + 2 + $y_pos)
        printf "$CL_MENUSELECT${ligne:0:$w_menu}"
        gotoxy $(expr 3 + $x_pos)  $(expr $current_item + 2 + $y_pos)
        printf "$CL_MENUSELECT${mitem[$current_item]}"
        gotoxy $(expr 2 + $x_pos)  $(expr $current_item + 2 + $y_pos)
    ;;
        esac
    }
    gotoxy $(expr 2 + $x_pos) $(expr $w_dy_menu + 2 + $y_pos)
    printf "\033[0;31;47m[a|A]-HAUT | [b|B]-BAS"
    gotoxy $(expr 2 + $x_pos) $(expr $w_dy_menu + 3 + $y_pos)
    printf "Chiffre ou [ENTER]: Exécuter"
    let current_item=0
    Select selected
    gotoxy 1 15; printf "\033[0m"
# Voici la boucle du menu
    function loop_menu()
    {
        current_item=0
        let _Done=0
        ctrl=0
        while [ $_Done -ne 1 ]
        do
            read -s -n 1 clef &>/dev/null
            case $clef in
                a|A)
                Select normal
                [ $((--current_item)) ]
                [ $current_item -lt 0 ] && let current_item=$(expr $nbItems - 1)
                REPONSE[0]=$(expr $current_item + 1)
                REPONSE[1]=${item[$current_item]}
                Select selected
            ;;
            b|B)
                Select normal
                [ $((++current_item)) ]
                [ $current_item -gt $(expr $nbItems - 1) ] && let current_item=0
                REPONSE[0]=$(expr $current_item + 1)
                REPONSE[1]=${item[$current_item]}
                Select selected
            ;;

            [1-9])
                if [ $clef -le $nbItems ]; then REPONSE[0]=$clef
                REPONSE[1]=${item[$(expr $clef - 1)]}
                break;
            fi
            ;;
                *)
                if [ -z $clef ] ; then REPONSE[0]=$(expr $current_item + 1)
                REPONSE[1]=${item[$current_item]}
                break;
            fi
            ;;
            esac
        done
    }
    loop_menu
    printf "\033[0m"

}

# Fonction AfficheTitre:
#  -- Cette fonction n'est plus utilisee dans ce programme...


export gotoxy question Clear
export TITRE


Archiver()
{
    source ${Files[0]}
}

DeArchiver()
{
    source ${Files[1]}
}


FixQtScroll()
{
    source ${Files[2]}
}

ConfigureCloud()
{
    source ${Files[3]}
}

TestSelecteur()
{
    source TestSelecteur.bash
}


function Usagers()
{
    source users.bash
}


function Main()
{
    let sel=0

    while [ $sel != 8 ]
    do
    TITRE="   Menu Principale:   "
    menu TestSelecteur Archiver Désarchiver "Micro-Scolling de QT sous Plasma" "Configurer le Nuage NFS" "Sauvegarder /etc" "Gestion Usagers" Quitter
    sel=${REPONSE[0]}
    
    case $sel in
    1)
        TestSelecteur
        ;;
    2)
        Archiver
        ;;
    3)
        DeArchiver
        ;;
    4)
        FixQtScroll
        ;;
    5)
        ConfigureCloud
        ;;
    6)
        Clear
        gotoxy 1 7
        printf "${Files[4]} : Pas encore implémenté"
        read
        ;;
    7)
        Usagers
        ;;
    8)
        TITRE="           Quitter"
        question "Êtes-vous sûr de vouloir Quitter? [n/N:Non] (Defaut:Oui)" 4
        Clear
        if [ -z ${REPONSE[1]} ] ; then
            Clear
            gotoxy 1 7
            echo "Terminé."
            break;
        fi
        [ ${REPONSE[1]} == "N" ] || [ ${REPONSE[1]} == "n" ] && sel=1

        gotoxy 1 7
        #printf "R: $sel ( ${REPONSE[1]} )\n"
        #echo "Quitter"
        Done "Terminé. (C) 2001,2018 bretzelus"
        ;;

    esac
    done
    return 0
}


#Clear

Main
#clear
