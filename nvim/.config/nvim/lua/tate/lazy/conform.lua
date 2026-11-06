return {
    "stevearc/conform.nvim",
    config = function()
        require("conform").setup({
            formatters = {
                -- match prettier's indent to the buffer's shiftwidth (prettier defaults to 2)
                prettier = {
                    prepend_args = function(_, ctx)
                        local sw = vim.bo[ctx.buf].shiftwidth
                        if sw == 0 then
                            sw = vim.bo[ctx.buf].tabstop
                        end
                        return { "--tab-width", tostring(sw) }
                    end,
                },
            },
            formatters_by_ft = {
                lua = { "stylua" },
                python = { "isort", "ruff_format" },
                xml = { "xmllint" },
                json = { "jq" },
                c = { "clang-format" },
                typescript = { "prettier" },
                typescriptreact = { "prettier" },
                javascript = { "prettier" },
                javascriptreact = { "prettier" },
                ["*"] = { "codespell" },
            },
        })
    end,
}
