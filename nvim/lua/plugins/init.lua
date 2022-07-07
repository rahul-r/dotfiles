local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system({
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  })
  print("Installing packer close and reopen Neovim...")
  vim.cmd([[packadd packer.nvim]])
end

-- Use a protected call so we don't error out on first use
local packer_ok, packer = pcall(require, "packer")
if not packer_ok then
  return
end

-- Have packer use a popup window
packer.init({
  display = {
    open_fn = function()
      return require("packer.util").float({ border = "rounded" })
    end,
  },
})

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_config
    autocmd!
    autocmd BufWritePost */plugins/init.lua source <afile> | PackerSync
  augroup end
]])
-- Rewrite autocmd in lua
-- local augroup = vim.api.nvim_create_augroup("packer_sync", {})
-- vim.api.nvim_clear_autocmds({ group = augroup })
-- vim.api.nvim_create_autocmd("BufWritePost", {
--  group = augroup,
--  pattern = "*/plugins/init.lua",
--  callback = function()
--    source the file
--    packer.sync()
--  end
-- })

local use_lsp = true

--require("plugins.ctrlp")
require("plugins.treesitter")
require("plugins.telescope")
require("plugins.airline")
require("plugins.gitsigns")
require("plugins.which-key")
require("plugins.nvim-tree")
require("plugins.indent-blankline")
if use_lsp then
  require("plugins.luasnip")
  require("plugins.cmp")
  require("plugins.lsp")
  require("plugins.symbols-outline")
else
  require("plugins.coc")
end

local colorizer_ok, colorizer = pcall(require, "colorizer")
if colorizer_ok then
  colorizer.setup()
end

local Comment_ok, Comment = pcall(require, "Comment")
if Comment_ok then
  Comment.setup()
end

local autopairs_ok, autopairs = pcall(require, "nvim-autopairs")
if autopairs_ok then
  autopairs.setup()
end

return packer.startup(function(use)
  use 'wbthomason/packer.nvim'

  -- User interface
  -- Themes
  use "EdenEast/nightfox.nvim"
  use "lunarvim/darkplus.nvim"
  use "ellisonleao/gruvbox.nvim"

  -- Icons
  use 'ryanoasis/vim-devicons'
  -- Status bar
  use "vim-airline/vim-airline"
  use "vim-airline/vim-airline-themes"
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

  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use 'p00f/nvim-ts-rainbow'

  --use 'ctrlpvim/ctrlp.vim'

  if use_lsp then
    -- cmp plugins
    use("hrsh7th/nvim-cmp") -- The completion plugin
    use("hrsh7th/cmp-buffer") -- buffer completions
    use("hrsh7th/cmp-path") -- path completions
    use("saadparwaiz1/cmp_luasnip") -- snippet completions
    use("hrsh7th/cmp-nvim-lsp")
    use("hrsh7th/cmp-nvim-lua")
    use('simrat39/symbols-outline.nvim')

    -- snippets
    use("L3MON4D3/LuaSnip") --snippet engine
    use("rafamadriz/friendly-snippets") -- a bunch of snippets to use

    -- LSP
    use("neovim/nvim-lspconfig") -- enable LSP
    use("williamboman/nvim-lsp-installer") -- simple to use language server installer
    use("jose-elias-alvarez/null-ls.nvim") -- for formatters and linters
  else
    use { 'neoclide/coc.nvim', branch = 'release' }
  end

  -- Telescope and dependencies
  use 'nvim-lua/plenary.nvim'
  use "nvim-telescope/telescope-live-grep-args.nvim"
  use {
    'nvim-telescope/telescope-fzf-native.nvim',
    run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
  }
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  -- Helpers
  use "windwp/nvim-autopairs"
  use 'numToStr/Comment.nvim'

  -- Automatically set up configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)

