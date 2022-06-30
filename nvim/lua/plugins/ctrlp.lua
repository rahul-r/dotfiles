vim.g.ctrlp_custom_ignore = [[{
   'dir': '\v[\/]\.(git|hg|svn)|node_modules|venv|build|dist$',
   'file': '\v\.(DS_Store|exe|so|dll)$',
}]]

vim.keymap.set('n', '<C-p><C-p>', ':CtrlPBuffer<CR>', { noremap = true, silent = true })
