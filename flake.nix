{
  description = "Pinned T3 Code desktop nightly, updated from upstream releases";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      package = pkgs.callPackage ./package.nix { };
    in {
      homeManagerModules.default = import ./home-manager.nix {
        defaultPackage = package;
      };

      packages.${system} = {
        t3code-desktop-nightly = package;
        default = package;
      };

      checks.${system}.desktop-launcher = pkgs.runCommand "t3-nightly-desktop-check" {
        nativeBuildInputs = [ pkgs.desktop-file-utils ];
      } ''
        desktop=${package}/share/applications/com.t3tools.T3Code.desktop
        desktop-file-validate "$desktop"
        grep -Fx 'NoDisplay=false' "$desktop"
        grep -Fx 'Exec=${package}/bin/t3code-desktop-nightly --no-sandbox %U' "$desktop"
        test -x ${package}/bin/t3code-desktop-nightly
        test -f ${package}/share/icons/hicolor/512x512/apps/t3code-nightly.png
        touch "$out"
      '';
    };
}
