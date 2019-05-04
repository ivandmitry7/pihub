#!/bin/bash

#Generate a client certificate
export CLIENTNAME=$0

# with a passphrase (recommended)
docker-compose run --rm openvpn easyrsa build-client-full $CLIENTNAME

# without a passphrase (not recommended)
#docker-compose run --rm openvpn easyrsa build-client-full $CLIENTNAME nopass

#Retrieve the client configuration with embedded certificates
docker-compose run --rm openvpn ovpn_getclient $CLIENTNAME > $CLIENTNAME.ovpn

#Revoke a client certificate
# Keep the corresponding crt, key and req files.
docker-compose run --rm openvpn ovpn_revokeclient $CLIENTNAME

# Remove the corresponding crt, key and req files.
docker-compose run --rm openvpn ovpn_revokeclient $CLIENTNAME remove