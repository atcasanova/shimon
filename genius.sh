#!/bin/bash

########################
#    Jogo do Genius    #
#  Autor: Julio Neves  #
#----------------------#
# Contribuições/Ideias #
#----------------------#
#     Maik Alberto     #
#   Alfredo Casanova   #
########################

# Variáveis Globais
LinhaMeio=$(($(tput lines)/2))
ColunaMeio=$(($(tput cols)/2))

clear
stty -echo

function FazSeta
{
#  Recebe: Tipo de seta; cor; som
    local k
    case $1 in
        A)  local Lin=$((LinhaMeio - 9))
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
            local Col=$((ColunaMeio + 9))
            local Seta[1]="█"
            local Seta[2]="██"
            local Seta[3]="███"
            local Seta[4]="██"
            local Seta[5]="█"
            local Pinta=$(tput setaf 2)
            local Toca=alert.wav
            ;;
        B)  local Lin=$((LinhaMeio + 3))
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
            local Col=$((ColunaMeio - 9))
            local Seta[1]="  █"
            local Seta[2]=" ██"
            local Seta[3]="███"
            local Seta[4]=" ██"
            local Seta[5]="  █"
            local Pinta=$(tput setaf 4)
            local Toca=send.wav
            ;;
    esac
    (($2)) && echo $Pinta
    for k in {1..5}
    do
        tput cup $((Lin+k)) $Col
        echo -e "${Seta[k]}"
    done
    (($3)) && aplay $Toca &>-
    (($2)) && {
        sleep .1
        tput sgr0
        FazSeta $1 0 0
    }
        
}; export -f FazSeta

function Sai
{
    echo Fim na $1ª rodada
    tput cnorm
    tput sgr0
    stty echo
    exit
}

function DesenhaCaixa
{
        #  Desenha uma caixa
        #+     1o. parâmetro: Linha
        #+     2o. parâmetro: Coluna
        #+     3o. parâmetro: Altura
        #+     4o. parâmetro: Largura
        #  Author: Julio Neves

    local i
    local Largura=$4
    printf -v Linha "%${Largura}s" ' '     # Cria $Largura espaços em $Linha
    printf -v Traco "\e(0\x71\e(B"         # Põe um traço semigráfico em $Traco
    tput cup $1 $2; printf "\e(0\x6c\e(B"  # Canto superior esquerdo
    echo -n ${Linha// /$Traco}             # Troca todos os espaços de $Linha por $Traco
    printf "\e(0\x6b\e(B\n"                # Canto superior direito
    for  ((i=1; i<=$3; i++))               # Construindo altura
    do
        tput cup $(($1+i)) $2 
        printf "\e(0\x78\e(B"               # Barra vertical esquerda
        printf %${Largura}s"\e(0\x78\e(B\n" # Barra vertical direita
    done
    printf -v linha "%${Largura}s" ' '
    printf -v traco "\e(0\x71\e(B"
    tput cup $(($1+i)) $2; printf "\e(0\x6d\e(B"
    echo -n ${Linha// /$Traco}             # Troca todos os espaços de $Linha por $Traco
    printf "\e(0\x6a\e(B\n"
}; export -f DesenhaCaixa

trap "Sai $i" 2 3 15 
tput civis
FazSeta A 0 0
FazSeta B 0 0
FazSeta C 0 0
FazSeta D 0 0
DesenhaCaixa $((LinhaMeio-3)) $((ColunaMeio-6)) 5 13
tput cup $((LinhaMeio-1)) $((ColunaMeio-2)); echo JOGANDO
tput cup $((LinhaMeio+1)) $((ColunaMeio)); echo VEZ
i=0
while :
do
    Vez=$((RANDOM%4+1))
    Vez=$(cut -c$Vez <<< ABCD)
    TudoComp[++i]=$Vez
    tput cup $((LinhaMeio)) $((ColunaMeio-1)); printf "a %02dª" $i
    for Jogada in ${TudoComp[@]}
    do
        FazSeta $Jogada 1 1
        FazSeta $Jogada 0 0; sleep .2
    done
    read -t0.1 -n10000 lixo
    for ((j=1; j<=i; j++))
    {
        while true
        do
            read -sn2 -t120 a || Sai ${1:-0}
            read -sn1 Ult
            [[ $(cat -vet <<< $a) == ^[[$ ]] && break
            a=; Ult=
            DesenhaCaixa $(($(tput lines)-5)) $((($(tput cols)-25)/2)) 2 30
            tput cup $(($(tput lines)-4)) $((($(tput cols)-14)/2)); echo "Use somente as setas"
            tput cup $(($(tput lines)-3)) $((($(tput cols)-14)/2)); echo "  Tecle <ENTER>..."
            read
            tput cup $(($(tput lines)-5)) 0; tput ed
        done
        [[ $Ult != ${TudoComp[j]} ]] && {
            Sai $i
        }
        FazSeta $Ult 1 1
        FazSeta $Ult 0 0; sleep .2
    }
    sleep .6
done
