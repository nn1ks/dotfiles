export EDITOR="kak"
export VISUAL="kak"
export PAGER="less -R"

export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

export GUIX_PACKAGE_PATH="$HOME/.config/guix/packages"
# export XDG_DATA_DIRS="$HOME/.local/share/flatpak/exports/share:$XDG_DATA_DIRS"
export XDG_DATA_DIRS="$HOME/.local/share/custom/exports/share:$XDG_DATA_DIRS"

# Include .bashrc if it exists
[ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
