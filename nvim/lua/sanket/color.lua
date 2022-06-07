--"Color Scheme
--"
vim.g["gruvbox_invert_selection"] = "0"
vim.g["gruvbox_contrast_dark"] = "hard"
vim.o.background = "dark"
vim.cmd([[
colorscheme gruvbox
highlight clear SignColumn]])


--"transparent
--vim.cmd([[hi Normal guibg=NONE ctermbg=NONE]])



---- Default options
--require('nightfox').setup({
  --options = {
    ---- Compiled file's destination location
    --compile_path = util.join_paths(vim.fn.stdpath("cache"), "nightfox"),
    --compile_file_suffix = "_compiled", -- Compiled file suffix
    --transparent = false,    -- Disable setting background
    --terminal_colors = true, -- Set terminal colors (vim.g.terminal_color_*)
    --dim_inactive = false,   -- Non focused panes set to alternative background
    --styles = {              -- Style to be applied to different syntax groups
      --comments = "NONE",
      --functions = "NONE",
      --keywords = "NONE",
      --numbers = "NONE",
      --strings = "NONE",
      --types = "NONE",
      --variables = "NONE",
    --},
    --inverse = {             -- Inverse highlight for different types
      --match_paren = false,
      --visual = false,
      --search = false,
    --},
    --modules = {             -- List of various plugins and additional options
      ---- ...
    --},
  --}
--})

---- setup must be called before loading
--vim.cmd("colorscheme nightfox")
