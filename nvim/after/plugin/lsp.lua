local nvim_lsp = require("lspconfig")

--LSP FOR ESLINT
--
--
nvim_lsp.eslint.setup {}

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
require 'lspsaga'.init_lsp_saga({
  saga_winblend = 100,
  border_style = "single",
  code_action_icon = "",
  code_action_lightbulb = {
    enable = false,
    sign = false,
    enable_in_insert = false,
    sign_priority = 20,
    virtual_text = false,
  },
})

local function keymaps(buf_set_keymap, opts)
  buf_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
  buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  buf_set_keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>", { silent = true })
  buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  buf_set_keymap("n", "<space>gh", '<Cmd>Lspsaga signature_help<CR>', { silent = true, noremap = true })
  --buf_set_keymap("n", "<space>gh", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
  buf_set_keymap("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
  buf_set_keymap("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
  buf_set_keymap("n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
  buf_set_keymap("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
  buf_set_keymap("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  buf_set_keymap("n", "<space>ca", "<cmd>Lspsaga code_action<CR>", opts)
  --buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  buf_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
  buf_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
  buf_set_keymap("n", "<space>wd", "<cmd>Telescope diagnostics<CR>", opts)
end

--LSP FOR TSSERVER
--
--
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()) --nvim-cmp
capabilities.textDocument.completion.completionItem.snippetSupport = true
nvim_lsp.tsserver.setup {
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    local function buf_set_keymap(...)
      vim.api.nvim_buf_set_keymap(bufnr, ...)
    end

    local function buf_set_option(...)
      vim.api.nvim_buf_set_option(bufnr, ...)
    end

    -- Mappings.
    local opts = { noremap = true, silent = true }
    --NOT USING INBUIT FORMATTER
    --vim.cmd('autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting()')
    vim.cmd("autocmd BufWritePre <buffer> EslintFixAll")
    vim.api.nvim_exec(
      [[
    augroup FormatAutogroup
      autocmd!
      autocmd BufWritePost *.js,*.tsx,*.ts FormatWrite
    augroup END
  ]]   ,
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
  local opts = { noremap = true, silent = true }
  vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.format()")
  keymaps(buf_set_keymap, opts)
  buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.format()<CR>", opts)
end

--LSP FOR JSON
--
--
--local capabilities = vim.lsp.protocol.make_client_capabilities()
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()) --nvim-cmp
capabilities.textDocument.completion.completionItem.snippetSupport = true

nvim_lsp.jsonls.setup {
  capabilities = capabilities,
  commands = {
    Format = {
      function()
        vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line("$"), 0 })
      end
    }
  },
  on_attach = on_attach
}

--LSP FOR GO LANG
--
--
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
capabilities.textDocument.completion.completionItem.snippetSupport = true
nvim_lsp.gopls.setup {
  capabilities = capabilities,
  cmd = { "gopls", "serve" },
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
  on_attach = on_attach,
  init_options = {
    usePlaceholders = true,
  }
}

--LSP FOR CPP
--
--
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()) --nvim-cmp
capabilities.textDocument.completion.completionItem.snippetSupport = true
nvim_lsp.clangd.setup { on_attach = on_attach,
  capabilities = capabilities,
}

--LSP FOR LUA
--
--
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()) --nvim-cmp
capabilities.textDocument.completion.completionItem.snippetSupport = true
nvim_lsp.sumneko_lua.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

--Enable (broadcasting) snippet capability for completion
--local capabilities = vim.lsp.protocol.make_client_capabilities()
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()) --nvim-cmp
capabilities.textDocument.completion.completionItem.snippetSupport = true
nvim_lsp.html.setup {
  capabilities = capabilities,
  on_attach = on_attach
}

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()) --nvim-cmp
capabilities.textDocument.completion.completionItem.snippetSupport = true
--require 'lspconfig'.pylsp.setup {
--capabilities = capabilities,
--on_attach = on_attach
--}
require 'lspconfig'.pyright.setup {
  capabilities = capabilities,
  on_attach = on_attach
}
