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

for F in *.gz
do
    FILES[$c]=$F
    [ $((++c)) ]
done

N=$c
c=0
while [ $c -lt ${N} ]
do
    #printf "${FILES[$c]}\n"
    let l=${#FILES[$c]}
    [ $Width -lt $l ] && Width=$l
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
        return
    fi
done

Archive=${REPONSE[1]}
question "Êtes-vous certain de vouloir décompresser l'archive de sauvegarde $Archive ? [o/N] " 1
if [ -z ${REPONSE[1]} ]; then
    return
fi


Status "Désarchivage..." "OK"
pushd .
cd ~
H=`pwd`
question "Vérification du répertoire de destination:$H - Correcte [o/N]?" 1
if [ -z ${REPONSE[1]} ] || [ ${REPONSE[1]} == "n" ] 
then
    Done "Decompression annulée..." "NO"
    popd >dev/null
    return
elif [ ${REPONSE[1]} == "O"] || [ ${REPONSE[1]} == "o"] 
then
    Status "Decompression ..."
    tar xfz /Nuage/A/Linux/Arch-Linux-Stuff/PostinstallScripts/h*.gz
else
    Done "Decompression annulée..." "NO"
    popd >dev/null
    return
fi


Done "Décompression terminée." "OK"
