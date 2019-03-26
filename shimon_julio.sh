#!/bin/bash

clear
[[ $1 == -s ]] && Som=1 || Som=0
ColunaMeio=$(($(tput cols)/2))
LinhaMeio=$(($(tput lines)/2))
function FazSeta
{
#  Recebe: Tipo de seta; cor; som
    local k
    case $1 in
        A)  local Lin=$((LinhaMeio - 8))
            local Col=$((ColunaMeio - 3))
            local Seta[1]="    █"
            local Seta[2]="   ███"
            local Seta[3]="  █████"
            local Seta[4]=" ███████"
            local Seta[5]="█████████"
            local Pinta=$(tput setaf 1)
            local Toca=test.wav
            ;;
        C)  local Lin=$((LinhaMeio - 3))
            local Col=$((ColunaMeio + 7))
            local Seta[1]="█"
            local Seta[2]="██"
            local Seta[3]="███"
            local Seta[4]="██"
            local Seta[5]="█"
            local Pinta=$(tput setaf 2)
            local Toca=alert.wav
            ;;
        B)  local Lin=$((LinhaMeio + 2))
            local Col=$((ColunaMeio - 3))
            local Seta[1]="█████████"
            local Seta[2]=" ███████"
            local Seta[3]="  █████"
            local Seta[4]="   ███"
            local Seta[5]="    █"
            local Pinta=$(tput setaf 3)
            local Toca=receive.wav
            ;;
        D)  local Lin=$((LinhaMeio - 3))
            local Col=$((ColunaMeio - 7))
            local Seta[1]="  █"
            local Seta[2]=" ██"
            local Seta[3]="███"
            local Seta[4]=" ██"
            local Seta[5]="  █"
            local Pinta=$(tput setaf 4)
            local Toca=send.wav
            ;;
    esac
    (($4)) && Pinta=$(tput setaf 5)
    (($2)) && echo $Pinta
    for k in {1..5}
    do
        tput cup $((Lin+k)) $Col
        echo -e "${Seta[k]}"
    done
    (($3)) && aplay $Toca &>-
    (($2)) && {
        sleep .3
        tput sgr0
        FazSeta $1 0 0
    }
        
}; export -f FazSeta

function Sai
{
    stty sane
    tput cnorm
    tput sgr0
    echo Score: $i 
    exit $i
}

trap Sai 2 3 15 
tput civis
FazSeta A 0 0
FazSeta B 0 0
FazSeta C 0 0
FazSeta D 0 0
i=0
posicoes=ABCD
stty -echo
while :
do
    Vez=$((RANDOM%4))
    Vez=${posicoes:$Vez:1}
    TudoComp[++i]=$Vez
    for Jogada in ${TudoComp[@]}
    do
        FazSeta $Jogada 1 $Som
        (($Som)) && sleep .1 || sleep .3
    done
    for ((j=1; j<=i; j++))
    {
        read -sn2; read -sn1 Ult
        FazSeta $Ult 1 $Som 1
        [[ $Ult != ${TudoComp[j]} ]] && {
            Sai
        }
    }
    case ${#i} in
        1) offset=1;;
        2) offset=0;;
        3) offset=-1;;
    esac
    tput cup $LinhaMeio $((ColunaMeio+offset))
    echo "$i"
    sleep 1; 
done
