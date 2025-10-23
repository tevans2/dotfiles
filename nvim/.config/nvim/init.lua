require("tate")


-- WISTL
-- Source a per-directory "types.vim" highlight file for C headers/sources
local grp = vim.api.nvim_create_augroup("UserTypesHighlight", { clear = true })

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = grp,
  pattern = { "*.c", "*.h" },
  callback = function(args)
    -- directory of the opened file
    local dir = vim.fn.fnamemodify(args.file, ":p:h")
    local fname = dir .. "/types.vim"
    -- if the file exists, source it (use fnameescape for safety)
    if vim.fn.filereadable(fname) == 1 then
      vim.cmd("source " .. vim.fn.fnameescape(fname))
    end
  end,
})


vim.api.nvim_create_autocmd({'BufReadPost', 'BufNewFile'}, {
  pattern = {'*.wistl'},
  command = 'setfiletype wistl',
})
vim.api.nvim_create_autocmd({'FileType'}, {
  pattern = {'wistl'},
  callback = function(ev)
    vim.bo.autoindent = true
    vim.bo.expandtab = true
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
    vim.bo.tabstop = 4
    vim.bo.textwidth = 80
    end
})
