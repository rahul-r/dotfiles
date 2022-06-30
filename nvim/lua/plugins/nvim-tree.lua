require("nvim-tree").setup()

-- toggle 
vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
-- focus
vim.keymap.set('n', '<leader>NvimTreeFocuse', ':NvimTreeFocus<CR>', { noremap = true, silent = true })
--["<leader>e"] = { "<cmd> NvimTreeFocus <CR>", "   focus nvimtree" },
