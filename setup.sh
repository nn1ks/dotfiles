#!/bin/sh

set -x

dconf load / < "$HOME/.dconf-dump"

git clone https://github.com/alexherbo2/plug.kak "$HOME/.config/kak/autoload/plugins/plug"

mkdir "$HOME/src"

git clone https://gitlab.redox-os.org/redox-os/ion "$HOME/src/ion"
cd "$HOME/src/ion"
mkdir custom-bin
echo "(manifest->specifications\n" > manifest.scm
echo "  '(\"gcc-toolchain\")" >> manifest.scm
guix environment -m manifest.scm
ln -s "$(which gcc)" custom-bin/cc
export PATH="$HOME/src/ion/custom-bin:$PATH"
cargo build --release
cargo install

git clone https://github.com/rust-analyzer/rust-analyzer "$HOME/src/rust-analyzer"
cd "$HOME/src/rust-analyzer"
cargo xtask install --server
