local present, telescope = pcall(require, "telescope")

if not present then
    return
end

telescope.setup {
	defaults = {
		layout_config = {
			preview_cutoff = 1,
			--layout_strategy = "flex",
			width = .7,
			preview_width = .7,
		},
		file_ignore_patterns = {
			"^./.git/",
			".cache",
			"node_modules/",
			"build/",
			"build_.*/",
			"dist/",
			"%.o",
			"%.a"
		}
	},
}
