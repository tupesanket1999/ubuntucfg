--require("bufferline").setup {
--options = {
--close_command = "bdelete! %d", -- can be a string | function, see "Mouse actions"
--left_mouse_command = "buffer %d", -- can be a string | function, see "Mouse actions"
--close_icon = '',
--diagnostics = "nvim_lsp",
--diagnostics_update_in_insert = false,
---- The diagnostics indicator can be set to nil to keep the buffer name highlight but delete the highlighting
--diagnostics_indicator = function(count, level, diagnostics_dict, context)
--return "(" .. count .. ")"
--end,
--show_close_icon = false,
--separator_style = { '', '' },
--indicator = ">>>  ",
--show_buffer_close_icons = true,
--color_icons = true
----indicator_icon = ""
--},
--highlights = {
--buffer_selected = {
----gui = "bold",
--italic = false
--},
--diagnostic_selected = {
----gui = "bold"
--italic = false
--},
--hint_selected = {
----gui = "bold",
--italic = false
--},
--hint_diagnostic_selected = {
----gui = "bold",
--italic = false
--},
--info_selected = {
----gui = "bold",
--italic = false
--},
--info_diagnostic_selected = {
----gui = "bold",
--italic = false
--},
--warning_selected = {
----gui = "bold",
--italic = false
--},
--warning_diagnostic_selected = {
----gui = "bold",
--italic = false
--},
--error_selected = {
----gui = "bold",
--italic = false
--},
--error_diagnostic_selected = {
----gui = "bold",
--italic = false
--},
--pick_selected = {
----gui = "bold",
--italic = false
--},
--pick_visible = {
----gui = "bold",
--italic = false
--},
--pick = {
----gui = "bold",
--italic = false
--},
--indicator_selected = {
--fg = '#ffffff',
--bg = '#ffffff'
--},
--}


--highlights = {
--buffer_selected = {
--guibg = "#076678",
--gui = "bold"
--},
--modified_selected = {
--guibg = "#076678",
--}
--}
--}


--local custom_ayu = require "lualine.themes.ayu_dark"
---- Change the background of lualine_c section for normal mode
----custom_ayu.normal.a.fg = '#ffffff' -- rgb colors are supported
--custom_ayu.normal.c.fg = "#ffffff" -- rgb colors are supported
--custom_ayu.normal.a.fg = "#ffffff" -- rgb colors are supported
--custom_ayu.insert.a.fg = "#ffffff" -- rgb colors are supported
--custom_ayu.visual.a.fg = "#ffffff" -- rgb colors are supported
--custom_ayu.visual.a.bg = "#ff9f00" -- rgb colors are supported

--require "lualine".setup {
--options = {
--theme = custom_ayu
----theme = 'tokyonight',
--},
--sections = {
--lualine_a = { 'mode' },
--lualine_b = { 'branch', 'diff', 'diagnostics' },
--lualine_c = { 'filename' },
--lualine_x = { 'encoding', 'fileformat', 'filetype' },
--lualine_y = { 'progress' },
--lualine_z = { 'location' }
--},
--}

require "lualine".setup {}

local get_hex = require('cokeline.hlgroups').get_hl_attr
require('cokeline').setup({
    --default_hl = {
    --fg = function(buffer)
    --return buffer.is_focused
    --and get_hex('Normal', 'fg')
    --or get_hex('Comment', 'fg')
    --end,
    --bg = get_hex('ColorColumn', 'bg'),
    --},

    --components = {
    --{
    --text = ' ',
    --bg = get_hex('Normal', 'bg'),
    --},
    --{
    --text = '',
    --fg = get_hex('ColorColumn', 'bg'),
    --bg = get_hex('Normal', 'bg'),
    --},
    --{
    --text = function(buffer)
    --return buffer.devicon.icon
    --end,
    --fg = function(buffer)
    --return buffer.devicon.color
    --end,
    --},
    --{
    --text = ' ',
    --},
    --{
    --text = function(buffer) return buffer.filename .. '  ' end,
    --style = function(buffer)
    --return buffer.is_focused and 'bold' or nil
    --end,
    --},
    --{
    --text = '',
    --delete_buffer_on_left_click = true,
    --},
    --{
    --text = '',
    --fg = get_hex('ColorColumn', 'bg'),
    --bg = get_hex('Normal', 'bg'),
    --},
    --},
})
