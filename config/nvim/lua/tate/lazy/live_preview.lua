-- install with yarn or npm
-- return {
--   "iamcco/markdown-preview.nvim",
--   cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
--   build = "cd app && yarn install",
--   init = function()
--     vim.g.mkdp_filetypes = { "markdown" }
--     vim.g.mkdp_browser = "safari"
--   end,
--   ft = { "markdown" },
-- }
--

return {
    "wallpants/github-preview.nvim",
    cmd = { "GithubPreviewToggle" },
    keys = { "<leader>mpt" },
    opts = {
        -- config goes here
    },
    config = function(_, opts)
        local gpreview = require("github-preview")
        gpreview.setup(opts)

        local fns = gpreview.fns
        vim.keymap.set("n", "<leader>mpt", fns.toggle)
        vim.keymap.set("n", "<leader>mps", fns.single_file_toggle)
        vim.keymap.set("n", "<leader>mpd", fns.details_tags_toggle)
    end,
}
