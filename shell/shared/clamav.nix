{ ... }:
{
  services.clamav = {
    updater.enable = true;

    daemon = {
      enable = true;
      settings = {
        ExcludePath = "^~/games/";
      };
    };
  };
}
