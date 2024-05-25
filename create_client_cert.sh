#!/bin/bash -e

./common.sh

# Grab all the organisation info
# Read in orgs.conf
. ./conf/orgs.conf
# Export all the params
export SHORT_ORG COUNTRY STATE CITY ORGANISATION OU EMAIL PASSWORD

# Ask for the info we need
echo -n "What is the name of the user (e.g. Bob Davies): "
read NAME
HYPHENED_NAME=$(echo ${NAME} | sed 's/ /-/g')
echo -n "How long (in days) do you want the certificate to last for (e.g. 3650 for 10 years): "
read DURATION
export NAME DURATION

# Create a password key
openssl genrsa -aes256 -passout pass:${PASSWORD} -out ./private_keys/${HYPHENED_NAME}.pass.key 4096

# Create the client private key using the password key
openssl rsa -passin pass:${PASSWORD} -in ./private_keys/${HYPHENED_NAME}.pass.key -out ./private_keys/${HYPHENED_NAME}.key

# Remove the password key
rm -f ./private_keys/${HYPHENED_NAME}.pass.key

# Set up the Certificate Signing Request configuration
envsubst < ./templates/client-csr-req.templ > ./conf/client-csr-req.conf

# Create the Certificate Signing Request
openssl req -config ./conf/client-csr-req.conf -passin pass:${PASSWORD} -new -key ./private_keys/${HYPHENED_NAME}.key -out ./private_keys/${HYPHENED_NAME}-csr.key

# Create the signed public key
openssl x509 -passin pass:${PASSWORD} -req -days ${DURATION} -in ./private_keys/${HYPHENED_NAME}-csr.key -CA ./public_keys/rootCA.crt -CAkey ./private_keys/rootCA.key -set_serial "01" -extfile ./conf/client-csr-req.conf -extensions "extensions" -out ./public_keys/${HYPHENED_NAME}.crt

# Remove the Certificate Signing Request
rm -f ./private_keys/${HYPHENED_NAME}-csr.key

# Create a PEM file (combination of private key, public key and CA public key)
cat ./private_keys/${HYPHENED_NAME}.key ./public_keys/${HYPHENED_NAME}.crt ./public_keys/rootCA.crt > ./client_keys/${HYPHENED_NAME}.full.pem

# Create client key in P12 format so it can be ingested by browsers
openssl pkcs12 -export -inkey ./private_keys/${HYPHENED_NAME}.key -in ./public_keys/${HYPHENED_NAME}.crt -out ./client_keys/${HYPHENED_NAME}.p12 -passout pass:${PASSWORD}

# Remove the PEM file
rm -f ./client_keys/${HYPHENED_NAME}.full.pem
