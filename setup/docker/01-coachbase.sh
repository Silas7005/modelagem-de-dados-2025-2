#!/bin/bash
set -e

echo "============================================================"
echo "    Iniciando script de instalação do Docker e Couchbase    "
echo "============================================================"

echo "\n---> [Passo 1/7] Atualizando os pacotes do sistema..."
sudo apt-get update
sudo apt-get upgrade -y

echo "\n---> [Passo 2/7] Instalando dependências necessárias..."
sudo apt-get install -y ca-certificates curl gnupg

echo "\n---> [Passo 3/7] Adicionando a chave GPG oficial do Docker..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "\n---> [Passo 4/7] Configurando o repositório do Docker..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


echo "\n---> [Passo 5/7] Instalando o Docker Engine..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "\n---> [Passo 6/7] Adicionando o usuário atual ao grupo 'docker'..."
sudo usermod -aG docker $USER
echo "!!! AVISO: Você precisa sair e fazer login novamente para usar o Docker sem 'sudo'."

echo "\n---> [Passo 7/7] Baixando e subindo o container do Couchbase Server..."

echo "Criando volume 'couchbase-data' para persistência de dados..."
docker volume create couchbase-data

docker run -d --name couchbase-server \
  -p 8091-8096:8091-8096 \
  -p 11210:11210 \
  -v couchbase-data:/opt/couchbase/var \
  couchbase
