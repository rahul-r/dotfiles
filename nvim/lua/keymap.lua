-- Change the leader key
vim.g.mapleader = " "

vim.cmd([[
  " Enforce laziness
  "nnoremap <Left> :echo "Don't be silly, use h"<CR>
  "nnoremap <Down> :echo "Don't be silly, use j"<CR>
  "nnoremap <Up> :echo "Don't be silly, use k"<CR>
  "nnoremap <Right> :echo "Don't be silly, use l"<CR>
]])

vim.keymap.set('n', '<C-J>', '<C-W><C-J>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-K>', '<C-W><C-K>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-L>', '<C-W><C-L>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-H>', '<C-W><C-H>', { noremap = true, silent = true })

-- Telescope keymaps
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<CR>', { noremap = true, silent = true })
