return {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    -- keys = {
    --     { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
    --     { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
    -- },
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        keywords = {
            FIX = {
                icon = " ", -- icon used for the sign, and in search results
                color = "error", -- can be a hex color, or a named color (see below)
                alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
                -- signs = false, -- configure signs for some keywords individually
            },
            TODO = { icon = " ", color = "info" },
            HACK = { icon = " ", color = "warning" },
            WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
            ERRMSG = { icon = " ", color = "errormsg" },
            PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
            NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
            TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
            DONE = { icon = " ", color = "done" },
        },
        colors = {
            errormsg = "#fca935",
            done = "#3bed4d"
        },
        highlight = {
            -- match keywords without requiring a trailing colon
            pattern = [[.*<(KEYWORDS)\s*]],  -- vim regex for in-buffer highlighting
            comments_only = true,            -- requires Tree‑sitter; set false to test quickly
        },
        search = {
            command = "rg",
            args = { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column" },
            pattern = [[\b(KEYWORDS)\b]],    -- ripgrep regex without colon
        },
    },

    config = function(_, opts)
        require("todo-comments").setup(opts)
        vim.keymap.set("n", "]t", function()
            require("todo-comments").jump_next()
        end, { desc = "Next todo comment" })

        vim.keymap.set("n", "[t", function()
            require("todo-comments").jump_prev()
        end, { desc = "Previous todo comment" })
    end,
}

