#!/usr/bin/env bash

# The DEBIAN_FRONTEND=noninteractive setting will prevent dialogs that ask you to enter settings while installing and/or updating packages and will use the default instead, you'll need this setting because you can't interactively answer these prompts when the Vagrant provisioner runs.
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
  nginx \
  rubygems \
  vim


# Vorhandenes Rbenv entfernen.
rm -rf $HOME/.rbenv

# Rbenv installieren
curl https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash

# Add rbenv to the path
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc

# Load rbenv config
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# Bootstrap rbenv
rbenv bootstrap-ubuntu-12-04

# Ruyb installieren
echo 'Ruby installieren...'
rbenv install 2.0.0-p247
rbenv rehash
echo 'Ruby-Version setzten...'
rbenv global 2.0.0-p247
rbenv/bin/rbenv rehash

# Rubygems konfigurieren.
echo 'gem: --no-ri --no-rdoc' > ~/.gemrc

# Rails installieren
echo 'Rails installieren...'
sudo rbenv exec gem install bundler 
rbenv rehash
sudo rbenv exec gem install rails 
rbenv rehash

# Postgresql Benutzer und DB anlegen
sudo pg_dropcluster --stop 9.1 main
sudo pg_createcluster --start --locale en_US.UTF-8 9.1 main
sudo -u postgres createuser -d -s -R temperature
sudo -u postgres psql -U postgres -d postgres -c "alter user temperature with password 'TemperatuRe'"
sudo -u postgres createdb -O temperature temperature_development
sudo -u postgres createdb -O temperature temperature_test
sudo -u postgres createdb -O temperature temperature_production

