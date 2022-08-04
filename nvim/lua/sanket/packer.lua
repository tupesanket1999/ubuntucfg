require("packer").startup(
  function()
    use "wbthomason/packer.nvim"

    --"colorscheme
    --"
    --use "morhetz/gruvbox"
    use "gruvbox-community/gruvbox"
    use "folke/tokyonight.nvim"

    --"telescope
    --"
    use "nvim-lua/popup.nvim"
    use "nvim-lua/plenary.nvim"
    use "nvim-telescope/telescope.nvim"
    use "kyazdani42/nvim-web-devicons"
    --use { "nvim-telescope/telescope-fzf-native.nvim", run = "make" }
    use { 'nvim-telescope/telescope-fzf-native.nvim',
      run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }

    --"lsp
    --"
    use "neovim/nvim-lspconfig"
    use { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }
    use 'nvim-treesitter/nvim-treesitter-context'
    use({
      "glepnir/lspsaga.nvim",
      branch = "main",
    })


    --use "hrsh7th/nvim-compe"
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-calc'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-cmdline'
    use 'hrsh7th/nvim-cmp'
    use("tzachar/cmp-tabnine", { run = "./install.sh" })
    use("saadparwaiz1/cmp_luasnip")
    use("L3MON4D3/LuaSnip")
    use "rafamadriz/friendly-snippets"
    use 'hrsh7th/cmp-nvim-lsp-signature-help'
    use('onsails/lspkind.nvim')

    use {
      "windwp/nvim-autopairs",
      config = function() require("nvim-autopairs").setup {} end
    }
    use "RRethy/vim-illuminate"
    use "mhartington/formatter.nvim"
    use "liuchengxu/vista.vim"
    use "simrat39/symbols-outline.nvim"
    use {
      "ThePrimeagen/refactoring.nvim",
      requires = {
        { "nvim-lua/plenary.nvim" },
        { "nvim-treesitter/nvim-treesitter" }
      }
    }

    --"utils
    --"
    use "szw/vim-maximizer"
    use "preservim/nerdcommenter"
    use "mbbill/undotree"
    use "kyazdani42/nvim-tree.lua"
    use "folke/which-key.nvim"
    use "lukas-reineke/indent-blankline.nvim"
    use "lewis6991/impatient.nvim"
    use {
      "rmagatti/session-lens",
      requires = { "rmagatti/auto-session", "nvim-telescope/telescope.nvim" },
      config = function()
        require("session-lens").setup({})
      end
    }

    --"debugger
    --"
    use "mfussenegger/nvim-dap"
    use "nvim-telescope/telescope-dap.nvim"
    use { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } }
    use 'leoluz/nvim-dap-go'
    use "theHamsta/nvim-dap-virtual-text"

    --"git
    --"
    use "lewis6991/gitsigns.nvim"
    use "TimUntersberger/neogit"
    use "sindrets/diffview.nvim"

    --"powerline
    --"
    use "hoob3rt/lualine.nvim"
    use "b0o/incline.nvim"
    -- using packer.nvim
    use { 'akinsho/bufferline.nvim', tag = "v2.*", requires = 'kyazdani42/nvim-web-devicons' }
  end
)
