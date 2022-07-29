-- Compe setup
--require "compe".setup {
--enabled = true,
--autocomplete = true,
--debug = false,
--min_length = 1,
--preselect = "enable",
--throttle_time = 80,
--source_timeout = 200,
--incomplete_delay = 400,
--max_abbr_width = 100,
--max_kind_width = 100,
--max_menu_width = 100,
--documentation = true,
--source = {
--path = true,
--nvim_lsp = true,
--buffer = true,
--calc = true,
--nvim_lua = true
--}
--}

--local t = function(str)
--return vim.api.nvim_replace_termcodes(str, true, true, true)
--end

--local check_back_space = function()
--local col = vim.fn.col(".") - 1
--if col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
--return true
--else
--return false
--end
--end

---- Use (s-)tab to:
----- move to prev/next item in completion menuone
----- jump to prev/next snippet's placeholder
--_G.tab_complete = function()
--if vim.fn.pumvisible() == 1 then
--return t "<C-n>"
--elseif check_back_space() then
--return t "<Tab>"
--else
--return vim.fn["compe#complete"]()
--end
--end
--_G.s_tab_complete = function()
--if vim.fn.pumvisible() == 1 then
--return t "<C-p>"
--else
--return t "<S-Tab>"
--end
--end

--vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", { expr = true })
--vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", { expr = true })
--vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", { expr = true })
--vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", { expr = true })
--require("vim.lsp.protocol").CompletionItemKind = {
--"", -- Text
--"ƒ ", -- Method
--"ƒ ", -- Function
--" ", -- Constructor
--"", -- Field
--"", -- Variable
--"", -- Class
--"ﰮ", -- Interface
--"", -- Module
--"", -- Property
--"", -- Unit
--"", -- Value
--"了", -- Enum
--" ", -- Keyword
--"﬌", -- Snippet
--" ", -- Color
--"", -- File
--"", -- Reference
--"", -- Folder
--"", -- EnumMember
--" ", -- Constant
--"", -- Struct
--"", -- Event
--"ﬦ", -- Operator
--"" -- TypeParameter
--}
--
-- Setup nvim-cmp.
--
local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

local luasnip = require("luasnip")
local cmp = require 'cmp'
local lspkind = require("lspkind")
local source_mapping = {
  buffer = "[Buffer]",
  nvim_lsp = "[LSP]",
  nvim_lua = "[Lua]",
  cmp_tabnine = "[TN]",
  path = "[Path]",
  luasnip = "[Snippet]"
}

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'cmp_tabnine' },
    { name = 'luasnip' }, -- For luasnip users.
    { name = 'calc' },
    { name = 'nvim_lsp_signature_help' },
    {
      name = 'buffer',
      option = {
        get_bufnrs = function()
          local buf = vim.api.nvim_get_current_buf()
          local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
          if byte_size > 1024 * 1024 then -- 1 Megabyte max
            return {}
          end
          return { buf }
        end
      }
    }
  }),
  formatting = {
    fields = { 'abbr', 'kind', 'menu' },
    format = lspkind.cmp_format({
      mode = "symbol_text", -- options: 'text', 'text_symbol', 'symbol_text', 'symbol'
      maxwidth = 40, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)

      -- The function below will be called before any actual modifications from lspkind
      -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
      before = function(entry, vim_item)
        vim_item.kind = string.format("%s %s", lspkind.presets.default[vim_item.kind], vim_item.kind)
        local menu = source_mapping[entry.source.name]
        if entry.source.name == "cmp_tabnine" then
          if entry.completion_item.data ~= nil and entry.completion_item.data.detail ~= nil then
            menu = entry.completion_item.data.detail .. " " .. menu
          end
          vim_item.kind = ""
        end

        vim_item.menu = menu

        return vim_item
      end,
    }),
  },
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  sources = cmp.config.sources({
    { name = 'nvim_lsp_document_symbol' }
  }, {
    { name = 'buffer' }
  }),
  mapping = cmp.mapping.preset.cmdline(),
})
-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

require("luasnip.loaders.from_vscode").lazy_load()
