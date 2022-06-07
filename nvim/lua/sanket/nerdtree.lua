require "nvim-tree".setup {
  diagnostics = {
    enable = true,
    icons = {
      error = " ",
      warning = " ",
      hint = " ",
      info = " "
    }
  },
  update_focused_file = {
    enable = true,
    update_cwd = true,
    ignore_list = {}
  },
  disable_netrw = true,
  hijack_netrw = true,
  open_on_setup = false,
  ignore_ft_on_setup = {},
  hijack_cursor = true,
  update_cwd = true,
  update_to_buf_dir = {
    enable = true,
    auto_open = true
  }
}
