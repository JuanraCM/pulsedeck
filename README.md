# Pulsedeck

Pulsedeck is a lightweight hardware monitor dashboard for AMD CPUs and GPUs. It is a web app designed to run on a Raspberry Pi screen, and it updates live without reloading the page.

> **Under development:** features and options may change.

## Configuration

Pulsedeck reads one YAML file that sets the grid and the widgets:

```
$HOME/.config/pulsedeck/config.yml
```

If the file does not exist, Pulsedeck writes this default file on the first request:

```yaml
# Size of the dashboard grid, in cells.
grid:
  columns: 4
  rows: 3

# Each widget has a provider and a placement.
# column and row start at 1. width and height are optional (default 1).
widgets:
  - provider: cpu_temperature # Provider id. Known ids: cpu_temperature
    column: 1
    row: 1
    width: 2
    height: 2
  - provider: cpu_temperature
    column: 3
    row: 1
    width: 2
  - provider: cpu_temperature
    column: 3
    row: 2
    height: 2
  - provider: cpu_temperature
    column: 4
    row: 2
  - provider: cpu_temperature
    column: 1
    row: 3
  - provider: cpu_temperature
    column: 2
    row: 3
  - provider: cpu_temperature
    column: 4
    row: 3
```

- `grid.columns` and `grid.rows` set the size of the grid.
- Each widget has a `provider` (`cpu_temperature` is the only known id), a `column` and a `row`. Column and row start at 1.
- `width` and `height` are optional. The default is 1.
- A widget must be inside the grid.

Pulsedeck reads the file on each request. Edit the file and reload the page to see the change.

If the file is not valid, the server answers with a 500 response. The response is plain text. It shows the file path and the error. No dashboard renders until you correct the file.

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

The service sets `HOME` to its state directory, so the config file is `/var/lib/pulsedeck/.config/pulsedeck/config.yml`. Pulsedeck writes the default file there on the first request.

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
