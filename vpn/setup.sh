#!/bin/bash

#Initialize the configuration files and certificates
docker-compose run --rm openvpn ovpn_genconfig -u udp://VPN.SERVERNAME.COM
docker-compose run --rm openvpn ovpn_initpki

#Fix ownership (depending on how to handle your backups, this may not be needed)
sudo chown -R $(whoami): ./openvpn-data

#Start OpenVPN server process
docker-compose up -d openvpn

#You can access the container logs with
#docker-compose logs -f
