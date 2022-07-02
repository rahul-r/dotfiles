vim.cmd [[packadd packer.nvim]]

require("plugins.ctrlp")
require("plugins.treesitter")
require("plugins.coc")
require("plugins.telescope")
require("plugins.airline")
require("plugins.gitsigns")
require("plugins.which-key")
require("plugins.nvim-tree")
require("plugins.indent-blankline")

local present, colorizer = pcall(require, "colorizer")
if  present then
	colorizer.setup()
end

local present, Comment = pcall(require, "Comment")
if  present then
	Comment.setup()
end

local present, autopairs = pcall(require, "nvim-autopairs")
if  present then
	autopairs.setup()
end

return require('packer').startup(function()
	use 'wbthomason/packer.nvim'

	-- User interface
	-- Themes
	use "EdenEast/nightfox.nvim"
	-- Icons
	use 'ryanoasis/vim-devicons'
	-- Status bar
	use "vim-airline/vim-airline"
	-- Sidebar
	use {
		'kyazdani42/nvim-tree.lua',
		requires = {
			'kyazdani42/nvim-web-devicons',
		}
	}
	-- Key binding helper
	use 'folke/which-key.nvim'
	-- Indent visualizer
	use 'lukas-reineke/indent-blankline.nvim'
	-- Highlight color codes with actual color
	use 'norcalli/nvim-colorizer.lua'
	-- Smooth scrolling
	use 'psliwka/vim-smoothie'
	--- Automatically adjust 'shiftwidth' and 'expandtab' based on the current file
	use 'tpope/vim-sleuth'

	-- Git
	use 'tpope/vim-fugitive'
	use 'lewis6991/gitsigns.nvim'

	use { 'neoclide/coc.nvim', branch = 'release' }

	use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
	use 'p00f/nvim-ts-rainbow'

	use 'ctrlpvim/ctrlp.vim'

	-- Telescope and dependencies
	use 'nvim-lua/plenary.nvim'
	use {
		'nvim-telescope/telescope.nvim',
		requires = { {'nvim-lua/plenary.nvim'} }
	}

	-- Helpers
	use "windwp/nvim-autopairs" 
	use 'numToStr/Comment.nvim'
end)

