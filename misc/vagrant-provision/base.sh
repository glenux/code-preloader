#!/bin/sh

set -e
set -u

USER="$(test -d /vagrant && echo "vagrant" || echo "debian")"
HOSTNAME="$(hostname)"

export DEBIAN_FRONTEND=noninteractive

echo "Installing required system packages"
apt-get update --allow-releaseinfo-change
apt-get install -y \
   apt-transport-https \
   ca-certificates \
   git \
   curl \
   wget \
   vim \
   gnupg2 \
   software-properties-common

# echo "Installing mfm requirements"
# apt-get install -y \
#    fzf \
#    sshfs \
#    httpdirfs \
#    libyaml-0-2 \
#    libyaml-dev \
#    libpcre3-dev \
#    libevent-dev

