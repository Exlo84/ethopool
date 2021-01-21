#!/bin/bash


# **********************************************************
#                     Modules and Running                  #
# **********************************************************

cd www
sudo chmod -R 777 . #Permission issues
sudo npm install ember-cli@^2.18.2
sudo npm install bower
sudo chown -R $USER:$GROUP ~/.npm
sudo chown -R $USER:$GROUP ~/.config
sudo npm install
sudo bower install --allow-root
sudo npm i intl-format-cache

sudo ./build.sh

sudo ember server

