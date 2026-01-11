{
  description = "Tom's Nix flake";

  inputs = {
    # NixOS official package source
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11"; # Use your current version
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    # Replace 'my-hostname' with your actual hostname (run 'hostname' to check)
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
      ];
    };
  };
}
