Install nix and home-manager
```sh
git clone https://github.com/rahul-r/dotfiles ~/.dotfiles
cd ~/.dotfiles
./install.sh
```
Run the following command to apply home-manager changes
```sh
home-manager switch --flake ~/.dotfiles
```
