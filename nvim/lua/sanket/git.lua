require("gitsigns").setup {
  signs = {
    add = {hl = "GitSignsAdd", text = "│", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn"},
    change = {hl = "GitSignsChange", text = "│", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn"},
    delete = {hl = "GitSignsDelete", text = "_", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn"},
    topdelete = {hl = "GitSignsDelete", text = "‾", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn"},
    changedelete = {hl = "GitSignsChange", text = "~", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn"}
  },
  signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
  numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
  keymaps = {
    -- Default keymap options
    noremap = true,
    ["n ]g"] = {expr = true, '&diff ? \']c\' : \'<cmd>lua require"gitsigns.actions".next_hunk()<CR>\''},
    ["n [g"] = {expr = true, '&diff ? \'[c\' : \'<cmd>lua require"gitsigns.actions".prev_hunk()<CR>\''},
    ["n <leader>ms"] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
    ["v <leader>ms"] = '<cmd>lua require"gitsigns".stage_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
    ["n <leader>mu"] = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
    ["n <leader>mr"] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
    ["v <leader>mr"] = '<cmd>lua require"gitsigns".reset_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
    ["n <leader>mR"] = '<cmd>lua require"gitsigns".reset_buffer()<CR>',
    ["n <leader>mp"] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
    ["n <leader>mb"] = '<cmd>lua require"gitsigns".blame_line(true)<CR>',
    ["n <leader>mS"] = '<cmd>lua require"gitsigns".stage_buffer()<CR>',
    ["n <leader>mU"] = '<cmd>lua require"gitsigns".reset_buffer_index()<CR>',
    -- Text objects
    ["o ih"] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
    ["x ih"] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>'
  },
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
  current_line_blame_formatter_opts = {
    relative_time = false
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
  yadm = {
    enable = false
  }
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
