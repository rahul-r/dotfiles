vim.cmd([[
 " Change the leader key
  let mapleader = " "

  " Enforce laziness
  "nnoremap <Left> :echo "Don't be silly, use h"<CR>
  "nnoremap <Down> :echo "Don't be silly, use j"<CR>
  "nnoremap <Up> :echo "Don't be silly, use k"<CR>
  "nnoremap <Right> :echo "Don't be silly, use l"<CR>

  "split navigations
  nnoremap <C-J> <C-W><C-J>
  nnoremap <C-K> <C-W><C-K>
  nnoremap <C-L> <C-W><C-L>
  nnoremap <C-H> <C-W><C-H>
]])

vim.cmd([[
  nnoremap <leader>ff <cmd>Telescope find_files<cr>
  nnoremap <leader>fg <cmd>Telescope live_grep<cr>
  nnoremap <leader>fb <cmd>Telescope buffers<cr>
  nnoremap <leader>fh <cmd>Telescope help_tags<cr>
]])
