return {
    {
        "nvim-telescope/telescope.nvim",
        branch = "master",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-ui-select.nvim",
        },

        config = function()
            local telescope = require("telescope")
            local builtin = require("telescope.builtin")
            local actions = require("telescope.actions")

            telescope.setup({
                defaults = {
                    preview = {
                        treesitter = false,
                    },
                    mappings = {
                        i = {
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<C-j>"] = actions.move_selection_next,
                        },
                    },
                },
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown({}),
                    },
                },
            })

            telescope.load_extension("ui-select")

            vim.keymap.set("n", "<leader>ff", function()
                builtin.find_files({ cwd = vim.fn.getcwd() })
            end, {})
            vim.keymap.set("n", "<C-p>", function()
                builtin.git_files({ cwd = vim.fn.getcwd() })
            end, {})
            vim.keymap.set("n", "<leader>fw", builtin.live_grep, {})
            vim.keymap.set("n", "<leader>fj", builtin.jumplist, {})
            vim.keymap.set("n", "<leader>fg", builtin.grep_string, {})
            vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
            vim.keymap.set("n", "<leader>fr", builtin.lsp_references, {})
        end,
    },
}
