require("telescope").setup {
  defaults = {file_ignore_patterns = {"node_modules", "undodir"}},
  extensions = {
    fzf = {
      fuzzy = true, -- false will only do exact matching
      override_generic_sorter = false, -- override the generic sorter
      override_file_sorter = true, -- override the file sorter
      case_mode = "smart_case" -- or "ignore_case" or "respect_case"
      -- the default case_mode is "smart_case"
    },
    project = {
      display_type = "full",
      base_dirs = {
        {path = "/home/sanket/gitlocal/uptycs/cloud"}
      }
    }
  }
}
-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require("telescope").load_extension("fzf")
require "telescope".load_extension("project")
require("telescope").load_extension("dap")

vim.api.nvim_set_keymap(
  "n",
  "<space>cp",
  ":lua require'telescope'.extensions.project.project{display_type = 'full'}<CR>",
  {noremap = true, silent = true}
)

vim.api.nvim_set_keymap(
  "n",
  "<space>fq",
  "<Cmd>lua require('telescope').extensions.frecency.frecency()<CR>",
  {noremap = true, silent = true}
)
