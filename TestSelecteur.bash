#!/bin/bash


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
  [ ${REPONSE[1]} == "Retour" ] && break
done

Status "Test ligne 1" "NO"
Status "Test ligne 2" "OK"
Status "Test ligne 3" "NO"
Status "Test ligne 4" "OK"
Done   " -------- " "OK"
