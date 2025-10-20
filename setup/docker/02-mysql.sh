#!/bin/bash

CONTAINER_NAME="mysql"
MYSQL_ROOT_PASSWORD="Model@2025"
MYSQL_DATABASE="crimes"
DATA_VOLUME_PATH="/var/lib/mysql-docker-data"

echo_info() {
    echo "INFO: $1"
}


if [ "$MYSQL_ROOT_PASSWORD" == "sua_senha_super_secreta_aqui" ]; then
    echo "====================================================="
    echo "!!! ATENÇÃO: Você está usando a senha padrão. !!!"
    echo "!!! Por favor, edite o script e defina uma senha forte na variável MYSQL_ROOT_PASSWORD."
    echo "====================================================="
    exit 1
fi

if [ ! -d "$DATA_VOLUME_PATH" ]; then
    echo_info "Criando diretório para dados persistentes em ${DATA_VOLUME_PATH}..."
    sudo mkdir -p "$DATA_VOLUME_PATH"
fi

if [ "$(sudo docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo_info "Parando contêiner antigo chamado ${CONTAINER_NAME}..."
    sudo docker stop $CONTAINER_NAME
fi
if [ "$(sudo docker ps -aq -f status=exited -f name=$CONTAINER_NAME)" ]; then
    echo_info "Removendo contêiner antigo chamado ${CONTAINER_NAME}..."
    sudo docker rm $CONTAINER_NAME
fi

echo_info "Iniciando o contêiner MySQL..."
sudo docker run -d \
    --name $CONTAINER_NAME \
    -p 3306:3306 \
    -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
    -e MYSQL_DATABASE=$MYSQL_DATABASE \
    -v $DATA_VOLUME_PATH:/var/lib/mysql \
    --restart=always \
    mysql:8.0 --local-infile=1

echo_info "Aguardando o MySQL iniciar..."
sleep 20

echo_info "Verificando o status do contêiner:"
sudo docker ps -f name=$CONTAINER_NAME

echo ""
echo_info "Script concluído! Seu servidor MySQL está rodando."
echo_info "Para ver os logs, use o comando: sudo docker logs ${CONTAINER_NAME}"
