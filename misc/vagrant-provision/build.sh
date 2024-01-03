#!/bin/sh

# install crystal
set -e
set -u

USER="$(test -d /vagrant && echo "vagrant" || echo "debian")"
HOSTNAME="$(hostname)"

export DEBIAN_FRONTEND=noninteractive

echo "Installing mfm requirements"
apt-get install -y \
   fzf \
   sshfs \
   httpdirfs \
   libyaml-0-2 \
   libyaml-dev \
   libpcre3-dev \
   libevent-dev

# Installing asdf
su - "$USER" -c "git config --global advice.detachedHead false"
su - "$USER" -c "rm -rf ~/.asdf"
su - "$USER" -c "git clone --quiet https://github.com/asdf-vm/asdf.git \
					~/.asdf \
					--branch v0.8.0"
su - "$USER" -c "echo '. \$HOME/.asdf/asdf.sh' >> ~/.bashrc"

su - "$USER" -c "source \$HOME/.asdf/asdf.sh \
				 && asdf plugin add crystal 2>&1 \
				 && asdf install crystal 1.7.3 >/dev/null 2>&1 \
 				 && asdf global  crystal 1.7.3"

