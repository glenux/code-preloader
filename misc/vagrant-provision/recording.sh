#!/bin/sh

# install crystal
set -e
set -u

USER="$(test -d /vagrant && echo "vagrant" || echo "debian")"
HOSTNAME="$(hostname)"

export DEBIAN_FRONTEND=noninteractive

echo "Installing required system packages"
apt-get update --allow-releaseinfo-change

echo "Installing recording requirements"
apt-get install -y \
   tmux \
   mdp \
   bat \
   asciinema \
   termtosvg

