require'nvim-treesitter.configs'.setup {
  ensure_installed = {
	"c",
    "cpp", 
    "lua", 
    "rust", 
    "go", 
    "javascript", 
    "typescript",
	"tsx",
	"html",
	"css",
	"http",
	"json",
	"yaml",
	"bash",
	"python",
	"cmake",
	"make",
	"dockerfile",
	"regex",
  },
  sync_install = false,
  highlight = {
    enabled = true,
	disable = {},
  }
}

-- local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
-- parser_config.tsx.used_by = { "javascript", "typescript.tsx" }
