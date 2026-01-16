{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      lazy-nvim
      catppuccin-nvim
    ];

    extraConfig = ''
      -- Lazyvim bootstrap
      local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
      if not (vim.uv or vim.loop).fs_stat(lazypath) then
        vim.fn.system({
          "git",
          "clone",
          "--filter=blob:none",
          "https://github.com/folke/lazy.nvim.git",
          lazypath,
        })
      end
      vim.opt.rtp:prepend(lazypath)

      require("lazy").setup({
        { "catppuccin/nvim", name = "catppuccin" },
        { "neovim/nvim-lspconfig" },
        { "nvim-treesitter/nvim-treesitter" },
        { "nvim-telescope/telescope.nvim" },
        { "hrsh7th/nvim-cmp" },
        { "hrsh7th/cmp-nvim-lsp" },
        { "hrsh7th/cmp-buffer" },
        { "hrsh7th/cmp-path" },
        { "L3MON4D3/LuaSnip" },
      })

      -- Theme
      vim.cmd.colorscheme "catppuccin"

      -- Catppuccin settings (matching your VSCode config)
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
        term_colors = true,
        dim_inactive = {
          enabled = false,
          shade = "dark",
          percentage = 0.15,
        },
        no_italic = false,
        no_bold = false,
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
        },
        color_overrides = {},
        custom_highlights = {},
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          notify = true,
          mini = false,
        },
      })

      -- LSP Config
      local lspconfig = require("lspconfig")
      local on_attach = function(client, bufnr)
        vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
        local opts = { buffer = bufnr, noremap = true, silent = true }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      end

      lspconfig.lua_ls.setup({
        on_attach = on_attach,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = {
                [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
              },
            },
          },
        },
      })

      lspconfig.tsserver.setup({
        on_attach = on_attach,
        cmd = { "typescript-language-server", "--stdio" },
        filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
      })

      lspconfig.eslint.setup({
        on_attach = on_attach,
        cmd = { "vscode-eslint-language-server", "--stdio" },
        settings = {
          eslint = {
            autoFixOnSave = true,
            validate = { "javascript", "javascriptreact" },
          },
        },
      })

      lspconfig.jsonls.setup({
        on_attach = on_attach,
        cmd = { "vscode-json-language-server", "--stdio" },
      })

      lspconfig.yamlls.setup({
        on_attach = on_attach,
        cmd = { "yaml-language-server", "--stdio" },
      })

      lspconfig.bashls.setup({
        on_attach = on_attach,
        cmd = { "bash-language-server", "start" },
      })

      lspconfig.helix_ls.setup({
        on_attach = on_attach,
      })

      -- Effect Language Service
      lspconfig.effectls.setup({
        on_attach = on_attach,
        cmd = { "npx", "-y", "effect-language-server", "--stdio" },
        filetypes = { "typescript", "typescriptreact", "typescript.tsx", "effect" },
        root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", ".git"),
        settings = {
          effect = {
            server = {
              typecheck = true,
              diagnostics = true,
            },
          },
        },
      })

      -- Treesitter
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua",
          "vim",
          "vimdoc",
          "typescript",
          "javascript",
          "json",
          "yaml",
          "bash",
          "markdown",
          "markdown_inline",
          "typescriptreact",
        },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
      })

      -- Telescope
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
      vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})

      -- Effect-specific keybindings
      vim.keymap.set("n", "<leader>ei", ":Effect inputConstructs<CR>", { desc = "Effect: show input constructs" })
      vim.keymap.set("n", "<leader>eo", ":Effect outputConstructs<CR>", { desc = "Effect: show output constructs" })
      vim.keymap.set("n", "<leader>es", ":Effect suggestions<CR>", { desc = "Effect: show suggestions" })

      -- Completion
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = {
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.close(),
          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = false,
          }),
        },
        sources = {
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
        },
      })

      -- Basic settings
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.tabstop = 2
      vim.opt.shiftwidth = 2
      vim.opt.expandtab = true
      vim.opt.smartindent = true
      vim.opt.wrap = false
      vim.opt.scrolloff = 8
      vim.opt.signcolumn = "yes"
      vim.opt.updatetime = 50
      vim.opt.termguicolors = true

      -- Leader key
      vim.g.mapleader = " "

      -- Effect commands
      vim.api.nvim_create_user_command("EffectInstallLanguageServer", function()
        vim.fn.system({ "npm", "install", "-g", "effect-language-server" })
        vim.notify("Effect Language Server installed!", vim.log.levels.INFO)
      end, {})

      vim.api.nvim_create_user_command("EffectSetup", function(opts)
        local project_type = opts.args or "default"
        vim.fn.system({ "npx", "-y", "effect-solutions", "setup" })
        vim.notify("Effect reference setup complete!", vim.log.levels.INFO)
      end, {
        nargs = "?",
        complete = function()
          return { "default", "cli", "http" }
        end,
      })

      -- File types
      vim.filetype.add({
        extension = {
          mdx = "markdown",
        },
      })
    '';
  };

  home.packages = with pkgs; [
    # LSP servers
    lua-language-server
    typescript-language-server
    eslint_d
    json-lsp
    yaml-language-server
    bash-language-server
    helix-ls
    nodejs
  ];
}
