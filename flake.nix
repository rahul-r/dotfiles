{
  description = "Nix configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixgl,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;
      system = "x86_64-linux";
      username = "rahul";
    in
    {
      homeConfigurations."blackhole" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
          config.allowUnfreePredicate = (_: true);
          overlays = [ nixgl.overlay ];
        };
        modules = [ ./home/linux.nix ];
        extraSpecialArgs = {
          inherit inputs outputs;
          username = username;
          dotfiles_repo_path  = "/home/${username}/.dotfiles";
        };
      };
      homeConfigurations."macbook" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          config.allowUnfree = true;
          config.allowUnfreePredicate = (_: true);
        };
        modules = [ ./home/darwin.nix ];
        extraSpecialArgs = {
          inherit inputs outputs;
          username = username;
          dotfile_repo_path  = "/Users/${username}/.dotfiles";
        };
      };
    };
}
