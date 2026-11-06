-- return {
--     "OXY2DEV/markview.nvim",
--     lazy = false,
--     ft = {"markdown"},
--
--    -- For `nvim-treesitter` users.
--     priority = 49,
--     opts = {
--         typst = { enable = false }
--     }
-- };

return {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
        latex = {
            render_modes = true,
            position = "center",
        },
    },
}
