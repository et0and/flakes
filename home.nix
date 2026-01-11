{ config, pkgs, inputs, ... }:

{
  imports = [
    ./firefox.nix
  ];

  home.username = "tom";
  home.homeDirectory = "/home/tom";
  home.stateVersion = "25.11";

  programs.vscode = {
    enable = true;
    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
      extensions = with pkgs.vscode-extensions; [
        github.vscode-pull-request-github
        esbenp.prettier-vscode
        dbaeumer.vscode-eslint
      ];
      userSettings = {
        "editor.tabSize" = 2;
        "editor.formatOnSave" = true;
        "editor.formatOnPaste" = true;
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "files.trimTrailingWhitespace" = true;
      };
    };
  };

  home.packages = with pkgs; [
  ];
}
