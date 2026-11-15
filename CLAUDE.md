# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Project

Pulsedeck is a lightweight hardware monitor dashboard. It is a web app. It shows on a Raspberry Pi screen.

Status: new project. Most code does not exist yet.

## Rules

- Write all explanations in ASD-STE100 Simplified Technical English.
- Write all commit messages in the Conventional Commits format (`type(scope): description`).
- Always run project commands inside the Nix development shell (`nix develop -c <command>`). The host Ruby is not the project Ruby.

## Stack

- Ruby and Sinatra for the web server.
- Sorbet for types. Put a `# typed:` sigil in each Ruby file.
- RuboCop for lint.
- RSpec for tests.
- Phlex for HTML views. Do not use ERB templates.
- Nix flake for build and deployment.

## Commands

- `nix develop`: start the development shell.
- `bundle exec rackup`: start the server.
- `bundle exec srb tc`: do the type check.
- `bundle exec rubocop`: do the lint. Add `-a` to correct offenses automatically.
- `bundle exec rspec`: run the tests.
- `nix build`: build the package.
- `nix develop -c bundix`: make `gemset.nix` again. Do this after each change to `Gemfile.lock`.
- `nix flake check`: run the NixOS VM test.

## Architecture

### Providers

- Each hardware metric (for example, CPU temperature or GPU power) has one provider object.
- All providers inherit from one abstract base class (Sorbet `abstract!`).
- Hardware support: AMD CPU and AMD GPU with the `amdgpu` driver only. Do not add support for other hardware unless the user tells you to.

### Dashboard

- One Sinatra endpoint serves the dashboard page.
- The page updates automatically. Do not use full-page reloads. Update only the widget data.
- A config file defines the widgets and their positions. Build the dashboard from this file.
- A dashboard is made of widgets as direct children. Do not give providers (or other widget data) to the dashboard. Each widget owns its provider.

### Widgets and layouts

- Make widgets from a small set of shared layouts (Phlex components).
- Do not make a new layout for each widget. Use an existing layout when possible.

### NixOS

- The flake gives a NixOS module. This is the primary deployment method.
- The module defines the server as a `systemd` service and opens the firewall ports.
- `nix flake check` runs the NixOS VM test.
