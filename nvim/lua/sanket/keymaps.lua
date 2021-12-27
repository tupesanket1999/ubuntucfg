local function map(mode, combo, mapping, opts)
  local options = {noremap = true}
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.api.nvim_set_keymap(mode, combo, mapping, options)
end

map("i", "jj", "<Esc>")
map("n", "zz", ":w<CR>", {noremap = true})
map("n", "zq", ":bp<bar>sp<bar>bn<bar>bd<CR>", {noremap = true})
map("n", "<leader>h", ":wincmd h<CR>", {noremap = true})
map("n", "<leader>j", ":wincmd j<CR>", {noremap = true})
map("n", "<leader>k", ":wincmd k<CR>", {noremap = true})
map("n", "<leader>l", ":wincmd l<CR>", {noremap = true})
map("n", "<C-k>", ":bn<CR>", {noremap = true})
map("n", "<C-j>", ":bp<CR>", {noremap = true})
map("n", "<Leader>+", ":vertical resize +5<CR> ", {noremap = true})
map("n", "<Leader>-", ":vertical resize -5<CR>", {noremap = true})
map("n", "<C-w>s", ":belowright split<CR>", {noremap = true})
map("n", "<C-w>v", ":belowright vsplit<CR>", {noremap = true})
map("n", "<leader>t", ":terminal<CR>", {noremap = true})

--"TERMINAL
map("t", "<Esc>", "<C-\\><C-n>")

--"AUTO COMPLETE
map("i", "<C-Space> ", "compe#complete()", {silent = true, expr = true})
map("i", "<CR>", 'compe#confirm(luaeval("require \'nvim-autopairs\'.autopairs_cr()"))', {silent = true, expr = true})
map("i", "<C-e>", 'compe#close("<C-e>")', {silent = true, expr = true})
map("i", "<C-f>", 'compe#scroll({"delta": +4 })', {silent = true, expr = true})
map("i", "<C-d>", 'compe#scroll({"delta": -4 })', {silent = true, expr = true})

--"TELESCOPE
map("n", "<leader>ff", "<cmd>lua require('telescope.builtin').find_files()<cr>")
map("n", "<leader>fa", "<cmd>Telescope find_files find_command=rg,--ignore,--hidden,--files cwd=~<cr>")
map("n", "<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<cr>")
map("n", "<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<cr>")
map("n", "<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<cr>")
map("n", "<leader>fc", "<cmd>lua require('telescope.builtin').command_history()<cr>")
map("n", "<leader>fs", "<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<cr>")
map("n", "<leader>ps", ':lua require(\'telescope.builtin\').grep_string({ search = vim.fn.input(" > ")})<CR>')
map("n", "<C-p>", ":lua require('telescope.builtin').git_files()<CR>")
map("n", "<leader>gr", '<cmd>lua require"telescope.builtin.lsp".references()<CR>', {silent = true})

--"NERD TREE
map("n", "<C-n>", ":NvimTreeToggle<CR>")
map("n", "<leader>y", '"+y')
map("n", "<leader>git", ":Neogit<CR>")

--"DEBUGGER
map("n", "<F5>", ":lua require'dap'.continue()<CR>", {silent = true})
map("n", "<leader>dd", ":lua require('dap').continue()<CR>", {silent = true})
map("n", "<F10>", ":lua require'dap'.step_over()<CR>", {silent = true})
map("n", "<F11>", ":lua require'dap'.step_into()<CR>", {silent = true})
map("n", "<F12>", ":lua require'dap'.step_out()<CR>", {silent = true})
map("n", "<leader>b", ":lua require'dap'.toggle_breakpoint()<CR>", {silent = true})
map("n", "<leader>B", ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition:'))<CR>", {silent = true})
map(
  "n",
  "<leader>dm",
  ":lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>",
  {silent = true}
)
map("n", "<leader>dr", ":lua require'dap'.repl.open()<CR>", {silent = true})
map("n", "<leader>dl", ":lua require'dap'.repl.run_last()<CR>`", {silent = true})
map("n", "<leader>dh", ':lua require"dap.ui.widgets".hover()<CR>', {silent = true})
map("n", "<leader>du", ':lua require("dapui").toggle()<CR>', {silent = true})
