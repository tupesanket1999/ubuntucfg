--"Color Scheme
--"
vim.g["gruvbox_invert_selection"] = "0"
vim.g["gruvbox_contrast_dark"] = "hard"
vim.o.background = "dark"
vim.cmd([[
colorscheme gruvbox
highlight clear SignColumn]])

--"transparent
vim.cmd([[hi Normal guibg=NONE ctermbg=NONE]])
vim.cmd([[hi VertSplit guibg=NONE guifg=#141414]])


---- setup must be called before loading
--vim.cmd("colorscheme nightfox")
