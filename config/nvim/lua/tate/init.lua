require("tate.remap")
require("tate.set")
require("tate.lazy_init")
require("tate.review").setup()

-- WISTL
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    pattern = { "*.wistl" },
    command = "setfiletype wistl",
})
vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { "wistl" },
    callback = function(ev)
        vim.bo.autoindent = true
        vim.bo.expandtab = true
        vim.bo.shiftwidth = 4
        vim.bo.softtabstop = 4
        vim.bo.tabstop = 4
        vim.bo.textwidth = 80
    end,
})

local augroup = vim.api.nvim_create_augroup
local CustomGroup = augroup("CustomCommands", {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup("HighlightYank", {})

function R(name)
    require("plenary.reload").reload_module(name)
end

autocmd("TextYankPost", {
    group = yank_group,
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({
            higroup = "IncSearch",
            timeout = 40,
        })
    end,
})

autocmd("BufWritePre", {
    group = CustomGroup,
    callback = function(e)
        -- markdown uses trailing spaces for hard line breaks
        if vim.tbl_contains({ "markdown", "gitcommit", "diff" }, vim.bo[e.buf].filetype) then
            return
        end
        local view = vim.fn.winsaveview()
        vim.cmd("keeppatterns keepjumps silent %s/\\s\\+$//e")
        vim.fn.winrestview(view)
    end,
})

autocmd("LspAttach", {
    group = CustomGroup,
    callback = function(e)
        local opts = { buffer = e.buf }
        vim.keymap.set("n", "gd", function()
            vim.lsp.buf.definition()
        end, opts)
        vim.keymap.set("n", "K", function()
            vim.lsp.buf.hover({ border = "single" })
        end, opts)
        vim.keymap.set("n", "<leader>vws", function()
            vim.lsp.buf.workspace_symbol()
        end, opts)
        vim.keymap.set("n", "<leader>k", function()
            vim.diagnostic.open_float()
        end, opts)
        vim.keymap.set("n", "<leader>vca", function()
            vim.lsp.buf.code_action()
        end, opts)
        vim.keymap.set("n", "<leader>vrr", function()
            vim.lsp.buf.references()
        end, opts)
        vim.keymap.set("n", "<leader>vrn", function()
            vim.lsp.buf.rename()
        end, opts)
        vim.keymap.set("i", "<C-h>", function()
            vim.lsp.buf.signature_help()
        end, opts)
        vim.keymap.set("n", "<leader>vk", function()
            vim.diagnostic.jump({ count = -1, float = true })
        end, opts)
        vim.keymap.set("n", "<leader>vj", function()
            vim.diagnostic.jump({ count = 1, float = true })
        end, opts)

        local client = vim.lsp.get_client_by_id(e.data.client_id)
        if client and client.name == "clangd" then
            vim.keymap.set("n", "<leader>ch", function()
                client:request("clangd/switchSourceHeader", vim.uri_from_bufnr(0), function(err, result)
                    if err or not result then
                        vim.notify("No corresponding file found", vim.log.levels.INFO)
                        return
                    end
                    vim.cmd("edit " .. vim.uri_to_fname(result))
                end)
            end, opts)
        end
    end,
})

-- C89 commenting + semicolon toggle
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "h" },
    callback = function()
        vim.bo.commentstring = "/* %s */"
        vim.keymap.set("n", "<leader>;", function()
            local line = vim.api.nvim_get_current_line()
            if line:match(";%s*$") then
                vim.api.nvim_set_current_line(line:gsub(";%s*$", ""))
            else
                vim.api.nvim_set_current_line(line:gsub("%s*$", "") .. ";")
            end
        end, { buffer = true, desc = "Toggle semicolon" })
    end,
})

-- Markdown editing
local grp = vim.api.nvim_create_augroup("ProseMode", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = grp,
    pattern = { "markdown", "text", "gitcommit" },
    callback = function()
        vim.opt_local.spell = true
        vim.opt_local.spelllang = { "en_us" }
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.breakindent = true
        vim.opt_local.showbreak = "↳ "

        -- motions respect wrapped screen lines
        vim.keymap.set("n", "j", function()
            return vim.v.count > 0 and "j" or "gj"
        end, { buffer = true, expr = true, silent = true })
        vim.keymap.set("n", "k", function()
            return vim.v.count > 0 and "k" or "gk"
        end, { buffer = true, expr = true, silent = true })
        vim.keymap.set("n", "0", "g0", { buffer = true })
        vim.keymap.set("n", "$", "g$", { buffer = true })

        -- spell nav (already built-in, mapped here just to remind)
        -- ]s / [s jump between misspellings; z= shows suggestions

        local function toggle_checkbox()
            local line = vim.api.nvim_get_current_line()
            local new_line
            if line:match("%- %[x%]") then
                new_line = line:gsub("%- %[x%]", "- [ ]", 1)
            elseif line:match("%- %[ %]") then
                new_line = line:gsub("%- %[ %]", "- [x]", 1)
            end
            if new_line then
                vim.api.nvim_set_current_line(new_line)
            end
        end

        vim.keymap.set("n", "<leader><CR>", toggle_checkbox, { buffer = true, silent = true })
    end,
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
