#!/usr/bin/env bash

CWD=$(pwd)
XDG_CONFIG_HOME="$HOME/.config"

INSTALL="nix-env -i"
EXTRA_PACKAGES=""

$INSTALL neovim ripgrep fd lazygit tmux fzf podman podman-compose qemu neovide
# brew install openssl

# Install nvm
if [ -d $HOME/.nvm ]; then
	echo "nvm is already installed, skipping installation"
else
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi
. ~/.profile
nvm install node || true
npm install -g yarn || true

# Install rust
if [ -d $HOME/.cargo ]; then
	echo "rust is already installed, skipping installation"
else
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

# Install nerd font
curl -OL https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/DroidSansMono.zip
unzip DroidSansMono.zip -d $HOME/Library/Fonts
rm DroidSansMono.zip

# Install providers for nvim
python3 -m pip install --user --upgrade pynvim
yarn global add neovim
# Use nvim as default editor for git
git config --global core.editor "nvim"

## Install .profile and .aliases
#ln -s ${CWD}/shell/profile ~/.profile
ln -s ${CWD}/shell/aliases ~/.aliases

# Setup zsh
ZSH_DIR=~/.zsh
ln -s ${CWD}/shell/zsh/zshrc ~/.zshrc
ln -s ${CWD}/shell/zsh/zprofile ~/.zprofile

for config_file in ${CWD}/shell/zsh/*.zsh; do
	ln -s $config_file ${ZSH_DIR}/$(basename $config_file)
done

# Install zsh plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_DIR/syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_DIR/zsh-autosuggestions

# don't print any messages when opening terminal
touch ~/.hushlogin

## Install tmux conf
mkdir -p $XDG_CONFIG_HOME/tmux
ln -s ${CWD}/shell/tmux/tmux.conf $XDG_CONFIG_HOME/tmux/tmux.conf

## Install tmux plugin manager
rm -rf $XDG_CONFIG_HOME/tmux/plugins/tpm
mkdir -p $XDG_CONFIG_HOME/tmux/plugins
git clone https://github.com/tmux-plugins/tpm $XDG_CONFIG_HOME/tmux/plugins/tpm

## alacritty
ln -s $CWD/shell/alacritty $XDG_CONFIG_HOME/alacritty

ln -s ${CWD}/nvim $XDG_CONFIG_HOME/nvim
