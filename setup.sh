#!/bin/bash

if ! [ $(id -u) = 0 ]; then
   echo "This script should be run as root. Aborting..."
   exit 1
fi

echo -n "Setting up configuration files..."

# Setting up .env file for docker-compose configuration
cp ./templates/general .env
chmod 600 .env

# Setting up environment variables files for services
mkdir -p .servenv
cp ./templates/*env -t ./.servenv
chmod 700 .servenv
chmod 600 .servenv/*env

PASSWD=`openssl rand -base64 24 | cut -c1-16 | sed 's/\//a/g'`

echo "DB_PASSWORD=$PASSWD" >> ./.servenv/nc-env
echo "POSTGRES_PASSWORD=$PASSWD" >> ./.servenv/nc-db-env

echo " done."
echo
echo "Specific environment variables must be set in the .env file before\
 running containers."
