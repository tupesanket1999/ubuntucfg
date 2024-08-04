require("gitsigns").setup {
    --signs = {
    --add = { hl = "GitSignsAdd", text = "│", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
    --change = { hl = "GitSignsChange", text = "│", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
    --delete = { hl = "GitSignsDelete", text = "_", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
    --topdelete = { hl = "GitSignsDelete", text = "‾", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
    --changedelete = { hl = "GitSignsChange", text = "~", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" }
    --},
    signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
    numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
    linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
    word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']g', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
        end, { expr = true })

        map('n', '[g', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
        end, { expr = true })

        -- Actions
        map('n', '<leader>ms', gs.stage_hunk)
        map('n', '<leader>mr', gs.reset_hunk)
        map('v', '<leader>ms', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
        map('v', '<leader>mr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
        map('n', '<leader>mS', gs.stage_buffer)
        map('n', '<leader>mu', gs.undo_stage_hunk)
        map('n', '<leader>mR', gs.reset_buffer)
        map('n', '<leader>mp', gs.preview_hunk)
        map('n', '<leader>mb', function() gs.blame_line { full = true } end)
        map('n', '<leader>tb', gs.toggle_current_line_blame)
        map('n', '<leader>md', gs.diffthis)
        map('n', '<leader>mD', function() gs.diffthis('~') end)
        --map('n', '<leader>td', gs.toggle_deleted)

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
    end,
    --keymaps = {
    ---- Default keymap options
    --noremap = true,
    --["n ]g"] = { expr = true, '&diff ? \']c\' : \'<cmd>lua require"gitsigns.actions".next_hunk()<CR>\'' },
    --["n [g"] = { expr = true, '&diff ? \'[c\' : \'<cmd>lua require"gitsigns.actions".prev_hunk()<CR>\'' },
    --["n <leader>ms"] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
    --["v <leader>ms"] = '<cmd>lua require"gitsigns".stage_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
    --["n <leader>mu"] = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
    --["n <leader>mr"] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
    --["v <leader>mr"] = '<cmd>lua require"gitsigns".reset_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
    --["n <leader>mR"] = '<cmd>lua require"gitsigns".reset_buffer()<CR>',
    --["n <leader>mp"] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
    --["n <leader>mb"] = '<cmd>lua require"gitsigns".blame_line(true)<CR>',
    --["n <leader>mS"] = '<cmd>lua require"gitsigns".stage_buffer()<CR>',
    --["n <leader>mU"] = '<cmd>lua require"gitsigns".reset_buffer_index()<CR>',
    ---- Text objects
    --["o ih"] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
    --["x ih"] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>'
    --},
    watch_gitdir = {
        interval = 1000,
        follow_files = true
    },
    attach_to_untracked = true,
    current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
        delay = 1000
    },
    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil, -- Use default
    max_file_length = 40000,
    preview_config = {
        -- Options passed to nvim_open_win
        border = "single",
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1
    },
}

require("neogit").setup {
    integrations = {
        -- Neogit only provides inline diffs. If you want a more traditional way to look at diffs, you can use `sindrets/diffview.nvim`.
        -- The diffview integration enables the diff popup, which is a wrapper around `sindrets/diffview.nvim`.
        --
        -- Requires you to have `sindrets/diffview.nvim` installed.
        -- use {
        --   'TimUntersberger/neogit',
        --   requires = {
        --     'nvim-lua/plenary.nvim',
        --     'sindrets/diffview.nvim'
        --   }
        -- }
        --
        diffview = true
    }
}
require("diffview").setup {}
