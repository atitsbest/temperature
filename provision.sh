#!/usr/bin/env bash

# The DEBIAN_FRONTEND=noninteractive setting will prevent dialogs that ask you to enter settings while installing and/or updating packages and will use the default instead, you’ll need this setting because you can’t interactively answer these prompts when the Vagrant provisioner runs.
export DEBIAN_FRONTEND=noninteractive
apt-get -y update > /dev/null
sudo apt-get -y remove ruby
sudo apt-get -y install \
  build-essential \
  zlib1g-dev \
  curl \
  git-core \
  sqlite3 \
  libsqlite3-dev \
  postgresql-9.1 \
  postgresql-client-9.1 \
  postgresql-server-dev-9.1 \
  imagemagick \
  nginx

# Rbenv installieren
cd /home/$SUDO_USER
git clone https://github.com/sstephenson/rbenv.git .rbenv \
  && echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> /home/$SUDO_USER/.bash_profile \
  && echo 'eval "$(rbenv init -)"' >> /home/$SUDO_USER/.bash_profile \
  && echo 'Rbenv installed.'

# Ruby-build
git clone https://github.com/sstephenson/ruby-build.git /home/$SUDO_USER/.rbenv/plugins/ruby-build

# Set permissions
chown -R $SUDO_USER /home/$SUDO_USER/.rbenv
chgrp -R $SUDO_USER /home/$SUDO_USER/.rbenv
chown -R $SUDO_USER /home/$SUDO_USER/.bashrc
chgrp -R $SUDO_USER /home/$SUDO_USER/.bashrc


# Ruyb installieren
su - $SUDO_USER -c "rbenv install 2.0.0-p247"
su - $SUDO_USER -c "rbenv rehash"
su - $SUDO_USER -c "rbenv global 2.0.0-p247"
su - $SUDO_USER -c "rbenv rehash"

# Rails installieren
su - $SUDO_USER -c "gem install bundler --no-ri --no-rdoc"
su - $SUDO_USER -c "rbenv rehash"

su - $SUDO_USER -c "gem install rails --no-ri --no-rdoc"
su - $SUDO_USER -c "rbenv rehash"

# Postgresql Benutzer und DB anlegen
sudo pg_dropcluster --stop 9.1 main
sudo pg_createcluster --start --locale en_US.UTF-8 9.1 main
sudo -u postgres createuser -d -s -R temperature
sudo -u postgres psql -U postgres -d postgres -c "alter user temperature with password 'TemperatuRe'"
sudo -u postgres createdb -O temperature temperature_development
sudo -u postgres createdb -O temperature temperature_test
sudo -u postgres createdb -O temperature temperature_production

