{
  description = "Pulsedeck hardware monitor dashboard";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
      lib = nixpkgs.lib;

      fullGemset = import ./gemset.nix;
      # Same gems as the default group in Gemfile. bundix gives wrong groups, so filter here.
      runtimeGems = [
        "phlex"
        "puma"
        "rackup"
        "sinatra"
        "sorbet-runtime"
      ];
      closure =
        names:
        let
          next = lib.unique (names ++ lib.concatMap (n: fullGemset.${n}.dependencies or [ ]) names);
        in
        if lib.length next == lib.length names then names else closure next;

      mkGems =
        pkgs:
        pkgs.bundlerEnv {
          name = "pulsedeck-gems";
          ruby = pkgs.ruby_4_0;
          gemdir = ./.;
          gemset = lib.getAttrs (closure runtimeGems) fullGemset;
          groups = [ "default" ];
        };
    in
    {
      packages = forAllSystems (
        pkgs:
        let
          gems = mkGems pkgs;
        in
        {
          default = pkgs.stdenvNoCC.mkDerivation {
            pname = "pulsedeck";
            version = "0.1.0";
            src = lib.fileset.toSource {
              root = ./.;
              fileset = lib.fileset.unions [
                ./config.ru
                ./config
                ./lib
              ];
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
        }
      );

      nixosModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfg = config.services.pulsedeck;
          pkg = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
        in
        {
          options.services.pulsedeck = {
            enable = lib.mkEnableOption "Pulsedeck hardware monitor dashboard";
            port = lib.mkOption {
              type = lib.types.port;
              default = 9292;
              description = "TCP port of the Pulsedeck server.";
            };
            openFirewall = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Open the server port in the NixOS firewall.";
            };
            user = lib.mkOption {
              type = lib.types.str;
              example = "alice";
              description = "Existing user that runs the service. The service reads $HOME/.config/pulsedeck/config.yml of this user.";
            };
          };

          config = lib.mkIf cfg.enable {
            systemd.services.pulsedeck = {
              wantedBy = [ "multi-user.target" ];
              after = [ "network.target" ];
              serviceConfig = {
                ExecStart = "${lib.getExe pkg} --port ${toString cfg.port}";
                User = cfg.user;
                Restart = "on-failure";
                PrivateTmp = true;
              };
            };
            networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
          };
        };

      checks = forAllSystems (pkgs: let
        userConfig = pkgs.writeText "config.yml" ''
          grid:
            columns: 1
            rows: 1
          widgets:
            - provider: gpu_power
              column: 1
              row: 1
        '';
      in {
        nixos-module = pkgs.testers.runNixOSTest {
          name = "pulsedeck-nixos-module";
          nodes = {
            server = { ... }: {
              imports = [ self.nixosModules.default ];
              users.users.alice.isNormalUser = true;
              services.pulsedeck = {
                enable = true;
                port = 8080;
                user = "alice";
                openFirewall = true;
              };
            };
            closed = { ... }: {
              imports = [ self.nixosModules.default ];
              users.users.alice.isNormalUser = true;
              services.pulsedeck = {
                enable = true;
                port = 8080;
                user = "alice";
              };
            };
            home = { ... }: {
              imports = [ self.nixosModules.default ];
              users.users.alice = {
                isNormalUser = true;
              };
              services.pulsedeck = {
                enable = true;
                port = 8080;
                user = "alice";
              };
            };
            client = { ... }: {
              environment.systemPackages = [ pkgs.curl ];
            };
          };
          testScript = ''
            start_all()
            for node in [server, closed]:
                node.wait_for_unit("pulsedeck.service")
                node.wait_for_open_port(8080)
            client.succeed("curl -sf http://server:8080/ | grep 'data-metric=\"cpu_temperature\"'")
            server.succeed("test -f /home/alice/.config/pulsedeck/config.yml")
            client.fail("curl -sf --max-time 5 http://closed:8080/")
            home.wait_for_unit("pulsedeck.service")
            home.wait_for_open_port(8080)
            home.succeed("systemctl show -p User --value pulsedeck.service | grep -x alice")
            home.succeed("install -D -o alice -g users -m 644 ${userConfig} /home/alice/.config/pulsedeck/config.yml")
            home.succeed("curl -sf http://localhost:8080/ | grep 'data-metric=\"gpu_power\"'")
            home.fail("curl -sf http://localhost:8080/ | grep 'data-metric=\"cpu_temperature\"'")
          '';
        };
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          # Ruby 4.0 ships Bundler 4.x; the separate bundler package (2.7) conflicts with it.
          packages = [
            pkgs.ruby_4_0
            pkgs.bundix
            # Headless browser and curl for the dashboard-screenshot skill.
            pkgs.chromium
            pkgs.curl
          ];
          shellHook = ''
            export BUNDLE_PATH="$PWD/vendor/bundle"
          '';
        };
      });
    };
}
