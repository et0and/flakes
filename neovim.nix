{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      # C compiler for treesitter
      gcc
      gnumake
      # LSP servers
      lua-language-server
      typescript-language-server
      vscode-langservers-extracted  # jsonls, eslint, html, css
      yaml-language-server
      bash-language-server
      nil  # Nix LSP
      # Formatters
      prettier
      prettierd
      stylua
      shfmt
      # Tools needed by LazyVim
      ripgrep
      fd
      lazygit
      # Node for LSPs
      nodejs
    ];

    extraLuaConfig = ''
      -- Bootstrap lazy.nvim
      local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
      if not (vim.uv or vim.loop).fs_stat(lazypath) then
        local lazyrepo = "https://github.com/folke/lazy.nvim.git"
        local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
        if vim.v.shell_error ~= 0 then
          vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
          }, true, {})
          vim.fn.getchar()
          os.exit(1)
        end
      end
      vim.opt.rtp:prepend(lazypath)

      -- Setup lazy.nvim with LazyVim
      require("lazy").setup({
        spec = {
          -- Import LazyVim and its plugins
          { "LazyVim/LazyVim", import = "lazyvim.plugins" },

          -- Import TypeScript extras
          { import = "lazyvim.plugins.extras.lang.typescript" },
          { import = "lazyvim.plugins.extras.lang.json" },
          { import = "lazyvim.plugins.extras.lang.yaml" },
          { import = "lazyvim.plugins.extras.lang.markdown" },

          -- Import formatting extras
          { import = "lazyvim.plugins.extras.formatting.prettier" },

          -- Keep dashboard but don't auto-open when opening files/dirs
          {
            "nvimdev/dashboard-nvim",
            opts = {
              config = {
                -- Only show dashboard when opening nvim without arguments
                disable_move = true,
              },
            },
          },

          -- Override colorscheme to catppuccin
          {
            "catppuccin/nvim",
            name = "catppuccin",
            priority = 1000,
            opts = {
              flavour = "mocha",
              integrations = {
                cmp = true,
                gitsigns = true,
                neo_tree = true,
                treesitter = true,
                notify = true,
                mini = { enabled = true },
                which_key = true,
                telescope = { enabled = true },
              },
            },
          },

          -- Set catppuccin as the colorscheme
          {
            "LazyVim/LazyVim",
            opts = {
              colorscheme = "catppuccin",
            },
          },

          -- Add Nix support
          {
            "nvim-treesitter/nvim-treesitter",
            opts = function(_, opts)
              if type(opts.ensure_installed) == "table" then
                vim.list_extend(opts.ensure_installed, { "nix" })
              end
            end,
          },
          {
            "neovim/nvim-lspconfig",
            opts = {
              servers = {
                nil_ls = {},
              },
            },
          },

          -- MDX filetype
          {
            "nvim-treesitter/nvim-treesitter",
            opts = function(_, opts)
              vim.filetype.add({
                extension = {
                  mdx = "markdown",
                },
              })
            end,
          },
        },
        defaults = {
          lazy = false,
          version = false,
        },
        install = { colorscheme = { "catppuccin", "tokyonight", "habamax" } },
        checker = { enabled = true },
        performance = {
          rtp = {
            disabled_plugins = {
              "gzip",
              "tarPlugin",
              "tohtml",
              "tutor",
              "zipPlugin",
            },
          },
        },
      })
    '';
  };
}
