{
  description = "Pinned T3 Code desktop nightly, updated from upstream releases";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      package = pkgs.callPackage ./package.nix { };
    in {
      packages.${system} = {
        t3code-desktop-nightly = package;
        default = package;
      };
    };
}
