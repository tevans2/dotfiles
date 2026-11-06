-- Deliberate review loop for AI-generated changes.
--
--   <leader>qr   load changed files into the quickfix list (vs HEAD)
--   <leader>qm   same, but vs the merge-base with main
--   <leader>gs   Telescope git_status, <C-q> to dump into quickfix
--   <leader>qf   fuzzy-find within the review list (random access, not scrolling)
--   ]q / [q      linear step through the list
--   ]h / [h      walk the hunks inside a file (gitsigns)
--   <leader>qd   mark the current file reviewed and drop it from the list
--   dd           inside the quickfix window, drop one entry
--   :ReviewCommit  commit, but only once the list is empty

local M = {}

local function git_root()
    local out = vim.fn.systemlist({ "git", "rev-parse", "--show-toplevel" })
    if vim.v.shell_error ~= 0 then
        return nil
    end
    return out[1]
end

-- One `git diff` pass. Records the first hunk line per file so that entries
-- land on an actual change rather than on line 1.
local function changed_entries(root, base)
    local entries, current, seen = {}, nil, {}

    for _, line in ipairs(vim.fn.systemlist({ "git", "-C", root, "diff", "-U0", base })) do
        if line:match("^%+%+%+ ") then
            -- nil for /dev/null, i.e. a deletion; nothing left to review
            current = line:match("^%+%+%+ b/(.*)")
        elseif current and not seen[current] then
            local lnum = line:match("^@@ %-%d+,?%d* %+(%d+)")
            if lnum then
                seen[current] = true
                table.insert(entries, {
                    filename = root .. "/" .. current,
                    lnum = tonumber(lnum),
                    col = 1,
                    text = "changed",
                })
            end
        end
    end

    local untracked = { "git", "-C", root, "ls-files", "--others", "--exclude-standard" }
    for _, file in ipairs(vim.fn.systemlist(untracked)) do
        table.insert(entries, { filename = root .. "/" .. file, lnum = 1, col = 1, text = "new" })
    end

    return entries
end

local function list_win()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.fn.getwininfo(win)[1].quickfix == 1 then
            return win
        end
    end
    return nil
end

-- Keep the list on screen, but leave the cursor where it was.
function M.open()
    if list_win() then
        return
    end
    local cur = vim.api.nvim_get_current_win()
    vim.cmd("botright copen")
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.wo.wrap = false
    if vim.api.nvim_win_is_valid(cur) then
        vim.api.nvim_set_current_win(cur)
    end
end

function M.toggle()
    if list_win() then
        vim.cmd("cclose")
    else
        M.open()
    end
end

function M.load(base)
    local root = git_root()
    if not root then
        vim.notify("not a git repo", vim.log.levels.WARN)
        return
    end

    base = base or "HEAD"
    local entries = changed_entries(root, base)
    if #entries == 0 then
        vim.notify("nothing to review", vim.log.levels.INFO)
        return
    end

    -- blame is meaningful again once we are back on worktree files
    require("gitsigns").toggle_current_line_blame(true)

    vim.fn.setqflist({}, " ", { title = "review " .. base, items = entries })
    M.open()
    vim.cmd("cfirst")
    vim.notify(#entries .. " files to review")
end

function M.load_vs_main()
    local root = git_root()
    if not root then
        vim.notify("not a git repo", vim.log.levels.WARN)
        return
    end

    local base = vim.fn.systemlist({ "git", "-C", root, "merge-base", "HEAD", "main" })[1]
    if vim.v.shell_error ~= 0 or not base then
        vim.notify("no merge-base with main", vim.log.levels.WARN)
        return
    end

    M.load(base)
end

-- Reviewing an arbitrary commit
--
-- The files are opened as fugitive blob buffers -- the content *as of* that
-- commit -- and gitsigns is pointed at the commit's parent, so the signs show
-- what that commit did rather than how it differs from your working tree.

local EMPTY_TREE = "4b825dc642cb6eb9a060e54bf8d69288fbee4904"

-- sha -> parent rev, consulted when a blob buffer is entered
local commit_base = {}

local function git(root, ...)
    local cmd = { "git", "-C", root }
    for _, a in ipairs({ ... }) do
        table.insert(cmd, a)
    end
    local out = vim.fn.systemlist(cmd)
    return vim.v.shell_error == 0 and out or nil
end

-- First changed line per file, from a single diff of parent..rev.
local function first_lines(root, parent, sha)
    local firsts, current = {}, nil
    for _, line in ipairs(git(root, "diff", "-U0", parent, sha) or {}) do
        if line:match("^%+%+%+ ") then
            current = line:match("^%+%+%+ b/(.*)")
        elseif current and not firsts[current] then
            local lnum = line:match("^@@ %-%d+,?%d* %+(%d+)")
            if lnum then
                firsts[current] = math.max(tonumber(lnum), 1)
            end
        end
    end
    return firsts
end

-- gitsigns attaches asynchronously, so retry until the buffer is live.
local function apply_base(bufnr, parent, tries)
    if not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end
    local gs = require("gitsigns")
    if gs.get_hunks(bufnr) ~= nil then
        vim.api.nvim_buf_call(bufnr, function()
            gs.change_base(parent, false)
        end)
    elseif (tries or 0) < 20 then
        vim.defer_fn(function()
            apply_base(bufnr, parent, (tries or 0) + 1)
        end, 100)
    end
end

function M.open_commit(rev)
    local root = git_root()
    if not root then
        vim.notify("not a git repo", vim.log.levels.WARN)
        return
    end

    local sha = (git(root, "rev-parse", "--verify", rev .. "^{commit}") or {})[1]
    if not sha then
        vim.notify("no such commit: " .. rev, vim.log.levels.ERROR)
        return
    end

    -- a root commit has no parent; diff it against the empty tree
    local parent = (git(root, "rev-parse", "--verify", sha .. "^") or {})[1] or EMPTY_TREE
    local gitdir = (git(root, "rev-parse", "--absolute-git-dir") or {})[1]

    -- --diff-filter=d: a file the commit deleted has no blob left to open
    -- --root so the repo's initial commit is reviewable; harmless otherwise
    local files = git(root, "diff-tree", "--root", "--no-commit-id", "--name-only", "-r", "--diff-filter=d", sha) or {}
    if #files == 0 then
        vim.notify("commit touches no files", vim.log.levels.INFO)
        return
    end

    local firsts = first_lines(root, parent, sha)
    local entries = {}
    for _, file in ipairs(files) do
        table.insert(entries, {
            filename = "fugitive://" .. gitdir .. "//" .. sha .. "/" .. file,
            lnum = firsts[file] or 1,
            col = 1,
            text = "changed",
        })
    end

    commit_base[sha] = parent

    -- every line of a blob buffer belongs to this commit, so blame says nothing
    -- and errors on the read-only buffer
    require("gitsigns").toggle_current_line_blame(false)

    local subject = (git(root, "log", "-1", "--format=%h %s", sha) or { sha:sub(1, 7) })[1]
    vim.fn.setqflist({}, " ", { title = "commit " .. subject, items = entries })
    M.open()
    vim.cmd("cfirst")
    vim.notify(#entries .. " files in " .. subject)
end

-- Pick a commit. The default <CR> on Telescope's git_commits picker checks the
-- commit out; this replaces it with a read-only review.
function M.pick_commit()
    local ok, builtin = pcall(require, "telescope.builtin")
    if not ok then
        vim.notify("telescope not available", vim.log.levels.ERROR)
        return
    end
    local actions = require("telescope.actions")
    local state = require("telescope.actions.state")

    builtin.git_commits({
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local entry = state.get_selected_entry()
                actions.close(prompt_bufnr)
                if entry and entry.value then
                    M.open_commit(entry.value)
                end
            end)
            return true
        end,
    })
end

function M.commit_base_for(bufnr)
    local name = vim.api.nvim_buf_get_name(bufnr)
    local sha = name:match("^fugitive://.*//(%x+)/")
    return sha and commit_base[sha] or nil
end

local function item_path(item)
    if item.bufnr and item.bufnr > 0 then
        return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(item.bufnr), ":p")
    end
    return vim.fn.fnamemodify(item.filename or "", ":p")
end

-- Drop every entry belonging to `path` (defaults to the current buffer).
function M.prune(path)
    path = vim.fn.fnamemodify(path or vim.api.nvim_buf_get_name(0), ":p")

    local kept = vim.tbl_filter(function(item)
        return item_path(item) ~= path
    end, vim.fn.getqflist())

    vim.fn.setqflist(kept, "r")

    if #kept == 0 then
        vim.cmd("cclose")
        vim.notify("review complete - safe to commit", vim.log.levels.INFO)
    else
        M.open()
        vim.notify(#kept .. " files left")
    end
end

function M.remaining()
    return #vim.fn.getqflist()
end

-- lualine component
function M.status()
    local n = M.remaining()
    return n > 0 and ("󰄲 " .. n) or ""
end

function M.setup()
    local map = function(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true })
    end

    map("<leader>gs", "<cmd>Telescope git_status<cr>", "Changed files (<C-q> to quickfix)")
    map("<leader>qr", function()
        M.load("HEAD")
    end, "Review: load changes vs HEAD")
    map("<leader>qm", M.load_vs_main, "Review: load changes vs main")

    map("<leader>qc", M.pick_commit, "Review: open a commit")
    map("<leader>qf", "<cmd>Telescope quickfix<cr>", "Review: fuzzy-find in list")
    map("<leader>qq", M.toggle, "Review: toggle list")
    map("]q", "<cmd>cnext<cr>zz", "Review: next file")
    map("[q", "<cmd>cprev<cr>zz", "Review: prev file")
    map("<leader>qd", function()
        M.prune()
    end, "Review: mark file reviewed")

    -- point gitsigns at the commit's parent whenever one of its blob buffers
    -- is opened, so the signs show what the commit changed
    vim.api.nvim_create_autocmd("BufReadPost", {
        group = vim.api.nvim_create_augroup("ReviewCommitBase", { clear = true }),
        pattern = "fugitive://*",
        callback = function(e)
            local parent = M.commit_base_for(e.buf)
            if parent then
                apply_base(e.buf, parent)
            end
        end,
    })

    -- dd inside the quickfix window drops that single row
    vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("ReviewQf", { clear = true }),
        pattern = "qf",
        callback = function(e)
            vim.keymap.set("n", "dd", function()
                local idx = vim.fn.line(".")
                local list = vim.fn.getqflist()
                if #list == 0 then
                    return
                end
                table.remove(list, idx)
                vim.fn.setqflist(list, "r")
                if #list > 0 then
                    vim.fn.cursor(math.min(idx, #list), 1)
                end
            end, { buffer = e.buf, desc = "Review: drop entry" })
        end,
    })

    vim.api.nvim_create_user_command("ReviewCommit", function()
        local n = M.remaining()
        if n > 0 then
            vim.notify(n .. " files still unreviewed", vim.log.levels.ERROR)
            return
        end
        vim.cmd("Git commit")
    end, { desc = "Commit, but only once the review list is empty" })
end

return M
