{
  description = "Niri config";

  inputs = {
    nix-config.url = "github:KiLoBO/nix-config";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nix-config,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      catppuccin,
      stylix,
      niri,
      ...
    }@inputs:
    {
      nixosConfigurations.nixpad = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          pkgs-unstable = import inputs.nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        };

        modules = [
          # {
          #   nixpkgs.overlays = [
          #     niri.overlays.niri
          #   ];
          # }
          niri.nixosModules.niri
          nix-config.nixosModules.all-features
          stylix.nixosModules.stylix
          nix-config.nixosModules.catppuccin
          ./system-niri.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "bak";
            home-manager.extraSpecialArgs = {
              inherit inputs;
            };
            home-manager.users.david = {
              imports = [
                nix-config.homeModules.base
                nix-config.homeModules.dms-base
                nix-config.dms.homeModules.niri
                nix-config.homeModules.catppuccin
                ./home-niri.nix
              ];
            };
          }
        ];
      };
    };
}
