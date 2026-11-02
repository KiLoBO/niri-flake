{
  description = "Niri config";

  inputs = {
    nix-config.url = "github:KiLoBO/nix-config";
    nixpkgs.follows = "nix-config/nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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
      noctalia,
      niri,
      ...
    }@inputs:
    {
      nixosConfigurations.nixpad = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
        };

        modules = [
          niri.nixosModules.niri
          nix-config.nixosModules.universal
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
