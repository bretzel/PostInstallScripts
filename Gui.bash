#!/bin/bash


declare -A TMenu

let TMenuMaxWidth=38
let TMenuMaxHeight=$LINES-4
let TMenu[x_pos]=$COLUMNS-$TMenuMaxWidth
let TMenu[x_in]=$COLUMNS-$TMenuMaxWidth+1
let TMenu[y_pos]=2
let TMenu[item_count]=0
printf -v TMenu[Spc] %35s

IN_FIELD="\033[44;1;33m"
CL_ERR="\033[1;31m"
CL_DTA="\033[1;33m"
CL_MENUNORMAL="\033[44;1;33m"
CL_MENUSELECT="\033[42;0;33m"
CL_WINBCK="\033[0;30;47m"
CL_RESET="\033[0m"
CL_QUESTION="\033[0;30;46m"
CL_QUESTION_SEL="\033[0;34;46m"

#export TMenuMaxWidth TMenuMaxHeight


function ClearMenu()
{
    let yy=$TMenuMaxHeight #${TMenu[item_count]}+2
    while [ $yy -gt 0 ]
    do
        gotoxy ${TMenu[x_pos]} $(expr $yy + ${TMenu[y_pos]})
        printf "$CL_WINBCK${TMenu[Spc]}$CL_RESET"
        [ $((--yy)) ]
    done
    printf "$CL_RESET\n";
    
}




