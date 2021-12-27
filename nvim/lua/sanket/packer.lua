require("packer").startup(
  function()
    use "wbthomason/packer.nvim"

    --"colorscheme
    --"
    use "morhetz/gruvbox"

    --"telescope
    --"
    use "nvim-lua/popup.nvim"
    use "nvim-lua/plenary.nvim"
    use "nvim-telescope/telescope.nvim"
    use "kyazdani42/nvim-web-devicons"
    use {"nvim-telescope/telescope-fzf-native.nvim", run = "make"}
    use "nvim-telescope/telescope-project.nvim"

    --"lsp
    --"
    use "neovim/nvim-lspconfig"
    use {"nvim-treesitter/nvim-treesitter", run = ":TSUpdate"}
    use "hrsh7th/nvim-compe"
    use "windwp/nvim-autopairs"
    use "RRethy/vim-illuminate"
    use "mhartington/formatter.nvim"

    --"utils
    --"
    use "szw/vim-maximizer"
    use "preservim/nerdcommenter"
    use "mbbill/undotree"
    use "kyazdani42/nvim-tree.lua"
    use "folke/which-key.nvim"
    use "lukas-reineke/indent-blankline.nvim"

    --"debugger
    --"
    use "mfussenegger/nvim-dap"
    use "nvim-telescope/telescope-dap.nvim"
    use "rcarriga/nvim-dap-ui"
    use "theHamsta/nvim-dap-virtual-text"

    --"git
    --"
    use "lewis6991/gitsigns.nvim"
    use "TimUntersberger/neogit"
    use "sindrets/diffview.nvim"

    --"powerline
    --"
    use "hoob3rt/lualine.nvim"
    use "akinsho/nvim-bufferline.lua"
  end
)
