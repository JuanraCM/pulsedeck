{
  description = "Pulsedeck hardware monitor dashboard";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
      lib = nixpkgs.lib;

      fullGemset = import ./gemset.nix;
      # Same gems as the default group in Gemfile. bundix gives wrong groups, so filter here.
      runtimeGems = [ "phlex" "puma" "rackup" "sinatra" "sorbet-runtime" ];
      closure = names:
        let next = lib.unique (names ++ lib.concatMap (n: fullGemset.${n}.dependencies or [ ]) names);
        in if lib.length next == lib.length names then names else closure next;

      mkGems = pkgs: pkgs.bundlerEnv {
        name = "pulsedeck-gems";
        ruby = pkgs.ruby_4_0;
        gemdir = ./.;
        gemset = lib.getAttrs (closure runtimeGems) fullGemset;
        groups = [ "default" ];
      };
    in
    {
      packages = forAllSystems (pkgs:
        let gems = mkGems pkgs;
        in {
          default = pkgs.stdenvNoCC.mkDerivation {
            pname = "pulsedeck";
            version = "0.1.0";
            src = lib.fileset.toSource {
              root = ./.;
              fileset = lib.fileset.unions [ ./config.ru ./config ./lib ];
            };
            nativeBuildInputs = [ pkgs.makeWrapper ];
            installPhase = ''
              runHook preInstall
              mkdir -p $out/share/pulsedeck $out/bin
              cp -r config.ru config lib $out/share/pulsedeck/
              makeWrapper ${gems}/bin/rackup $out/bin/pulsedeck \
                --chdir $out/share/pulsedeck \
                --set GEM_PATH ${gems}/${pkgs.ruby_4_0.gemPath} \
                --add-flags "--env production --host 0.0.0.0"
              runHook postInstall
            '';
            meta.mainProgram = "pulsedeck";
          };
        });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          # Ruby 4.0 ships Bundler 4.x; the separate bundler package (2.7) conflicts with it.
          packages = [ pkgs.ruby_4_0 pkgs.bundix ];
          shellHook = ''
            export BUNDLE_PATH="$PWD/vendor/bundle"
          '';
        };
      });
    };
}
