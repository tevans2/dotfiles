return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "stevearc/conform.nvim",
        "mason-org/mason.nvim",
        "mason-org/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
        {
            "folke/lazydev.nvim",
            ft = "lua", -- only load on lua files
            opts = {
                library = {
                    -- See the configuration section for more details
                    -- Load luvit types when the `vim.uv` word is found
                    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                },
            },
        },
    },

    config = function()
        local cmp = require("cmp")
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities()
        )

        require("fidget").setup({})
        require("mason").setup()

        -- Per-server overrides merge on top of the configs nvim-lspconfig ships
        -- in its lsp/ dir; mason-lspconfig's automatic_enable then enables each
        -- server once Mason has installed it.
        vim.lsp.config("lua_ls", {
            capabilities = capabilities,
            settings = {
                Lua = {
                    format = {
                        enable = true,
                        defaultConfig = {
                            indent_style = "space",
                            indent_size = "4",
                        },
                    },
                },
            },
        })

        vim.lsp.config("pyright", {
            capabilities = capabilities,
            settings = {
                python = {
                    analysis = {
                        extraPaths = { "layers/norman-client/python" },
                        diagnosticMode = "off",
                    },
                },
            },
        })

        vim.lsp.config("clangd", {
            capabilities = capabilities,
            init_options = {
                fallbackFlags = { "-x", "c", "-std=c99" },
            },
        })

        vim.lsp.config("ts_ls", {
            capabilities = capabilities,
        })

        vim.lsp.config("eslint", {
            capabilities = capabilities,
        })

        vim.lsp.config("prismals", {
            capabilities = capabilities,
        })

        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "pyright",
                "ruff",
                "clangd",
                "ts_ls",
                "eslint",
                "prismals",
            },
            automatic_enable = true,
        })

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-k>"] = cmp.mapping.select_prev_item(cmp_select),
                ["<C-j>"] = cmp.mapping.select_next_item(cmp_select),
                ["<CR>"] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = "supermaven", group_index = 2 },
                { name = "nvim_lsp" },
                { name = "luasnip" }, -- For luasnip users.
            }, {
                { name = "buffer" },
                { name = "path" }, -- include file paths
            }),
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
        })

        -- Setup up vim-dadbod
        cmp.setup.filetype({ "sql" }, {
            sources = {
                { name = "vim-dadbod-completion" },
                { name = "buffer" },
            },
        })

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end,
}
