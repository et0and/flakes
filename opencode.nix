{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.opencode;

  # Convert an agent config to a markdown file
  agentToMarkdown = name: agent: ''
    ---
    description: ${agent.description or "No description"}
    mode: ${agent.mode or "all"}
    ${optionalString (agent.model != null) "model: ${agent.model}"}
    ${optionalString (agent.temperature != null) "temperature: ${toString agent.temperature}"}
    ${optionalString (agent.hidden or false) "hidden: true"}
    ${optionalString (agent ? tools) ''
    tools:
      ${optionalString (agent.tools.write != null) "  write: ${if agent.tools.write then "true" else "false"}"}
      ${optionalString (agent.tools.edit != null) "  edit: ${if agent.tools.edit then "true" else "false"}"}
      ${optionalString (agent.tools.bash != null) "  bash: ${if agent.tools.bash then "true" else "false"}"}
      ${optionalString (agent.tools.webfetch != null) "  webfetch: ${if agent.tools.webfetch then "true" else "false"}"}
    ''}
    ---
    ${if agent.promptFile != null then "{file:${name}-prompt.md}" else (agent.prompt or "")}
  '';

  # Generate agent files
  generateAgents = agents: mapAttrs' (name: agent: nameValuePair "${name}.md" (agentToMarkdown name agent)) agents;

  # Convert a command config to a markdown file
  commandToMarkdown = name: command: ''
    ---
    description: ${command.description or "No description"}
    ${optionalString (command.agent != null) "agent: ${command.agent}"}
    ${optionalString (command.model != null) "model: ${command.model}"}
    ${optionalString (command.subtask != null) "subtask: ${if command.subtask then "true" else "false"}"}
    ---
    ${if command.templateFile != null then "{file:${name}-template.md}" else (command.template or "")}
  '';

  # Generate command files
  generateCommands = commands: mapAttrs' (name: command: nameValuePair "${name}.md" (commandToMarkdown name command)) commands;

in
{
  options.services.opencode = {
    enable = mkEnableOption "OpenCode agents and commands configuration";

    configFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to opencode.jsonc configuration file";
    };

    agents = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          description = mkOption {
            type = types.str;
            description = "Brief description of what the agent does";
          };
          mode = mkOption {
            type = types.enum [ "primary" "subagent" "all" ];
            default = "all";
            description = "Agent mode";
          };
          model = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Model to use for this agent";
          };
          temperature = mkOption {
            type = types.nullOr types.number;
            default = null;
            description = "Temperature for the agent";
          };
          hidden = mkOption {
            type = types.bool;
            default = false;
            description = "Hide from autocomplete menu";
          };
          prompt = mkOption {
            type = types.str;
            default = "";
            description = "System prompt for the agent";
          };
          promptFile = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = "Path to a markdown file containing the system prompt";
          };
          tools = mkOption {
            type = types.nullOr (types.submodule {
              options = {
                write = mkOption {
                  type = types.nullOr types.bool;
                  default = null;
                  description = "Enable write tool";
                };
                edit = mkOption {
                  type = types.nullOr types.bool;
                  default = null;
                  description = "Enable edit tool";
                };
                bash = mkOption {
                  type = types.nullOr types.bool;
                  default = null;
                  description = "Enable bash tool";
                };
                webfetch = mkOption {
                  type = types.nullOr types.bool;
                  default = null;
                  description = "Enable Exa webfetch tool";
                };
              };
            });
            default = null;
            description = "Tools configuration";
          };
        };
      });
      default = {};
      description = "Agent configurations";
    };

    commands = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          description = mkOption {
            type = types.str;
            description = "Brief description of what the command does";
          };
          template = mkOption {
            type = types.str;
            description = "Prompt template for the command";
          };
          templateFile = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = "Path to a markdown file containing the template";
          };
          agent = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Agent to execute this command";
          };
          subtask = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = "Force the command to trigger a subagent invocation";
          };
          model = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Model to use for this command";
          };
        };
      });
      default = {};
      description = "Command configurations";
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile = {
      "opencode/opencode.jsonc" = mkIf (cfg.configFile != null) {
        source = cfg.configFile;
      };
      "opencode/agent" = mkIf (cfg.agents != {}) {
        source = pkgs.linkFarm "opencode-agents" (
          (mapAttrsToList (name: content: {
            inherit name;
            path = pkgs.writeText "opencode-agent-${name}" content;
          }) (generateAgents cfg.agents)) ++
          (mapAttrsToList (name: agent: {
            name = "${name}-prompt.md";
            path = agent.promptFile;
          }) (filterAttrs (n: a: a.promptFile != null) cfg.agents))
        );
      };
      "opencode/command" = mkIf (cfg.commands != {}) {
        source = pkgs.linkFarm "opencode-commands" (
          (mapAttrsToList (name: content: {
            inherit name;
            path = pkgs.writeText "opencode-command-${name}" content;
          }) (generateCommands cfg.commands)) ++
          (mapAttrsToList (name: command: {
            name = "${name}-template.md";
            path = command.templateFile;
          }) (filterAttrs (n: c: c.templateFile != null) cfg.commands))
        );
      };
    };
  };
}
