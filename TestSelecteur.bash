#!/bin/bash


Clear

#TITRE='Sélecteur de Fichier(s):'
let FILES=0
let c=0
let Height=0
let Width=0
let items=0
let N=0
for F in "$@"
do
    FILES[$c]=$F
    printf "$F\n"
    [ $((++c)) ]
done
printf "$c\n"
N=$c
let c=0
printf "Debug: N=$N\n"
printf " args: $*"
read

while [ $c -lt ${N} ]
do
    #printf "${FILES[$c]}\n"
    let l=${#FILES[$c]}
    [ $Width -lt $l ] && Width=$l
    unset "items[$c]"
    [ $((++c)) ]
done

[ $c -gt 7 ] && Height=7 || Height=$c
let x=0
printf "Width: $Width; Height: $Height\n"

while [ $x -lt $Height ]
do
    items[$x]=${FILES[$x]}
    [ $((++x)) ]
done

while [ ${REPONSE[1]} != "Retour" ]
  TITRE="Selecteur d'archive:"
do
  menu ${items[*]} Retour
  [ ${REPONSE[1]} == "Retour" ] && return
done



Done "Test terminé."
