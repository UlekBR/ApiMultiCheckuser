#!/bin/bash

# Definição das cores para o terminal
cor_vermelha='\033[91m'
cor_verde='\033[92m'
cor_amarela='\033[93m'
cor_azul='\033[94m'
cor_reset='\033[0m'

# Função para obter o IP público
get_public_ip() {
    url="https://api.ipify.org"
    response=$(curl -s "$url")
    echo "$response"
}

# Função para verificar se o processo está rodando
verificar_processo() {
    if ps aux | grep -v grep | grep -q "apicheck"; then
        return 1
    else
        return 0
    fi
}

# Loop do menu principal
while true; do
    clear
    echo -e "API-CHECKUSER"

    # Verifica o status do processo
    if verificar_processo; then
        status="${cor_verde}ativo${cor_reset}"
        acao="Parar"
        
        # Verifica se o arquivo /opt/api/port existe antes de tentar exibir o link
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

    # Exibe o status e o link de sincronização (se existir)
    echo -e "Status: $status"

    if [[ -n "$link_sinc" ]]; then
        echo -e "\n$link_sinc"
    fi

    # Exibe o menu de opções
    echo -e "\nSelecione uma opção:"
    echo -e " 1 - $acao API"
    echo -e " 2 - Sobre"
    echo -e " 0 - Sair do menu"

    # Recebe a opção do usuário
    read -p "Digite a opção: " option

    # Ação conforme a opção selecionada
    case $option in
    "1")
        if verificar_processo; then
            # Se o processo estiver rodando, para o serviço
            sudo systemctl stop apicheck.service
            sudo systemctl disable apicheck.service
            sudo rm /etc/systemd/system/apicheck.service
            sudo systemctl daemon-reload
            rm -f /opt/api/port
            echo -e "\nServiço API-CHECKUSER parado e removido."
        else
            # Se o processo não estiver rodando, inicia o serviço
            read -p $'\nDigite a porta que deseja usar: ' port
            echo "$port" > /opt/api/port

            clear
            echo -e "Porta escolhida: $port"

            # Criação do arquivo de serviço
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
            echo -e "\nServiço API-CHECKUSER iniciado na porta $port."
        fi
        echo -e "\nO Link estará no Menu."
        read -p "Pressione a tecla enter para voltar ao menu."
        ;;
    "2")
        # Exibe informações sobre o sistema ou API
        clear
        echo -e "Sobre: API-CHECKUSER\n\nDescrição do sistema: Este é um serviço de verificação de usuário.\n"
        read -p "Pressione a tecla enter para voltar ao menu."
        ;;
    "0")
        # Sai do script
        exit 0
        ;;
    *)
        # Caso o usuário insira uma opção inválida
        clear
        echo -e "Opção inválida. Tente novamente!"
        read -p "Pressione a tecla enter para voltar ao menu."
        ;;
    esac
done
