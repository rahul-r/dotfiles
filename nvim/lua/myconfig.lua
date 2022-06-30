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
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- Linebreak on 500 characters
vim.opt.linebreak = true
vim.opt.textwidth=500

vim.opt.ai = true --Auto indent
vim.opt.si = true --Smart indent
vim.opt.wrap = true --Wrap lines

vim.cmd([[
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  "    Turn persistent undo on
  "    means that you can undo even when you close a buffer/VIM
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  try
      set undodir=~/.vim/tmp/undo
      set undofile
  catch
  endtry
  """"""""""""""""""""""""""""""
  "       Opening/Closing
  """"""""""""""""""""""""""""""
  " Return to last edit position when opening files
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

  " Delete trailing white space on save, useful for some filetypes ;)
  fun! CleanExtraSpaces()
      let save_cursor = getpos(".")
      let old_query = getreg('/')
      silent! %s/\s\+$//e
      call setpos('.', save_cursor)
      call setreg('/', old_query)
  endfun

  if has("autocmd")
      autocmd BufWritePre *.txt,*.js,*.py,*.wiki,*.sh,*.coffee :call CleanExtraSpaces()
          " set filetypes as typescriptreact
          autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescriptreact
  endif

  let g:ctrlp_custom_ignore = {
          \ 'dir': '\v[\/]\.(git|hg|svn)|node_modules|venv|build|dist$',
          \ 'file': '\v\.(DS_Store|exe|so|dll)$',
          \}
]])

-- Indent commants with code in languages like Python, Perl
vim.cmd('filetype plugin indent on')

-- Set the color theme
vim.cmd("colorscheme nightfox")
--set background=dark

vim.opt.mouse=a

-- Always show the statusbar
vim.opt.laststatus=2
