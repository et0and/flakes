{ config, pkgs, inputs, ... }:

{
  imports = [
    ./firefox.nix
    ./code.nix
    ./opencode.nix
  ];

  home.username = "tom";
  home.homeDirectory = "/home/tom";
  home.stateVersion = "25.11";
  services.opencode = {
    enable = true;
    configFile = ./opencode.jsonc;
    agents = {
      "code-reviewer" = {
        description = "Reviews code for bugs, security, and best practices";
        mode = "subagent";
        temperature = 0.1;
        promptFile = ./agents/code-reviewer-prompt.md;
        tools = {
          write = false;
          edit = false;
          bash = true;
          webfetch = true;
        };
      };
    };
    commands = {
      "test" = {
        description = "Run tests with coverage";
        template = "Run the full test suite with coverage report and show any failures.\nFocus on the failing tests and suggest fixes.";
        agent = "build";
      };
      "review" = {
        description = "Review changes with parallel @code-review subagents";
        agent = "plan";
        templateFile = ./commands/review-template.md;
      };
    };
  };

  home.packages = with pkgs; [
  ];
}
