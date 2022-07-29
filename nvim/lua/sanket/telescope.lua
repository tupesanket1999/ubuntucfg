require("telescope").setup {
  defaults = {
    file_ignore_patterns = { "node_modules", "undodir" }
  },
  extensions = {
    fzf = {
      fuzzy = true, -- false will only do exact matching
      override_generic_sorter = false, -- override the generic sorter
      override_file_sorter = true, -- override the file sorter
      case_mode = "smart_case" -- or "ignore_case" or "respect_case"
      -- the default case_mode is "smart_case"
    },
  }
}
require("telescope").load_extension("fzf")
require("telescope").load_extension("dap")
require("telescope").load_extension("session-lens")
require("telescope").load_extension("refactoring")
-- remap to open the Telescope refactoring menu in visual mode
vim.api.nvim_set_keymap(
  "v",
  "<leader>rr",
  "<Esc><cmd>lua require('telescope').extensions.refactoring.refactors()<CR>",
  { noremap = true }
)
