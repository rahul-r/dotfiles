local telescope_ok, telescope = pcall(require, "telescope")

if not telescope_ok then
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
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"; the default case_mode is "smart_case"
    }
  }
}

telescope.load_extension('fzf') -- This require 'telescope-fzf-native.nvim' plugin
telescope.load_extension('live_grep_args') -- This require 'telescope-live-grep-args.nvim' plugin
