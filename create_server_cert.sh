#!/bin/bash -e

./common.sh

if [ ! -f "./conf/orgs.conf" -o ! -f "./private_keys/rootCA.key" -o ! -f "./public_keys/rootCA.crt" ]
then
	echo "You need to set up your CA information before creating a server certificate"
	exit 1
fi

. ./conf/orgs.conf
export SHORT_ORG COUNTRY STATE CITY ORGANISATION OU EMAIL PASSWORD

# Ask for the info we need
echo -n "What domain do you want to create a certificate for (e.g. my-domain.ddns.net): "
read DOMAIN
echo -n "How long (in days) do you want the certificate to last for (e.g. 3650 for 10 years): "
read DURATION

export DOMAIN

# These two variables I don't want to substitute so I'm setting them to literal strings
export FQDN='$FQDN'
export ALTNAMES='$ALTNAMES'

# Set up the configuration files for the certificate creation
envsubst < ./templates/domain-csr-req.templ > ./conf/domain-csr-req.conf
envsubst < ./templates/domain.templ > ./conf/domain.ext

# Generate the password key for the server
openssl genrsa -aes256 -out ./private_keys/${DOMAIN}-pass.key -passout pass:${PASSWORD} 2048

# Generate the private key for the server
openssl rsa -passin pass:${PASSWORD} -in ./private_keys/${DOMAIN}-pass.key -out ./private_keys/${DOMAIN}.key

# Create the certificate signing request
openssl req -config ./conf/domain-csr-req.conf -passin pass:${PASSWORD} -key ./private_keys/${DOMAIN}-pass.key -new -out ./private_keys/${DOMAIN}-csr.key
rm -f ./private_keys/${DOMAIN}-pass.key

# Sign the request with the CA certificate to form the server key
openssl x509 -req -CA ./public_keys/rootCA.crt -CAkey ./private_keys/rootCA.key -in ./private_keys/${DOMAIN}-csr.key -out ./public_keys/${DOMAIN}.crt -days ${DURATION} -CAcreateserial -extfile ./conf/domain.ext -passin pass:${PASSWORD}

# Delete the CSR
rm -f ./private_keys/${DOMAIN}-csr.key
