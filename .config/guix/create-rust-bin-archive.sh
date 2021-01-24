#!/usr/bin/env bash

set -e

date="2020-12-31"
version="1.49.0"
arch="x86_64-unknown-linux-gnu"
base_url="https://static.rust-lang.org/dist/$date"

download_dir="$HOME/.cache/guix-rust-bin"
target_name="rust-bin-$version-$arch"

if [ -e "$download_dir" ]; then
    printf "%s" "Download directory at \"$download_dir\" already exists. Replace? [y/N] "
    read input
    if [ "$input" = "y" ] || [ "$input" = "Y" ]; then
        rm -r "$download_dir"
    else
        exit 0
    fi
fi

mkdir -p $download_dir/$target_name/{bin,lib,etc,share}

install-component() {
    if [ "$1" = "--url-no-arch" ]; then
        shift
        component="$1-$version"
    else
        component="$1-$version-$arch"
    fi
    wget "$base_url/$component.tar.gz" -P "$download_dir"
    tar xf "$download_dir/$component.tar.gz" -C "$download_dir"
    for subdir in bin etc lib share; do
        source_dir="$download_dir/$component/${2:-${1}}/$subdir"
        [ ! -d "$source_dir" ] && continue
        rsync -av "$source_dir" "$download_dir/$target_name"
    done
}

install-component rustc
install-component cargo
install-component rust-std rust-std-$arch
install-component rust-docs
install-component rustfmt rustfmt-preview
install-component clippy clippy-preview
#install-component rust-analyzer rust-analyzer-preview
install-component --url-no-arch rust-src
#install-component llvm-tools llvm-tools-preview
install-component rust-analysis
#install-component miri miri-preview

cd "$download_dir"
tar czvf "$target_name.tar.gz" "$target_name"
fd --max-depth 1 --exclude "$target_name.tar.gz" --exec rm -r {}
cd -

guix download "file://$download_dir/$target_name.tar.gz"
