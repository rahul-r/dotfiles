{
  description = "Nix configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # firefox-addons = {
    #   url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixgl,
      neovim-nightly-overlay,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;
      system = "x86_64-linux";
      username = "rahul";
      email = "jossb6cw@duck.com";
    in
    {
      homeConfigurations."blackhole" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
          config.allowUnfreePredicate = (_: true);
          overlays = [ nixgl.overlay neovim-nightly-overlay.overlay ];
        };
        modules = [ ./machines/linux.nix ];
        extraSpecialArgs = {
          inherit inputs outputs;
          username = username;
          email = email;
          dotfiles_repo_path  = "/home/${username}/.dotfiles";
        };
      };
      homeConfigurations."macbook" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          config.allowUnfree = true;
          config.allowUnfreePredicate = (_: true);
        };
        modules = [ ./machines/darwin.nix ];
        extraSpecialArgs = {
          inherit inputs outputs;
          username = username;
          email = email;
          dotfile_repo_path  = "/Users/${username}/.dotfiles";
        };
      };
      homeConfigurations."work-wsl" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
          config.allowUnfreePredicate = (_: true);
        };
        modules = [ ./machines/work-wsl.nix ];
        extraSpecialArgs = {
          inherit inputs outputs;
          username = username;
          email = "";
          dotfiles_repo_path  = "/home/${username}/.dotfiles";
        };
      };
    };
}
