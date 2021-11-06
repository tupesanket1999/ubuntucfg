call plug#begin('~/.vim/plugged')

"colorscheme
"
Plug 'morhetz/gruvbox'


"telescope
"
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'nvim-telescope/telescope-project.nvim'


"lsp
"
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'hrsh7th/nvim-compe'
Plug 'Raimondi/delimitMate'
Plug 'neovim/nvim-lspconfig'
Plug 'onsails/lspkind-nvim'
Plug 'RRethy/vim-illuminate'
Plug 'folke/lsp-colors.nvim'
Plug 'mhartington/formatter.nvim'



"utils
"
Plug 'szw/vim-maximizer'
Plug 'preservim/nerdcommenter'
Plug 'mbbill/undotree'
Plug 'kyazdani42/nvim-tree.lua'
Plug 'folke/which-key.nvim'


"git
"
Plug 'lewis6991/gitsigns.nvim'
Plug 'TimUntersberger/neogit'

"powerline
"
Plug 'hoob3rt/lualine.nvim'
Plug 'akinsho/nvim-bufferline.lua'

call plug#end()
lua require("sanket")
