--vim.cmd(":TSInstall all");
--

local hl = function(thing, opts)
	vim.api.nvim_set_hl(0, thing, opts)
end

hl("LineNr", {
	fg = "#5eacd3"
})

hl("Function", { fg = '#ea9a97', bold = true })

hl("TreesitterContext", { bg = "#1a1c1e" })
