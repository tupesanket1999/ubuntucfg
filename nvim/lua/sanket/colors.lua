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

--vim.g.tokyonight_sidebars = { "qf", "vista_kind", "terminal", "packer", "TelescopePrompt" }
--vim.g.tokyonight_hide_inactive_statusline = true
vim.g.tokyonight_style = "night"
vim.g.tokyonight_italic_functions = false
vim.g.tokyonight_transparent = true
vim.g.tokyonight_transparent_sidebar = true
vim.g.tokyonight_dark_float = false
vim.g.tokyonight_italic_keywords = false
vim.g.tokyonight_lualine_bold = true

-- Change the "hint" color to the "orange" color, and make the "error" color bright red
--

--vim.g.tokyonight_colors = { hint = "orange", error = "#ff0000" }

vim.cmd([[
colorscheme tokyonight
]])

local hl = function(thing, opts)
  vim.api.nvim_set_hl(0, thing, opts)
end
------ Load the colorscheme


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

hl("TelescopeNormal", {
  bg = "NONE",
})

hl("TelescopeBorder", {
  fg = "#3d59a1"
})

hl("Function", { fg = "#7aa2f7", bold = true })

hl("TreesitterContext", { bg = "#33467C" })

hl("BufferLineFill", { bg = "NONE" })

--hl("BufferLineIndicatorSelected", { fg = "#5eacd3" })
