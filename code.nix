{ config, pkgs, inputs, ... }:

{
  programs.vscode = {
    enable = true;
    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
      extensions = with pkgs.vscode-extensions; [
        github.vscode-pull-request-github
        esbenp.prettier-vscode
        dbaeumer.vscode-eslint
        catppuccin.catppuccin-vsc
      ];
      userSettings = {
        "editor.wordWrap" = "on";
        "editor.tabSize" = 2;
        "editor.formatOnSave" = true;
        "editor.formatOnPaste" = true;
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "files.trimTrailingWhitespace" = true;
        "workbench.colorTheme" = "Catppuccin Mocha";
        "github.copilot.nextEditSuggestions.enabled" = true;
      };
    };
  };
}
