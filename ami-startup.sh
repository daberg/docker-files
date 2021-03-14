#!/bin/bash

WEBSITE_ROOT='/srv/daberg.info'
CADDY_FOLDER='/srv/caddy'

#--- Environment variables ---#

COMPOSE_PROJECT_NAME='docker-services'

LETSENCRYPT_FOLDER='/srv/acme'
CERTIFICATES_FOLDER='/srv/certs'

CADDY_ROOT="${WEBSITE_ROOT}"
CADDY_DATA="${CADDY_FOLDER}/data"
CADDY_CONFIG="${CADDY_FOLDER}/config"
CADDY_DOMAIN='daberg.info'

GITEA_DATA='/srv/gitea'
GITEA_DOMAIN='git.daberg.info'
GITEA_URL="https://${GITEA_DOMAIN}"
GITEA_NAME="daberg's gitea"

#-----------------------------#

function write_env {
    var=$1
    val=$(eval echo \$$1)
    echo "${var}=\"${val}\"" >> .env
}

yum update -y

# Install Git
yum install git -y

# Install Docker
amazon-linux-extras install docker
systemctl enable docker
systemctl start docker

# Install Docker Compose
curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Fetch Docker files
mkdir -p /srv && cd /srv
git clone https://github.com/daberg/docker-files
cd docker-files

write_env COMPOSE_PROJECT_NAME
write_env LETSENCRYPT_FOLDER
write_env CERTIFICATES_FOLDER
write_env CADDY_ROOT
write_env CADDY_DATA
write_env CADDY_CONFIG
write_env CADDY_DOMAIN
write_env GITEA_DATA
write_env GITEA_DOMAIN
write_env GITEA_URL
write_env GITEA_NAME

mkdir -p $CERTIFICATES_FOLDER
mkdir -p $LETSENCRYPT_FOLDER
openssl req \
       -subj "/C=GB/CN=daberg.info" \
       -newkey rsa:4092 -nodes -keyout "${CERTIFICATES_FOLDER}/certificate.key" \
       -x509 -days 365 -out "${CERTIFICATES_FOLDER}/certificate.crt"

mkdir -p "$CADDY_FOLDER"
mkdir -p "$CADDY_ROOT"
useradd -r -s /usr/sbin/nologin caddy
CADDY_UID=$(id -u caddy)
CADDY_GID=$(id -g caddy)
write_env CADDY_UID
write_env CADDY_GID

useradd -r -s /usr/sbin/nologin gitea
mkdir -p "$GITEA_DATA"
GITEA_UID=$(id -u gitea)
GITEA_GID=$(id -g gitea)
write_env GITEA_UID
write_env GITEA_GID

# Spin up containers
docker-compose pull
docker-compose up -d
