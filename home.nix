{ config, pkgs, inputs, ... }:

let
  cloudflare-skill = builtins.fetchTarball {
    url = "https://github.com/dmmulroy/cloudflare-skill/archive/refs/heads/main.tar.gz";
    sha256 = "sha256-acYWBeiGzeeZnRxRTXQZXFxUmNPzvHKaQ/N8YqTBI+s=";
  };
in
{
  imports = [
    ./firefox.nix
    ./code.nix
    ./opencode.nix
    ./neovim.nix
  ];

  home.username = "tom";
  home.homeDirectory = "/home/tom";
  home.stateVersion = "25.11";

  # Starship prompt
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
  };

  # Bash configuration
  programs.bash = {
    enable = true;
    enableCompletion = true;
    initExtra = ''
      export PATH="$HOME/.bun/bin:$PATH"

      # Initialize ble.sh for fish-like autosuggestions
      source ${pkgs.blesh}/share/blesh/ble.sh
    '';
  };

  home.sessionVariables = {
    PATH = "$HOME/.bun/bin:$PATH";
  };

  xdg.configFile = {
    "opencode/skill/cloudflare" = {
      source = "${cloudflare-skill}/skill/cloudflare";
      recursive = true;
    };
  };

  services.opencode = {
    enable = true;
    configFile = ./opencode.jsonc;
    extraCommandFiles = {
      "cloudflare.md" = "${cloudflare-skill}/command/cloudflare.md";
    };
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
      "summary" = {
      	description = "Summarize the current session as a chronological transcript";
	      agent = "build";
	      templateFile = ./commands/summary.md;
      };
    };
  };

  home.packages = with pkgs; [
    blesh  # Fish-like autosuggestions for bash
  ];
}
