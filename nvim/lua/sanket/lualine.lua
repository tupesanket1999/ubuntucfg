require("bufferline").setup {
  options = {
    close_command = "bdelete! %d", -- can be a string | function, see "Mouse actions"
    left_mouse_command = "buffer %d", -- can be a string | function, see "Mouse actions"
    close_icon = '',
    diagnostics = "nvim_lsp",
    diagnostics_update_in_insert = false,
    -- The diagnostics indicator can be set to nil to keep the buffer name highlight but delete the highlighting
    diagnostics_indicator = function(count, level, diagnostics_dict, context)
      return "(" .. count .. ")"
    end,
    show_close_icon = false,
    separator_style = { '', '' },
    indicator_icon = ">>>  ",
    show_buffer_close_icons = true,
    color_icons = true
    --indicator_icon = ""
  },
  highlights = {
    buffer_selected = {
      gui = "bold",
    },
    diagnostic_selected = {
      gui = "bold"
    },
    hint_selected = {
      gui = "bold",
    },
    hint_diagnostic_selected = {
      gui = "bold",
    },
    info_selected = {
      gui = "bold",
    },
    info_diagnostic_selected = {
      gui = "bold",
    },
    warning_selected = {
      gui = "bold",
    },
    warning_diagnostic_selected = {
      gui = "bold",
    },
    error_selected = {
      gui = "bold",
    },
    error_diagnostic_selected = {
      gui = "bold",
    },
    pick_selected = {
      gui = "bold",
    },
    pick_visible = {
      gui = "bold",
    },
    pick = {
      gui = "bold",
    },
    indicator_selected = {
      guifg = '#ffffff',
      guibg = '#ffffff'
    },
  }


  --highlights = {
  --buffer_selected = {
  --guibg = "#076678",
  --gui = "bold"
  --},
  --modified_selected = {
  --guibg = "#076678",
  --}
  --}
}


local custom_ayu = require "lualine.themes.ayu_dark"
-- Change the background of lualine_c section for normal mode
--custom_ayu.normal.a.fg = '#ffffff' -- rgb colors are supported
custom_ayu.normal.c.fg = "#ffffff" -- rgb colors are supported
custom_ayu.normal.a.fg = "#ffffff" -- rgb colors are supported
custom_ayu.insert.a.fg = "#ffffff" -- rgb colors are supported
custom_ayu.visual.a.fg = "#ffffff" -- rgb colors are supported
custom_ayu.visual.a.bg = "#ff9f00" -- rgb colors are supported

require "lualine".setup {
  options = {
    --theme = custom_ayu
    theme = 'tokyonight',
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { 'filename' },
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' }
  },
}
