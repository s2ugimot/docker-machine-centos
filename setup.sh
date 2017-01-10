#!/bin/bash
set -eu
set -x

docker-machine create --driver generic --generic-ip-address 192.168.99.100 --generic-ssh-user vagrant --generic-ssh-key id_rsa default
