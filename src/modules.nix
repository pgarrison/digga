{ lib }:
{
  hmNixosDefaults = { specialArgs, modules }:
    { options, ... }: {
      config = lib.optionalAttrs (options ? home-manager) {
        home-manager = {
          # always use the system nixpkgs from the host's channel
          useGlobalPkgs = true;
          # and use the possible future default (see manual)
          useUserPackages = lib.mkDefault true;

          extraSpecialArgs = specialArgs;
          sharedModules = modules;
        };
      };
    };

  globalDefaults = { hmUsers }:
    { config, pkgs, self, ... }: {
      # Digga's library functions can be accessed within modules directly via
      # `config.lib.digga`.
      lib = {inherit (pkgs.lib) digga;};

      _module.args = {
        inherit hmUsers;
        hosts = throw ''
          The `hosts` module argument has been removed, you should instead use
          `self.nixosConfigurations`, with the `self` module argument.
        '';
      };
    };

  nixosDefaults = { self, ... }: {
    users.mutableUsers = lib.mkDefault false;
    hardware.enableRedistributableFirmware = lib.mkDefault true;
    system.configurationRevision = lib.mkIf (self ? rev) self.rev;
  };

  nixDarwinCompat = { config, options, lib, ... }: {
    # TODO: remove when merged: https://github.com/LnL7/nix-darwin/pull/429
    options.lib = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
  };

}
