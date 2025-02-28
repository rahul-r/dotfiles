-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

vim.keymap.set("n", "<C-p>", "<cmd>Telescope fd<CR>", { desc = "File picker", remap = true })
vim.keymap.set("n", "<leader>/", "gcc", { desc = "Comment line", remap = true })
vim.keymap.set("v", "<leader>/", "gcc", { desc = "Comment line", remap = true })
vim.keymap.set("x", "<leader>/", "gc", { desc = "Comment selection", remap = true })
vim.keymap.set("n", "<leader>qw", "<cmd>x<cr>", { desc = "Save file and quit" })
vim.keymap.set("n", "<leader>ww", "<cmd>w<cr>", { desc = "Save file" })
vim.keymap.set("n", "<leader>h", "<cmd>nohl<cr>", { desc = "No highlight" })

vim.keymap.set("n", "<leader>tr", "<cmd>Trouble lsp_references<cr>", { desc = "References" })
vim.keymap.set("n", "<leader>tf", "<cmd>Trouble lsp_definitions<cr>", { desc = "Definitions" })
vim.keymap.set("n", "<leader>td", "<cmd>Trouble document_diagnostics<cr>", { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>tq", "<cmd>Trouble quickfix<cr>", { desc = "QuickFix" })
vim.keymap.set("n", "<leader>tl", "<cmd>Trouble loclist<cr>", { desc = "LocationList" })
vim.keymap.set("n", "<leader>tw", "<cmd>Trouble workspace_diagnostics<cr>", { desc = "Workspace Diagnostics" })

vim.keymap.set("n", "<leader>ghh", "<cmd>DiffviewFileHistory %<cr>", { desc = "This file history" })
vim.keymap.set("n", "<leader>ghH", "<cmd>DiffviewFileHistory<cr>", { desc = "All file history" })
vim.keymap.set("n", "<leader>ghq", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" })
vim.keymap.set("n", "<leader>ght", "<cmd>DiffviewToggleFiles<cr>", { desc = "Toggle file list" })
vim.keymap.set("n", "<leader>ghr", "<cmd>DiffviewRefresh<cr>", { desc = "Refresh" })

vim.keymap.set("n", "<leader>cE", function() LazyVim.format.toggle() end, { desc = "Toggle Auto Format (Global)" })
vim.keymap.set("n", "<leader>ce", function() LazyVim.format.toggle(true) end, { desc = "Toggle Auto Format (Buffer)" })

vim.keymap.set("n", "<leader>ci", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(nil)) end, { desc = "Toggle inlay hints" })
