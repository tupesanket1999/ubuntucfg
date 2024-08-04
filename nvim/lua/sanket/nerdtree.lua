require "nvim-tree".setup {
    actions = {
        open_file = {
            resize_window = false,
        }
    }
    ,
    diagnostics = {
        enable = true,
        icons = {
            error = " ",
            warning = " ",
            hint = " ",
            info = " "
        }
    },
    update_focused_file = {
        enable = true,
        --update_cwd = true,
        ignore_list = {}
    },
    disable_netrw = true,
    hijack_netrw = true,
    hijack_cursor = true,
    update_cwd = true,
    --update_to_buf_dir = {
    --enable = true,
    --auto_open = true
    --}
}
