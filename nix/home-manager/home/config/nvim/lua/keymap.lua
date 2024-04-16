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

-- 'jk' for quitting insert mode options)
vim.keymap.set('i', "jk", "<ESC>", options)
-- 'kj' for quitting insert mode options)
vim.keymap.set('i', "kj", "<ESC>", options)
-- 'jj' for quitting insert mode options)
vim.keymap.set('i', "jj", "<ESC>", options)
-- Move current line / block with Alt-j/k ala vscode. options)
vim.keymap.set('i', "<A-j>", "<Esc>:m .+1<CR>==gi", options)
vim.keymap.set('i', "<A-k>", "<Esc>:m .-2<CR>==gi", options)
vim.keymap.set('n', "<A-j>", ":m .+1<CR>==gi", options)
vim.keymap.set('n', "<A-k>", ":m .-2<CR>==gi", options)
vim.keymap.set('v', "<A-j>", ":m '>+1<CR>gv-gv", options)
vim.keymap.set('v', "<A-k>", ":m '<-2<CR>gv-gv", options)
-- navigation options)
vim.keymap.set('i', "<A-Up>", "<C-\\><C-N><C-w>k", options)
vim.keymap.set('i', "<A-Down>", "<C-\\><C-N><C-w>j", options)
vim.keymap.set('i', "<A-Left>", "<C-\\><C-N><C-w>h", options)
vim.keymap.set('i', "<A-Right>", "<C-\\><C-N><C-w>l", options)
-- Better window movement
vim.keymap.set('n', "<C-h>", "<C-w>h", options)
vim.keymap.set('n', "<C-j>", "<C-w>j", options)
vim.keymap.set('n', "<C-k>", "<C-w>k", options)
vim.keymap.set('n', "<C-l>", "<C-w>l", options)
-- Terminal window navigation
vim.keymap.set('t', "<C-h>", "<C-\\><C-N><C-w>h", options)
vim.keymap.set('t', "<C-j>", "<C-\\><C-N><C-w>j", options)
vim.keymap.set('t', "<C-k>", "<C-\\><C-N><C-w>k", options)
vim.keymap.set('t', "<C-l>", "<C-\\><C-N><C-w>l", options)
-- Resize with arrows
vim.keymap.set('n', "<C-Up>", ":resize -2<CR>", options)
vim.keymap.set('n', "<C-Down>", ":resize +2<CR>", options)
vim.keymap.set('n', "<C-Left>", ":vertical resize -2<CR>", options)
vim.keymap.set('n', "<C-Right>", ":vertical resize +2<CR>", options)
-- Tab switch buffer
vim.keymap.set('n', "<S-l>", ":BufferLineCycleNext<CR>", options)
vim.keymap.set('n', "<S-h>", ":BufferLineCyclePrev<CR>", options)
-- QuickFix
vim.keymap.set('n', "]q", ":cnext<CR>", options)
vim.keymap.set('n', "[q", ":cprev<CR>", options)
vim.keymap.set('n', "<C-q>", ":call QuickFixToggle()<CR>", options)

vim.keymap.set('n', "<C-F>", function() vim.lsp.buf.formatting_sync(nil, 4000) end, options)
vim.keymap.set('n', "ga", function() vim.lsp.buf.code_action(nil, 4000) end, options)
vim.keymap.set('n', "K", function() vim.lsp.buf.hover() end, options)
vim.keymap.set('n', "gd", function() vim.lsp.buf.definition() end, options)
vim.keymap.set('n', "gD", function() vim.lsp.buf.declaration() end, options)
vim.keymap.set('n', "gr", function() vim.lsp.buf.references() end, options)
vim.keymap.set('n', "gI", function() vim.lsp.buf.implementation() end, options)
vim.keymap.set('n', "gs", function() vim.lsp.buf.signature_help() end, options)
vim.keymap.set('n', "gp", function() require("plugins.lsp.peek").Peek "definition" end, options)

-- Telescope keymaps
--vim.keymap.set('n', '<C-p>', '<cmd>Telescope find_files<CR>', options)
vim.keymap.set('n', '<C-p>', function() require("telescope.builtin").find_files(require("telescope.themes").get_dropdown({previewer = false})) end, options)
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope git_files<CR>', options)
--vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', options)
vim.keymap.set("n", "<leader>fg", function() require('telescope').extensions.live_grep_args.live_grep_args() end, options)
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<CR>', options)
vim.keymap.set('n', '<leader>fhh', '<cmd>Telescope help_tags<CR>', options)
vim.keymap.set('n', '<leader>fhb', '<cmd>Telescope builtins<CR>', options)
vim.keymap.set('n', '<leader>fl', '<cmd>Telescope reloader<CR>', options)
vim.keymap.set('n', '<leader>fw', '<cmd>Telescope grep_string<CR>', options)
vim.keymap.set('n', '<leader>th', '<cmd>Telescope colorscheme<CR>', options)
vim.keymap.set('n', '<leader>fr', '<cmd>Telescope registers<CR>', options)
vim.keymap.set('n', '<leader>fk', '<cmd>Telescope keymaps<CR>', options)
vim.keymap.set('n', '<leader>fd', '<cmd>Telescope resume<CR>', options)
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

-- Trouble keymaps
vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<cr>", options)
vim.keymap.set("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", options)
vim.keymap.set("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", options)
vim.keymap.set("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>", options)
vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", options)
vim.keymap.set("n", "gR", "<cmd>Trouble lsp_references<cr>", options)

-- Toggleterm keymaps
function _G.set_terminal_keymaps()
  local opts = {noremap = true}
  vim.api.nvim_buf_set_keymap(0, 't', '<esc>', [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', 'jk', [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-h>', [[<C-\><C-n><C-W>h]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-j>', [[<C-\><C-n><C-W>j]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-k>', [[<C-\><C-n><C-W>k]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-l>', [[<C-\><C-n><C-W>l]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

-- Function to make it easier to copy from neovim using mouse
function COPY()
  vim.opt.number = false
  vim.opt.relativenumber = false
  vim.cmd('set mouse=n')
  vim.cmd('Gitsigns detach_all')
  vim.cmd('startinsert')
end
