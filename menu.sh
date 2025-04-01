#!/bin/bash

# Definição das cores para o terminal
cor_vermelha='\033[91m'
cor_verde='\033[92m'
cor_amarela='\033[93m'
cor_azul='\033[94m'
cor_reset='\033[0m'

get_public_ip() {
    url="https://api.ipify.org"
    response=$(curl -s "$url")
    echo "$response"
}

verificar_processo() {
    if [ -f /opt/api/port ] && [ -s /opt/api/port ]; then
        port=$(cat /opt/api/port)
        if ss -tuln | grep ":$port" > /dev/null; then
            return 0  # Processo ativo na porta
        else
            return 1  # Processo não está rodando na porta
        fi
    else
        return 1  # Arquivo de porta vazio ou inexistente
    fi
}

# Loop do menu principal
while true; do
    clear
    echo -e "API-CHECKUSER"

    if verificar_processo; then
        status="${cor_verde}ativo${cor_reset}"
        acao="Parar"
        

        if [ -f /opt/api/port ]; then
            link_sinc="Link: http://$(get_public_ip):$(cat /opt/api/port)"
        else
            link_sinc=""
        fi
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
    echo -e " 1 - $acao API"
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
            rm -f /opt/api/port
            clear
            echo -e "\nServiço parado"
        else
            read -p $'\nDigite a porta que deseja usar: ' port
            echo "$port" > /opt/api/port

            clear
            echo -e "Porta escolhida: $port"

            echo "[Unit]
Description=CheckuserApiService
After=network.target

[Service]
Type=simple
ExecStart=/opt/api/apicheck
Restart=always

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/apicheck.service > /dev/null

            sudo systemctl daemon-reload
            sudo systemctl enable apicheck.service
            sudo systemctl start apicheck.service 2>/dev/null
            clear
            echo -e "\nO Link estará no Menu."
        fi
        read -p "Pressione a tecla enter para voltar ao menu."
        ;;
    "2")
        clear
        echo -e "Sobre: API-CHECKUSER\n\nDescrição do sistema: Este é um serviço de verificação de usuário.\n"
        read -p "Pressione a tecla enter para voltar ao menu."
        ;;
    "0")
        exit 0
        ;;
    *)
        clear
        echo -e "Opção inválida. Tente novamente!"
        read -p "Pressione a tecla enter para voltar ao menu."
        ;;
    esac
done
