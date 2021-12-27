local nvim_lsp = require("lspconfig")
require "lspconfig".eslint.setup {}
require("which-key").setup {}
require("nvim-autopairs").setup {}

require("indent_blankline").setup {
  -- for example, context is off by default, use this to turn it on
  show_current_context = true,
  show_current_context_start = true
}

local signs = {Error = " ", Warn = " ", Hint = " ", Info = " "}
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, {text = icon, texthl = hl, numhl = hl})
end
--Default Keybindings for lsp
local function keymaps(buf_set_keymap, opts)
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
  buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
  buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  buf_set_keymap("n", "<space>gh", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
  buf_set_keymap("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
  buf_set_keymap("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
  buf_set_keymap("n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
  buf_set_keymap("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
  buf_set_keymap("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  buf_set_keymap("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  --buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  --buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap("n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
  buf_set_keymap("n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
  buf_set_keymap("n", "<space>q", "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>", opts)
end

--LSP FOR TSSERVER
--
--
nvim_lsp.tsserver.setup {
  on_attach = function(client, bufnr)
    local function buf_set_keymap(...)
      vim.api.nvim_buf_set_keymap(bufnr, ...)
    end
    local function buf_set_option(...)
      vim.api.nvim_buf_set_option(bufnr, ...)
    end
    -- Mappings.
    local opts = {noremap = true, silent = true}
    --NOT USING INBUIT FORMATTER
    --vim.cmd('autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting()')
    vim.cmd("autocmd BufWritePre <buffer> EslintFixAll")
    vim.api.nvim_exec(
      [[
    augroup FormatAutogroup
      autocmd!
      autocmd BufWritePost *.js,*.tsx,*.ts FormatWrite
    augroup END
  ]],
      true
    )
    keymaps(buf_set_keymap, opts)
    buf_set_keymap("n", "<space>f", "<cmd>Format<CR>", opts)
  end
}

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end
  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end
  -- Mappings.
  local opts = {noremap = true, silent = true}
  vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting()")
  keymaps(buf_set_keymap, opts)
  buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
end

--LSP FOR JSON
--
--
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
require "lspconfig".jsonls.setup {
  capabilities = capabilities,
  commands = {
    Format = {
      function()
        vim.lsp.buf.range_formatting({}, {0, 0}, {vim.fn.line("$"), 0})
      end
    }
  },
  on_attach = on_attach
}

--LSP FOR GO LANG
--
--
require "lspconfig".gopls.setup {
  cmd = {"gopls", "serve"},
  settings = {
    gopls = {
      experimentalPostfixCompletions = true,
      analyses = {
        unusedparams = true,
        shadow = true
      },
      staticcheck = true
    }
  },
  on_attach = on_attach
}

--LSP FOR CPP
--
--
require "lspconfig".clangd.setup {on_attach = on_attach}
require "lspconfig".sumneko_lua.setup {on_attach = on_attach}
