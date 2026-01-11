{ config, pkgs, inputs, ... }:

{
  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      name = "Default";
      isDefault = true;
      settings = {
        "browser.startup.page" = 3;
        "browser.search.region" = "NZ";
        "browser.search.isUS" = false;
        "extensions.update.autoUpdateDefault" = false;
        "privacy.trackingprotection.enabled" = true;
      };
      extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
        ublock-origin
        onepassword-password-manager
      ];
    };
  };
}
