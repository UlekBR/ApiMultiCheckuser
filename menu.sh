#!/bin/bash

cor_vermelha='\033[91m'
cor_verde='\033[92m'
cor_amarela='\033[93m'
cor_azul='\033[94m'
cor_reset='\033[0m'

get_public_ip() {
    url="https://api.ipify.org"
    response=$(curl -s "$url")
    echo $response
}


verificar_processo() {
    if pgrep -x "apicheck" > /dev/null; then
        return 0
    else
        return 1
    fi
}


while true; do
    clear

    echo -e "API-CHECKUSER"

    if verificar_processo; then
        status="${cor_verde}ativo${cor_reset}"
        acao="Parar"
        link_sinc="Link: http://$(get_public_ip):$(cat /opt/api/port)"
    else
        status="${cor_vermelha}parado${cor_reset}"
        acao="Iniciar"
        link_sinc=""
    fi

    echo -e "Status: $status"

    if [[ -n "$link_sinc" ]]; then
        echo -e "\n$link_sinc"
    fi

    echo -e "\nSelecione uma opção:"
    echo -e " 1 - $acao api"
    echo -e " 2 - Sobre"
    echo -e " 0 - Sair do menu"

    read -p "Digite a opção: " option

    case $option in
    "1")
        if verificar_processo; then
            sudo systemctl stop apicheck.service
            sudo systemctl disable apicheck.service
            sudo rm /etc/systemd/system/apicheck.service
            sudo systemctl daemon-reload
            rm -f /opt/api/port;
        else
            read -p $'\nDigite a porta que deseja usar: ' port
            echo $port > /opt/api/port 
            
            clear
            echo -e "Porta escolhida: $port"

echo "[Unit]
Description=CheckuserApiService
After=network.target

[Service]
Type=simple
ExecStart=/opt/rt/apicheck
Restart=always

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/apicheck.service > /dev/null

            sudo systemctl daemon-reload
            sudo systemctl enable apicheck.service
            sudo systemctl start apicheck.service 2>/dev/null

        fi
        echo -e "O Link estará no Menu\n"
        read -p "Pressione a tecla enter para voltar ao menu "
        ;;
    "0")
        exit 0
        ;;
    *)
        clear
        echo -e "Selecionado uma opção invalida, tente novamente !"
        read -p "Pressione a tecla enter para voltar ao menu"
        ;;
    esac
done
