-- line numbering
vim.opt.relativenumber = true
vim.opt.number = true

-- set to auto read when a file is changed from the outside
vim.opt.autoread = true

-- Set 7 lines to the cursor - when moving vertically using j/k
vim.opt.scrolloff = 7

-- Turn on the Wild menu (for filename completion)
vim.opt.wildmenu = true
--vim.opt.wildmode = list:longest,full

-- Ignore case when searching
vim.opt.ignorecase = true

-- When searching try to be smart about cases
vim.opt.smartcase = true

-- Highlight search results
vim.opt.hlsearch = true

-- Highlight words while searching
vim.opt.incsearch = true

-- Don't redraw while executing macros (good performance config)
vim.opt.lazyredraw = true

-- the cursor will briefly jump to the matching brace when you insert one
vim.opt.showmatch = true
-- How many tenths of a second to blink when matching brackets
vim.opt.mat = 2

-- 1 tab == 4 spaces
-- 'tpope/vim-sleuth' plugin will automatically select space/tab based on the current file
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true

-- Linebreak on 500 characters
vim.opt.linebreak = true
vim.opt.textwidth=500

vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.wrap = true --Wrap lines

-- Prevent some plugins from hiding line numbers
vim.opt.signcolumn = "auto"

-- Turn persistent undo on, means that you can undo even when you close a buffer/vim
local pathprefix = vim.env.XDG_CONFIG_HOME or vim.fn.expand("~/.config")
vim.opt.undodir = { pathprefix .. "/nvim/undo//"}
vim.opt.undofile = true

-- Return to last edit position when opening files
vim.cmd([[ autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif ]])

vim.cmd([[
  if has("autocmd")
      "autocmd BufWritePre *.txt,*.js,*.py,*.wiki,*.sh,*.coffee :call CleanExtraSpaces()
      " set filetypes as typescriptreact
      autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescriptreact
  endif
]])

-- Automaticlly format JavaScript and TypeScript files on save
--vim.cmd([[ autocmd BufWritePre *.tsx,*.ts,*.jsx,*.js EslintFixAll ]])

-- Indent commants with code in languages like Python, Perl
vim.cmd('filetype plugin indent on')

-- Set the color theme
vim.cmd [[
    try
      colorscheme nightfox
      let g:airline_theme = 'selenized' " ouo, night_owl, paperclor
    catch /^Vim\%((\a\+)\)\=:E185/
      colorscheme default
      set background=dark
    endtry
]]
vim.opt.background = "dark"
vim.opt.termguicolors = true

vim.opt.cursorline = true  -- highlight current line

vim.cmd('set mouse=a')

-- Show global status bar
vim.opt.laststatus=3
