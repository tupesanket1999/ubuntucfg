require("formatter").setup(
  {
    filetype = {
      javascript = {
        -- prettier
        function()
          return {
            exe = "./node_modules/prettier/bin-prettier.js",
            args = { "--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)) },
            stdin = true
          }
        end
      },
      typescriptreact = {
        -- prettier
        function()
          return {
            exe = "./node_modules/prettier/bin-prettier.js",
            args = { "--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)) },
            stdin = true
          }
        end
      },
      javascriptreact = {
        -- prettier
        function()
          return {
            exe = "./node_modules/prettier/bin-prettier.js",
            args = { "--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)) },
            stdin = true
          }
        end
      },
      typescript = {
        -- prettier
        function()
          return {
            exe = "./node_modules/prettier/bin-prettier.js",
            args = { "--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)) },
            stdin = true
          }
        end
      },
      lua = {
        -- luafmt
        function()
          return {
            exe = "luafmt",
            args = { "--indent-count", 2, "--stdin" },
            stdin = true
          }
        end
      }
    }
  }
)
