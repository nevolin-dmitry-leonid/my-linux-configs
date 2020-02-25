#!/bin/sh

cd tilde && cp -R . ~/ && cd ..
cd slash && sudo cp -R . / && cd ..
chmod 744 ~/.xinitrc
mkdir ~/.scrot
