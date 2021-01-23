#!/bin/sh

set -x

dconf load / < "$HOME/.dconf-dump"

git clone https://github.com/alexherbo2/plug.kak "$HOME/.config/kak/autoload/plugins/plug"
