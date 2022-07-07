local options = { silent = true }

-- Change the leader key
vim.g.mapleader = " "

vim.cmd([[
  " Enforce laziness
  "nnoremap <Left> :echo "Don't be silly, use h"<CR>
  "nnoremap <Down> :echo "Don't be silly, use j"<CR>
  "nnoremap <Up> :echo "Don't be silly, use k"<CR>
  "nnoremap <Right> :echo "Don't be silly, use l"<CR>
]])

vim.keymap.set('n', '<C-J>', '<C-W><C-J>', options)
vim.keymap.set('n', '<C-K>', '<C-W><C-K>', options)
vim.keymap.set('n', '<C-L>', '<C-W><C-L>', options)
vim.keymap.set('n', '<C-H>', '<C-W><C-H>', options)

vim.keymap.set('n', '<C-F>', '<cmd>lua vim.lsp.buf.formatting_sync(nil, 4000)<CR>', options)
vim.keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action(nil, 4000)<CR>', options)

-- Telescope keymaps
vim.keymap.set('n', '<C-p>', '<cmd>Telescope find_files<CR>', options)
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope git_files<CR>', options)
--vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', options)
vim.keymap.set("n", "<leader>fg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", options)
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<CR>', options)
vim.keymap.set('n', '<leader>fhh', '<cmd>Telescope help_tags<CR>', options)
vim.keymap.set('n', '<leader>fhb', '<cmd>Telescope builtins<CR>', options)
vim.keymap.set('n', '<leader>fl', '<cmd>Telescope reloader<CR>', options)
vim.keymap.set('n', '<leader>fw', '<cmd>Telescope grep_string<CR>', options)
vim.keymap.set('n', '<leader>th', '<cmd>Telescope colorscheme<CR>', options)
vim.keymap.set('n', '<leader>fr', '<cmd>Telescope registers<CR>', options)
vim.keymap.set('n', '<leader>fk', '<cmd>Telescope keymaps<CR>', options)
--vim.keymap.set('n', '<leader>gcc', '<cmd>Telescope git_commits<CR>', options)
--vim.keymap.set('n', '<leader>gcb', '<cmd>Telescope git_bcommits<CR>', options)
--vim.keymap.set('n', '<leader>gb', '<cmd>Telescope git_branches<CR>', options) -- Lists buffer's git commits with diff preview and checks them out on <cr>
vim.keymap.set('n', '<leader>gs', '<cmd>Telescope git_status<CR>', options)
vim.keymap.set('n', '<leader>gt', '<cmd>Telescope git_stash<CR>', options)

-- nvim-tree keymaps
vim.keymap.set('n', '<leader>nf', ':NvimTreeFindFile<CR>', options)
vim.keymap.set('n', '<leader>nc', '<cmd>NvimTreeCollapse<CR>', options)

-- symbols-outline keymaps
vim.keymap.set('n', '<space>m', '<cmd>SymbolsOutline<CR>', options)
