return {
    {
        "toppair/peek.nvim",
        event = { "VeryLazy" },
        build = "deno_emit task --quiet build",
        config = function()
            require("peek").setup({
                filetype = { 'markdown', 'conf' }
            })
            vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
            vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
        end,
    },
}
