{
  description = "Pulsedeck hardware monitor dashboard";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          # Ruby 4.0 ships Bundler 4.x; the separate bundler package (2.7) conflicts with it.
          packages = [ pkgs.ruby_4_0 ];
          shellHook = ''
            export BUNDLE_PATH="$PWD/vendor/bundle"
          '';
        };
      });
    };
}
