local present, nvimtree = pcall(require, "nvim-tree")

if not present then
    return
end

nvimtree.setup()

-- toggle 
vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
-- focus
vim.keymap.set('n', '<leader>NvimTreeFocuse', ':NvimTreeFocus<CR>', { noremap = true, silent = true })
