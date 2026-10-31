{
  description = "Niri config";

  inputs = {
    nix-config.url = "github:KiLoBO/nix-config/dendritic-migration";
    nixpkgs.follows = "nix-config/nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nix-config,
      nixpkgs,
      home-manager,
      catppuccin,
      noctalia,
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
          niri.nixosModules.niri
          nix-config.nixosModules.universal
          stylix.nixosModules.stylix
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
                nix-config.homeManagerModules.universal
                nix-config.modules.homeManager.dms-base
                nix-config.modules.homeManager.noctalia-base
                inputs.dms.homeModules.niri
                ./home-niri.nix
              ];
            };
          }
        ];
      };
    };
}
