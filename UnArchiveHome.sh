#!/bin/sh

Clear
gotoxy 1 7
Clear

#TITRE='Sélecteur de Fichier(s):'
unset FILES
let c=0
let Height=0
let Width=0
let N=0
#pushd . >/dev/null
#cd $RemoteDestination

for F in $RemoteDestination/*.gz
do
    FILES[$c]=$F
    [ $((++c)) ]
done

N=$c
c=0
while [ $c -lt $N ]
do
    #printf "${FILES[$c]}\n"
    let l=${#FILES[$c]}
    [ $Width -lt $(expr $l + 2) ] && let Width=$l+2
    [ $((++c)) ]
done

[ $c -gt 7 ] && Height=7 || Height=$c
let x=0

while [ ${REPONSE[1]} != "Retour" ]
do
    menu ${FILES[*]} Retour
    if [ ${REPONSE[1]} == "Retour" ]
    then
        Done "Décompression annulée." "OK"  
        return 1
    else 
        break
    fi
done

Archive="${REPONSE[1]}"
question "Êtes-vous certain de vouloir décompresser l'archive de sauvegarde $Archive ? [o/N] " 1
if [ -z ${REPONSE[1]} ]; then
    Done "Décompression annulée." "OK"  
    return 1
fi

pushd .
cd ~
H=`pwd`

question "Vérification du répertoire de destination:$H - Correcte [o/N]?" 2

if [ -z ${REPONSE[1]} ] || [ ${REPONSE[1]} == "n" ] 
then
    Done "Decompression annulée..." "NO"
    popd >dev/null
    return 1
elif [ ${REPONSE[1]} == "O" ] || [ ${REPONSE[1]} == "o" ]
then
    Status "Decompression ..." "OK"
    tar xfz "$Archive"
else
    Done "Decompression annulée..." "NO"
    popd >dev/null
    return 1
fi

popd >/dev/null

Done "Décompression terminée." "OK"
return  0
