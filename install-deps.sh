#!/usr/bin/env bash

# Clipboard access
sudo apt install xsel
# Clipboard access when running ssh
weget https://github.com/lemonade-command/lemonade/releases/download/v1.1.1/lemonade_linux_amd64.tar.gz
tar -xvf lemonade_linux_amd64.tar.gz -C ~/bin
rm lemonade_linux_amd64.tar.gz

# Language servers, linters, formetters, etc.
sudo apt install clang-format cppcheck fd-find, ripgrep
pip install yamllint black flake8 beautysh mdformat cmake-format pynvim
yarn global add eslint jsonlint tsc markdownlint-cli stylelint @fsouza/prettierd neovim
go install golang.org/x/tools/cmd/goimports@latest

# Some plugins require unzip (e.g. lsp clangd)
sudo apt install unzip

# Install patched font
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts && curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf
