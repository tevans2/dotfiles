-- lua/plugins/core.lua
return {
  -- nvim-cmp + LSP completion capabilities
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
        },
        mapping = cmp.mapping.preset.insert({
          ["<CR>"]     = cmp.mapping.confirm({ select = false }),
          ["<C-Space>"]= cmp.mapping.complete(),
          ["<C-u>"]    = cmp.mapping.scroll_docs(-4),
          ["<C-d>"]    = cmp.mapping.scroll_docs(4),
        }),
      })
    end,
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    version = "v1.8.0", -- same as tag; pin to keep stable
    -- pin = true, -- (not needed when version is set; either is fine)
    config = function()
      -- Reserve sign column to prevent layout jumps
      vim.opt.signcolumn = "yes"

      -- Augment LSP capabilities for nvim-cmp
      local lspconfig = require("lspconfig")
      local defaults = lspconfig.util.default_config
      defaults.capabilities = vim.tbl_deep_extend(
        "force",
        defaults.capabilities,
        require("cmp_nvim_lsp").default_capabilities()
      )

      -- Nice LSP keymaps only when a server attaches
      vim.api.nvim_create_autocmd("LspAttach", {
        desc = "LSP actions",
        callback = function(event)
          local opts = { buffer = event.buf }
          local map = vim.keymap.set

          map("n", "K",  vim.lsp.buf.hover, opts)
          map("n", "gd", vim.lsp.buf.definition, opts)
          map("n", "gD", vim.lsp.buf.declaration, opts)
          map("n", "gi", vim.lsp.buf.implementation, opts)
          map("n", "go", vim.lsp.buf.type_definition, opts)
          map("n", "gr", vim.lsp.buf.references, opts)
          map("n", "gs", vim.lsp.buf.signature_help, opts)
          map("n", "<F2>", function() vim.lsp.buf.rename() end, opts)
          map({ "n", "x" }, "<F3>", function() vim.lsp.buf.format({ async = true }) end, opts)
          map("n", "<F4>", vim.lsp.buf.code_action, opts)
        end,
      })

      -- Enable servers you have installed on your system/container
      lspconfig.clangd.setup({})
    end,
  },
}

