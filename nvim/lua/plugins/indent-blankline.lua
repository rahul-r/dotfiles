local present, indent_blankline = pcall(require, "indent_blankline")

if not present then
	return
end

vim.opt.list = true
vim.opt.listchars:append("space:⋅")
--vim.opt.listchars:append("eol:↴")

indent_blankline.setup({
	indentLine_enabled = 1,
	use_treesitter = true,
	use_treesitter_scope = true,
	--char = "▏",
	--char_blankline = "▏",
	filetype_exclude = {
		"help",
		"terminal",
		"alpha",
		"packer",
		"lspinfo",
		"TelescopePrompt",
		"TelescopeResults",
		"lsp-installer",
		"",
	},
	buftype_exclude = { "terminal" },
	show_trailing_blankline_indent = false,
	show_first_indent_level = false,
	show_current_context = true,
	show_current_context_start = true,
	show_end_of_line = true,
})
