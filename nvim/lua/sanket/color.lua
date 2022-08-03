--"Color Scheme
--vim.g["gruvbox_invert_selection"] = "0"
--vim.g["gruvbox_contrast_dark"] = "hard"
--vim.o.background = "dark"
--vim.cmd([[
--colorscheme gruvbox
--highlight clear SignColumn)

----"transparent
--vim.cmd([[hi Normal guibg=NONE ctermbg=NONE]])
--vim.cmd([[hi VertSplit guibg=NONE guifg=#141414]])

vim.g.tokyonight_style = "night"
vim.g.tokyonight_italic_functions = false
--vim.g.tokyonight_sidebars = { "qf", "vista_kind", "terminal", "packer", "TelescopePrompt" }
vim.g.tokyonight_transparent = true
--vim.g.tokyonight_hide_inactive_statusline = true
vim.g.tokyonight_transparent_sidebar = true
vim.g.tokyonight_dark_float = false
vim.g.tokyonight_italic_keywords = false
--vim.g.tokyonight_bold_functions = true
--vim.g.tokyonight_lualine_bold = true

-- Change the "hint" color to the "orange" color, and make the "error" color bright red
--

--vim.g.tokyonight_colors = { hint = "orange", error = "#ff0000" }
vim.g.tokyonight_lualine_bold = true
local hl = function(thing, opts)
  vim.api.nvim_set_hl(0, thing, opts)
end
------ Load the colorscheme
vim.cmd([[
colorscheme tokyonight
]])

vim.cmd([[highlight Function gui=bold]])
vim.cmd([[highlight TelescopeNormal guibg=#ffffffff]])
vim.cmd([[highlight TelescopeBorder guibg=#ffffffff]])
vim.cmd([[highlight  TreesitterContext guibg=#33467C]])
vim.cmd([[highlight BufferLineFill guibg='$ffffffff']])
vim.cmd([[highlight BufferLineIndicatorSelected guifg='#5eacd3']])

hl("SignColumn", {
  bg = "none",
})

hl("ColorColumn", {
  ctermbg = 0,
  bg = "#555555",
})

hl("CursorLineNR", {
  bg = "None"
})

hl("Normal", {
  bg = "none"
})

hl("LineNr", {
  fg = "#5eacd3"
})
--hl("Function", {
--fg = bold
--})
require 'lspsaga'.init_lsp_saga({
  saga_winblend = 100,
  border_style = "single",
})
