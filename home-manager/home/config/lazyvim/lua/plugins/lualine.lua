return {
  "nvim-lualine/lualine.nvim",

  opts = function(_, opts)
    opts.options.section_separators = { left = "", right = "" }
    -- opts.sections.lualine_a = { { "mode", separator = { left = "", right = "" }, right_padding = 2 } }
    -- opts.sections.lualine_c[3].padding.left = 5
    -- opts.sections.lualine_b[#opts.sections.lualine_b + 1] = { separator = "??", padding = { left = 10, right = 10 } }
  end,
}
