--require('rose-pine').setup({
--variant = "moon", -- auto, main, moon, or dawn
--dark_variant = "moon", -- main, moon, or dawn
--dim_inactive_windows = false,
--extend_background_behind_borders = true,

--styles = {
--bold = true,
--italic = false,
--transparency = true,
--},

--groups = {
--border = "muted",
--link = "iris",
--panel = "surface",

--error = "love",
--hint = "iris",
--info = "foam",
--warn = "gold",

--git_add = "foam",
--git_change = "rose",
--git_delete = "love",
--git_dirty = "rose",
--git_ignore = "muted",
--git_merge = "iris",
--git_rename = "pine",
--git_stage = "iris",
--git_text = "rose",
--git_untracked = "subtle",

--headings = {
--h1 = "iris",
--h2 = "foam",
--h3 = "rose",
--h4 = "gold",
--h5 = "pine",
--h6 = "foam",
--},
---- Alternatively, set all headings at once.
---- headings = "subtle",
--},

--highlight_groups = {
--Comment = { italic = true },
--Function = { bold = true }
----VertSplit = { fg = "muted", bg = "muted" },
--},

--before_highlight = function(group, highlight, palette)
---- Disable all undercurls
---- if highlight.undercurl then
----     highlight.undercurl = false
---- end
----
---- Change palette colour
---- if highlight.fg == palette.pine then
----     highlight.fg = palette.foam
---- end
--end,
--})

--vim.cmd('colorscheme rose-pine')












--vim.cmd('colorscheme gruvbox')
--vim.cmd.colorscheme("gruvbox")

-- Each highlight group must follow the structure:
-- ColorGroup = {fg = "foreground color", bg = "background_color", style = "some_style(:h attr-list)"}
-- See also :h highlight-guifg
-- Example:
--
--local colors = require("gruvbox-baby.colors").config()


vim.g.gruvbox_baby_transparent_mode = 1
vim.g.gruvbox_baby_background_color = "dark"
vim.g.gruvbox_baby_telescope_theme = 1
--vim.g.gruvbox_baby_highlights = { Normal = { fg = colors.milk } }
--vim.g.gruvbox_baby_color_overrides = { background = "#0d0e0f" } --#0d0e0f
vim.cmd.colorscheme "gruvbox-baby"




--vim.cmd("colorscheme kanagawa-dragon")
