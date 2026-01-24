{ config, pkgs, inputs, ... }:

let
  cloudflare-skill = builtins.fetchTarball {
    url = "https://github.com/dmmulroy/cloudflare-skill/archive/refs/heads/main.tar.gz";
    sha256 = "sha256-acYWBeiGzeeZnRxRTXQZXFxUmNPzvHKaQ/N8YqTBI+s=";
  };
  opentui-skill = builtins.fetchTarball {
    url = "https://github.com/msmps/opentui-skill/archive/refs/heads/main.tar.gz";
    sha256 = "0wib4851dkp6c6jnafjfwj377yzwv83r3xaj3wc4xm1j3cq1g3zf";
  };
  elysiajs-skills = builtins.fetchTarball {
    url = "https://github.com/elysiajs/skills/archive/refs/heads/main.tar.gz";
    sha256 = "0p9psxp3r63iv6myzicfnyhr2im7mh75f6bcsph3pip1qq4yrlzj";
  };
  better-auth-skills = builtins.fetchTarball {
    url = "https://github.com/better-auth/skills/archive/refs/heads/main.tar.gz";
    sha256 = "0pgaqkcwid7wnryalnb6n5i7fkah3g2x2vw9q19kbx8hpzn0ms1j";
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

  services.opencode = {
    enable = true;
    configFile = ./opencode.jsonc;
    extraCommandFiles = {
      "cloudflare.md" = "${cloudflare-skill}/command/cloudflare.md";
      "opentui.md" = "${opentui-skill}/command/opentui.md";
      "supermemory-init.md" = ./commands/supermemory-init.md;
    };
    extraSkills = {
      "cloudflare" = "${cloudflare-skill}/skill/cloudflare";
      "opentui" = "${opentui-skill}/skill/opentui";
      "elysia" = "${elysiajs-skills}/elysia";
      "better-auth-best-practices" = "${better-auth-skills}/better-auth/best-practices";
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
