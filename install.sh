#!/bin/bash

apt-get update
curl -sSL https://get.docker.com | sh
apt-get install vim docker-compose git ntfs-3g
git clone https://github.com/hdoedens/pihub.git
cd pihub/dsmr-reader
docker-compose up