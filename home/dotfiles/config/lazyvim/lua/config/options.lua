-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.o.termguicolors = true
vim.opt.wrap = true

-- Prevent adding new line at end of files
vim.cmd("set nofixeol")
vim.cmd("set rnu")

function COPY()
  vim.opt.number = false
  vim.opt.relativenumber = false
  vim.cmd("set mouse=n")
  vim.cmd("Gitsigns detach_all")
  vim.cmd("startinsert")
end

-- Remove the "How-to disable mouse" menu item and the separator above it
vim.cmd("aunmenu PopUp.How-to\\ disable\\ mouse")
vim.cmd("aunmenu PopUp.-1-")

if vim.g.neovide then
  -- vim.o.guifont = "UbuntuMono Nerd Font:h13"
  vim.o.guifont = "DroidSansM Nerd Font"
end

-- Disable autoformat
vim.g.autoformat = false
