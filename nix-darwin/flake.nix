{
  description = "iam's nix-darwin configs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      nix-darwin,
      ...
    }:
    let
      env = import ./env.nix;
      pkgs = import nixpkgs {
        system = env.system;
        config.allowUnfree = true;
      };
    in
    {
      darwinConfigurations = {
        ${env.hostname} = nix-darwin.lib.darwinSystem {
          modules = [

            {
              system = {
                stateVersion = 5;
                primaryUser = env.user;
              };

              nix = {
                enable = false;
                settings = {
                  experimental-features = "nix-command flakes";
                };
              };

              nixpkgs = {
                hostPlatform = env.system;
              };

              users.users.${env.user} = {
                name = env.user;
                home = /Users/${env.user};
              };

              environment = {
                systemPath = [ "/opt/homebrew/bin" ];
                pathsToLink = [ "/Applications" ];
                defaultPackages = import ./packages.nix pkgs;
              };

              imports = [
                (import ./brew.nix)
                (import ./fonts.nix pkgs)
                (import ./shell.nix pkgs)
                (import ./system.nix)
              ];

            }
          ];
        };
      };
    };
}
