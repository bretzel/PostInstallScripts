#!/bin/bash


Clear

#TITRE='Sélecteur de Fichier(s):'
unset FILES
let c=0
let Height=0
let Width=0
let items=0
let N=0

Clear

for F in "$@"
do
    FILES[$c]=$F
    #printf "$F\n"
    [ $((++c)) ]
done



N=$c
c=0
#printf "Debug: N=$N\n"
#printf " args: $*"
#read

#unset items
while [ $c -lt ${N} ]
do
    #printf "${FILES[$c]}\n"
    let l=${#FILES[$c]}
    [ $Width -lt $l ] && Width=$l
    [ $((++c)) ]
done

[ $c -gt 7 ] && Height=7 || Height=$c
let x=0
#printf "Width: $Width; Height: $Height\n"

#while [ $x -lt $Height ]
#do
#    items[$x]=${FILES[$x]}
#    [ $((++x)) ]
#done

while [ ${REPONSE[1]} != "Retour" ]
do
  menu ${FILES[*]} Retour
  [ ${REPONSE[1]} == "Retour" ] && break
done



Status "Test terminé. Appuyer sur [ENTER] pour retourner au menu précedant..." "OK"
read -t 5
