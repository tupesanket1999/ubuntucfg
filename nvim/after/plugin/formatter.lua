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
            python = {
                function()
                    return {
                        exe = "black",
                        args = { vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)) },
                        stdin = true,
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
            },
            java = {
                -- java
                function()
                    return {
                        exe = "/usr/lib/jvm/java-11-openjdk-amd64/bin/java",
                        args = { '-jar', os.getenv('HOME') .. '/.config/nvim/bin/google-java-format-1.8-all-deps.jar',
                            vim.api.nvim_buf_get_name(0) },
                        stdin = true
                    }
                end
            },
        }
    }
)
