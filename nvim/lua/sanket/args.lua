local set = vim.opt
set.termguicolors = true
set.guicursor = ""
set.lazyredraw = true
set.relativenumber = true
set.hlsearch = false
set.hidden = true
set.errorbells = false
set.tabstop = 2
set.softtabstop = 2
set.shiftwidth = 2
set.expandtab = true
set.smartindent = true
set.nu = true
set.wrap = false
set.swapfile = false
set.backup = false
set.undodir = "/home/sanket/.local/share/nvim/undodir"
set.undofile = true
set.incsearch = true
set.scrolloff = 8
set.showmode = false
--"set signcolumn=yes
--set isfname+=@-@
--" set ls=0
--" Give more space for displaying messages.
set.cmdheight = 1
--" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
--" delays and poor user experience.
set.updatetime = 50
--" Don't pass messages to |ins-completion-menu|.
set.shortmess:append("c")
vim.wo.colorcolumn = "80"
set.showtabline = 2
set.completeopt = "menuone,noselect,noinsert"

--"LeaderKey
--"
vim.g.mapleader = " "
vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal"
