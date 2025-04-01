#!/bin/bash


mkdir /opt
mkdir /opt/api

apt update -y && apt upgrade -y
apt install curl -y

arch=$(uname -m)

if [[ $arch == "x86_64" || $arch == "amd64" || $arch == "x86_64h" ]]; then
    echo "Sistema baseado em x86_64 (64-bit Intel/AMD)"
    curl -o "/opt/api/apicheck" -f "https://raw.githubusercontent.com/UlekBR/ApiMultiCheckuser/main/x86"
elif [[ $arch == "aarch64" || $arch == "arm64" || $arch == "armv8-a" ]]; then
    echo "Sistema baseado em arm64 (64-bit ARM)"
    curl -o "/opt/api/apicheck" -f "https://raw.githubusercontent.com/UlekBR/ApiMultiCheckuser/main/arm"
else
    echo "Arquitetura não reconhecida: $arch"
    return
fi

curl -o "/opt/api/menu.sh" -f "https://raw.githubusercontent.com/UlekBR/ApiMultiCheckuser/main/menu.sh"

chmod +x /opt/api/rtcheck
chmod +x /opt/api/menu.sh

ln -s /opt/api/menu.sh /usr/local/bin/apicheck
clear
echo -e "Para iniciar o menu digite: apicheck"

