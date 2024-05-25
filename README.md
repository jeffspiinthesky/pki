# Certificate Signing Scripts

Become your own certificate authority using these scripts!!

## Create your own Certificate Authority (CA)
Run the script to create your CA and provide the answers to the questions it asks:
```
./create_ca_cert.sh
```
After that's done, make sure you keep the files `./conf/orgs.conf`, `./private_keys/rootCA.key`, and `./public_keys/rootCA.crt` safe. If you delete them, you'll need to start from scratch again and you won't be able to create new certificates for your servers or clients.

## Create certificates for your servers
Run the script to create a certificate pair for your server (e.g. a web server) and answer the questions it asks you:
```
./create_server_cert.sh
```
After that's done, in your server config, provide the server private and public keys along with the CA public key. For example, for NGINX:
```
server_name			jpits.ddns.net;
ssl_certificate                 /etc/ssl/jpits.ddns.net.crt;
ssl_certificate_key             /etc/ssl/jpits.ddns.net.key;
ssl_client_certificate          /etc/ssl/rootCA.crt;
```

## Create certificates for your clients
Run the script to create a certificate pair for your clients along with a certificate in P12 format that you can import into a browser
```
./create_client_cert.sh
```
Once complete, import `./client_keys/<name>.p12` into your browser as a client certificate and import the CA public key as an authority. After that, restart your browser and access your site! It should prompt you for which certificate to use to authenticate.
