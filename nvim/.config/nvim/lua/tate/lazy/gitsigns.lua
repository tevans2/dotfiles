return {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    config = function()
        local gs = require("gitsigns")

        -- Unstaged: solid bar. Deletions get an edge glyph so they are not
        -- invisible -- a deleted block has no line of its own to mark.
        local signs = {
            add = { text = "▍" },
            change = { text = "▍" },
            delete = { text = "▁" },
            topdelete = { text = "▔" },
            changedelete = { text = "▍" },
            untracked = { text = "┆" },
        }

        -- Staged: hollow, so "the AI staged this" reads differently at a glance
        -- from "I have edited this since".
        local signs_staged = {
            add = { text = "▏" },
            change = { text = "▏" },
            delete = { text = "▁" },
            topdelete = { text = "▔" },
            changedelete = { text = "▏" },
        }

        gs.setup({
            signs = signs,
            signs_staged = signs_staged,
            signs_staged_enable = true,

            -- second and third channels: tint the line number and the sign on
            -- the cursor line, so a hunk is legible without hunting the gutter
            numhl = true,
            culhl = true,
            word_diff = false,

            current_line_blame = true,
            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = "eol",
                delay = 300,
                ignore_whitespace = true,
            },
            current_line_blame_formatter = "  <author>, <author_time:%R> - <summary>",
            current_line_blame_formatter_nc = "  uncommitted",

            preview_config = { border = "single" },

            on_attach = function(bufnr)
                local map = function(mode, l, r, desc)
                    vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
                end

                -- In the worktree the agent leaves its work staged, so the
                -- default target (unstaged only) finds nothing and every jump
                -- reports "No hunks" -- hence "all". A blob buffer from a past
                -- commit is the opposite: its real diff is the unstaged list,
                -- and its staged list holds one phantom hunk at line 1.
                local function nav()
                    local name = vim.api.nvim_buf_get_name(0)
                    local blob = name:match("^fugitive://") or name:match("^gitsigns://")
                    return { target = blob and "unstaged" or "all", wrap = true }
                end
                map("n", "]h", function()
                    gs.nav_hunk("next", nav())
                end, "Next hunk")
                map("n", "[h", function()
                    gs.nav_hunk("prev", nav())
                end, "Prev hunk")
                map("n", "]H", function()
                    gs.nav_hunk("last", nav())
                end, "Last hunk")
                map("n", "[H", function()
                    gs.nav_hunk("first", nav())
                end, "First hunk")

                map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
                map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
                map("v", "<leader>hs", function()
                    gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, "Stage hunk")
                map("v", "<leader>hr", function()
                    gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, "Reset hunk")
                map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
                map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
                map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")

                map("n", "<leader>hb", function()
                    gs.blame_line({ full = true })
                end, "Blame line")
                map("n", "<leader>hB", gs.blame, "Blame file")
                map("n", "<leader>hd", gs.diffthis, "Diff this")
                map("n", "<leader>hD", function()
                    gs.diffthis("~")
                end, "Diff this against HEAD~")

                -- inline beats a float while reviewing: the old lines appear in
                -- place, so the change reads as a diff without losing your spot
                map("n", "<leader>hp", gs.preview_hunk_inline, "Preview hunk inline")
                map("n", "<leader>hP", gs.preview_hunk, "Preview hunk (float)")

                -- toggles, for when you want more or less noise
                map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle line blame")
                map("n", "<leader>tw", gs.toggle_word_diff, "Toggle word diff")
                map("n", "<leader>td", gs.toggle_deleted, "Toggle deleted lines")

                -- ih works as a text object: dih, vih, yih
                map({ "o", "x" }, "ih", gs.select_hunk, "Select hunk")
            end,
        })

        -- catppuccin leaves the staged and number-column groups undefined, which
        -- is what made the gutter look empty. Derive them from the base colours.
        local function derive()
            local function fg(name)
                local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
                return hl and hl.fg or nil
            end

            local map = {
                GitSignsStagedAdd = fg("GitSignsAdd"),
                GitSignsStagedChange = fg("GitSignsChange"),
                GitSignsStagedDelete = fg("GitSignsDelete"),
                GitSignsStagedTopdelete = fg("GitSignsDelete"),
                GitSignsStagedChangedelete = fg("GitSignsChange"),
            }
            for group, colour in pairs(map) do
                if colour then
                    vim.api.nvim_set_hl(0, group, { fg = colour })
                end
            end

            -- number-column variants: same hue, so the line number itself
            -- carries the signal
            local nr = {
                GitSignsAddNr = fg("GitSignsAdd"),
                GitSignsChangeNr = fg("GitSignsChange"),
                GitSignsDeleteNr = fg("GitSignsDelete"),
                GitSignsTopdeleteNr = fg("GitSignsDelete"),
                GitSignsChangedeleteNr = fg("GitSignsChange"),
                GitSignsStagedAddNr = fg("GitSignsAdd"),
                GitSignsStagedChangeNr = fg("GitSignsChange"),
                GitSignsStagedDeleteNr = fg("GitSignsDelete"),
            }
            for group, colour in pairs(nr) do
                if colour then
                    vim.api.nvim_set_hl(0, group, { fg = colour, bold = true })
                end
            end

            vim.api.nvim_set_hl(0, "GitSignsCurrentLineBlame", { fg = "#6c7086", italic = true })
        end

        derive()
        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("GitSignsHl", { clear = true }),
            callback = derive,
        })
    end,
}
