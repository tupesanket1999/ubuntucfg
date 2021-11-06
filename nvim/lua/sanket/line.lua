require('bufferline').setup {
  options = {
    show_buffer_close_icons = false,
    show_close_icon = false,
    separator_style = "thick",
    diagnostics = "nvim_lsp"
  }
}
local custom_ayu = require'lualine.themes.ayu_dark'
-- Change the background of lualine_c section for normal mode
--custom_ayu.normal.a.fg = '#ffffff' -- rgb colors are supported
custom_ayu.normal.c.fg = '#ffffff' -- rgb colors are supported
custom_ayu.normal.a.fg = '#ffffff' -- rgb colors are supported
custom_ayu.insert.a.fg = '#ffffff' -- rgb colors are supported
custom_ayu.visual.a.fg = '#ffffff' -- rgb colors are supported
custom_ayu.visual.a.bg = '#ff9f00' -- rgb colors are supported
require'lualine'.setup{
  options={
    theme=custom_ayu
  }
}
