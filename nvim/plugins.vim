call plug#begin('~/.vim/plugged')
Plug 'preservim/nerdcommenter'
"Coc Completion
"
Plug 'honza/vim-snippets'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

"Formatter
"
Plug 'google/vim-glaive'
Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'


"Airline powerline
"
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-airline/vim-airline'

"telescope
"
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

"colorscheme
"
Plug 'morhetz/gruvbox'
Plug 'sheerun/vim-polyglot'

"Go Lang
"
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
 
"NERDTree
"
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'ryanoasis/vim-devicons'
Plug 'preservim/nerdtree'
Plug 'mbbill/undotree'
Plug 'Xuyuanp/nerdtree-git-plugin'

"Git Plugins
"
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

"REACT JS DEV
"
Plug 'frazrepo/vim-rainbow'
Plug 'prettier/vim-prettier', { 'do': 'yarn install' }
call plug#end()
