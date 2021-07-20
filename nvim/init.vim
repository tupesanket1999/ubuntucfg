call plug#begin('~/.vim/plugged')

"colorscheme
"
Plug 'morhetz/gruvbox'
Plug 'sainnhe/gruvbox-material'

"powerline
"
Plug 'hoob3rt/lualine.nvim'
Plug 'akinsho/nvim-bufferline.lua'

"telescope
"
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }

"LSP
"
Plug 'neovim/nvim-lspconfig'
Plug 'kabouzeid/nvim-lspinstall'
Plug 'hrsh7th/nvim-compe'
Plug 'Raimondi/delimitMate'
Plug 'jose-elias-alvarez/nvim-lsp-ts-utils'
Plug 'jose-elias-alvarez/null-ls.nvim'
Plug 'onsails/lspkind-nvim'
Plug 'RRethy/vim-illuminate'
Plug 'folke/trouble.nvim'
Plug 'glepnir/lspsaga.nvim'


"NODE
"
Plug 'puremourning/vimspector'
Plug 'szw/vim-maximizer'

"git
"
Plug 'lewis6991/gitsigns.nvim'
Plug 'tpope/vim-fugitive'

Plug 'preservim/nerdcommenter'
Plug 'mbbill/undotree'
Plug 'tpope/vim-surround'
Plug 'kyazdani42/nvim-tree.lua'

call plug#end()
lua require("sanket")
