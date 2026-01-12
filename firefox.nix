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
        "privacy.clearOnShutdown.cookies" = false;
        "privacy.clearOnShutdown.history" = false;
        "privacy.trackingprotection.enabled" = true;
	      "extensions.autoDisableScopes" = 0;
        "browser.newtab.url" = "about:blank";
        "browser.search.defaultenginename" = "DuckDuckGo";
        "browser.search.order.1" = "DuckDuckGo";
      };
      extensions.packages = with inputs.firefox-addons.packages.${pkgs.system}; [
        ublock-origin
      ];
    };
  };
}
