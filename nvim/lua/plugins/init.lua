vim.cmd [[packadd packer.nvim]]

require("plugins.treesitter")
require("plugins.coc")
require("plugins.telescope")
require("plugins.airline")
require("plugins.blamer")
require("plugins.which-key")
require("plugins.nvim-tree")

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
	use 'kyazdani42/nvim-tree.lua'
	-- Key binding helper
	use 'folke/which-key.nvim'

	-- Git
	use 'tpope/vim-fugitive'
	use 'APZelos/blamer.nvim'
	use 'airblade/vim-gitgutter'

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
end)

