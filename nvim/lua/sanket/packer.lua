require("packer").startup(
	function()
		use "wbthomason/packer.nvim"

		--"colorscheme
		--"
		--use "rebelot/kanagawa.nvim"
		--use "morhetz/gruvbox"
		--use "gruvbox-community/gruvbox"
		--
		--use({ "ellisonleao/gruvbox.nvim" })
		--use "folke/tokyonight.nvim"
		--use({ 'rose-pine/neovim', as = 'rose-pine' })
		--use { "catppuccin/nvim", as = "catppuccin" }
		use "luisiacc/gruvbox-baby"
		--"telescope
		--"
		use "nvim-lua/popup.nvim"
		use "nvim-lua/plenary.nvim"
		use "nvim-telescope/telescope.nvim"
		use "kyazdani42/nvim-web-devicons"
		--use { "nvim-telescope/telescope-fzf-native.nvim", run = "make" }
		use { 'nvim-telescope/telescope-fzf-native.nvim',
			run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }
		use {
			"AckslD/nvim-neoclip.lua",
			requires = {
				{ 'nvim-telescope/telescope.nvim' },
			},
			config = function()
				require('neoclip').setup()
			end,
		}

		--"lsp
		--"
		use "neovim/nvim-lspconfig"
		use { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }
		use 'nvim-treesitter/playground'
		use 'nvim-treesitter/nvim-treesitter-context'
		use { "nvim-neotest/nvim-nio" }
		--use({
		--"glepnir/lspsaga.nvim",
		--opt = true,
		--branch = "main",
		--event = "LspAttach",
		--config = function()
		--require("lspsaga").setup({
		--lightbulb = {
		--enable = false,
		--},
		--ui = {
		---- This option only works in Neovim 0.9
		--title = true,
		---- Border type can be single, double, rounded, solid, shadow.
		--border = "single",
		--winblend = 0,
		--expand = "",
		--collapse = "",
		--code_action = "|",
		--incoming = " ",
		--outgoing = " ",
		--hover = ' ',
		--kind = {},
		--},
		--diagnostic = {
		--on_insert = false,
		--on_insert_follow = false,
		--insert_winblend = 0,
		--show_code_action = false,
		--show_source = true,
		--jump_num_shortcut = true,
		--max_width = 0.7,
		--max_height = 0.6,
		--max_show_width = 0.9,
		--max_show_height = 0.6,
		--text_hl_follow = true,
		--border_follow = true,
		--extend_relatedInformation = false,
		--keys = {
		--exec_action = 'o',
		--quit = 'q',
		--expand_or_jump = '<CR>',
		--quit_in_show = { 'q', '<ESC>' },
		--},
		--},
		--})
		--end,
		--requires = {
		--{ "nvim-tree/nvim-web-devicons" },
		----Please make sure you install markdown and markdown_inline parser
		--{ "nvim-treesitter/nvim-treesitter" }
		--}
		--})
		use({ 'scalameta/nvim-metals', requires = { "nvim-lua/plenary.nvim" } })
		use 'mfussenegger/nvim-jdtls'
		use { 'nvim-telescope/telescope-ui-select.nvim' }


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
		use {
			'declancm/maximize.nvim',
			config = function() require('maximize').setup() end
		}
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
		use({
			'willothy/nvim-cokeline',
			requires = 'kyazdani42/nvim-web-devicons', -- If you want devicons
			config = function()
				require('cokeline').setup()
			end
		})


		-- using packer.nvim
		--use { 'akinsho/bufferline.nvim', tag = "v2.*", requires = 'kyazdani42/nvim-web-devicons' }
	end
)
