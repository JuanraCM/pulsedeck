# Pulsedeck

Pulsedeck is a lightweight hardware monitor dashboard for AMD CPUs and GPUs. It is a web app designed to run on a Raspberry Pi screen, and it updates live without reloading the page.

> **Under development:** features and options may change.

## NixOS

Pulsedeck ships a NixOS module that runs the server as a `systemd` service.

1. Add the flake as an input and enable the module in your configuration:

   ```nix
   {
     inputs.pulsedeck.url = "github:JuanraCM/pulsedeck";

     outputs = { nixpkgs, pulsedeck, ... }: {
       nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
         system = "x86_64-linux";
         modules = [
           pulsedeck.nixosModules.default
           {
             services.pulsedeck = {
               enable = true;
               port = 9292;
               openFirewall = true;
             };
           }
         ];
       };
     };
   }
   ```

   If your configuration already uses an `imports` list, add `pulsedeck.nixosModules.default` there instead.

2. Apply the configuration:

   ```sh
   sudo nixos-rebuild switch --flake .#myhost
   ```

3. Open `http://<host>:<port>/` in a browser.

### Options

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `services.pulsedeck.enable` | bool | `false` | Run Pulsedeck as the `pulsedeck.service` systemd service. |
| `services.pulsedeck.port` | port | `9292` | TCP port the server listens on. |
| `services.pulsedeck.openFirewall` | bool | `false` | Open the port in the NixOS firewall. |

The service runs as a dynamic user, so it cannot bind ports below 1024.

## Development

Start the development shell:

```sh
nix develop
```

Then run these commands inside it (or prefix them with `nix develop -c`):

- `bundle exec rackup`: start the server.
- `bundle exec srb tc`: run the type check.
- `bundle exec rubocop`: run the linter (add `-a` to autocorrect).
- `bundle exec rspec`: run the tests.
- `nix build`: build the package.
- `nix flake check`: run the NixOS VM test.
- `bundix`: regenerate `gemset.nix` after `Gemfile.lock` changes.
