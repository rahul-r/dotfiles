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
vim.keymap.set('n', '<C-p>', '<cmd>Telescope find_files<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope git_files<CR>', { noremap = true, silent = true })
--vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', { noremap = true, silent = true })
vim.keymap.set("n", "<leader>fg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fhh', '<cmd>Telescope help_tags<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fhb', '<cmd>Telescope builtins<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fl', '<cmd>Telescope reloader<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fw', '<cmd>Telescope grep_string<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>th', '<cmd>Telescope colorscheme<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fr', '<cmd>Telescope registers<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fk', '<cmd>Telescope keymaps<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>gcc', '<cmd>Telescope git_commits<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>gcb', '<cmd>Telescope git_bcommits<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>gb', '<cmd>Telescope git_branches<CR>', { noremap = true, silent = true }) -- Lists buffer's git commits with diff preview and checks them out on <cr>
vim.keymap.set('n', '<leader>gs', '<cmd>Telescope git_status<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>gt', '<cmd>Telescope git_stash<CR>', { noremap = true, silent = true })

-- nvim-tree keymaps
vim.keymap.set('n', '<leader>nf', ':NvimTreeFindFile<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>nc', '<cmd>NvimTreeCollapse<CR>', { noremap = true, silent = true })

-- symbols-outline keymaps
vim.keymap.set('n', '<space>m', '<cmd>SymbolsOutline<CR>', { noremap = true, silent = true })
