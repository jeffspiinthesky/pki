#!/bin/bash -e

./common.sh

# If orgs.conf doesn't exist, ask the questions we need answers to:
if [ ! -f "./conf/orgs.conf" ]
then
	echo -n "Short name for your org - no spaces!: "
	read SHORT_ORG
	echo -n "2-Country code for your country (e.g. UK): "
	read COUNTRY
	echo -n "State / County: "
	read STATE
	echo -n "Town / City: "
	read CITY
	echo -n "Organisation name (e.g. Jeffs PI In The Sky): "
	read ORGANISATION
	echo -n "Division of the organisation (e.g. YouTube): "
	read OU
	echo -n "Email address for certificate authority: "
	read EMAIL
	echo -n "Password for certificate authority: "
	read -s PASSWORD

	echo "SHORT_ORG=${SHORT_ORG}" > ./conf/orgs.conf
	echo "COUNTRY=${COUNTRY}" >> ./conf/orgs.conf
	echo "STATE=${STATE}" >> ./conf/orgs.conf
	echo "CITY=${CITY}" >> ./conf/orgs.conf
	echo "ORGANISATION=\"${ORGANISATION}\"" >> ./conf/orgs.conf
	echo "OU=${OU}" >> ./conf/orgs.conf
	echo "EMAIL=${EMAIL}" >> ./conf/orgs.conf
	echo "PASSWORD=${PASSWORD}" >> ./conf/orgs.conf
fi

# Read in orgs.conf
. ./conf/orgs.conf
# Export all the params
export SHORT_ORG COUNTRY STATE CITY ORGANISATION OU EMAIL PASSWORD

# Set up ca-create.conf
envsubst < ./templates/ca-create.templ > ./conf/ca-create.conf

openssl req -x509 -sha256 --config ./conf/ca-create.conf -days 3650 -newkey rsa:2048 -keyout ./private_keys/rootCA.key -out ./public_keys/rootCA.crt 
