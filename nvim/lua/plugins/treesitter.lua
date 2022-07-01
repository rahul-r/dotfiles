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
    enable = true,
	disable = {},
  },
  rainbow = {
    enable = true,
    extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
    max_file_lines = nil, -- Do not enable for files with more than n lines, int
  },
}