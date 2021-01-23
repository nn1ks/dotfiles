#!/bin/sh

set -x

dconf load / < "$HOME/.dconf-dump"

git clone https://github.com/alexherbo2/plug.kak "$HOME/.config/kak/autoload/plugins/plug"

mkdir "$HOME/src"

git clone https://github.com/rust-analyzer/rust-analyzer "$HOME/src/rust-analyzer"
cd "$HOME/src/rust-analyzer"
cargo xtask install --server
