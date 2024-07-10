## Use nix shell

Run the following command  to activate a shell
```shell
nix develop ~/.dotfiles/shell/gleam
```

## Use nix shell with direnv

Create `.envrc` with the following content
```shell
use flake ~/.dotfiles/shell/gleam
```

