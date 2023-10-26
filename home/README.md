# structure

## components

> ./components/

Components define standalone program configurations and are therefor program
specific. These have no runtime dependencies to other components and/or modules.
Thus, it is only allowed to configure modules like enabling integrations.

## modules

> ./modules/

Modules on the other hand have dependencies to other components and/or modules.
Besides dependencies, modules can define non program specific capabilities e.g.
`screenshot` or `xdg`.

## profiles

> ./

Profiles define concrete home environments used in flake.nix and depend on
components and/or modules.
