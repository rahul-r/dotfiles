#!/usr/bin/env bash

set -e

. /etc/os-release

INSTALL="apt-get install -y"
EXTRA_PACKAGES=""

if [ "$ID" = "opensuse-tumbleweed" ]; then
    sudo zypper refresh
    INSTALL="zypper install -y"
    EXTRA_PACKAGES="fd"
elif [ "$ID" = "fedora" ]; then
    sudo dnf update
    INSTALL="dnf install -y"
    EXTRA_PACKAGES="fd-find"
elif [ "$ID" = "ubuntu" ]; then
    sudo apt-get update
    INSTALL="apt-get install -y"
    EXTRA_PACKAGES="fd-find"
fi

sudo $INSTALL unzip tmux

# Install nvm and nodejs
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
. ~/.bashrc
npm install node
npm install -g yarn

# Install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Clipboard access
sudo $INSTALL xsel
# Clipboard access when running ssh
wget https://github.com/lemonade-command/lemonade/releases/download/v1.1.1/lemonade_linux_amd64.tar.gz
tar -xvf lemonade_linux_amd64.tar.gz -C ~/bin
rm lemonade_linux_amd64.tar.gz

# Language servers, linters, formetters, etc.
sudo $INSTALL clang-tools cppcheck ripgrep $EXTRA_PACKAGES
pip install yamllint black flake8 beautysh mdformat cmake-format pynvim
yarn global add eslint jsonlint tsc markdownlint-cli stylelint @fsouza/prettierd neovim
~/bin/go/bin/go install golang.org/x/tools/cmd/goimports@latest

# Lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep '"tag_name":' |  sed -E 's/.*"v*([^"]+)".*/\1/')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
sudo tar xf lazygit.tar.gz -C /usr/local/bin lazygit
rm lazygit.tar.gz

# Install patched font
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts && curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf
