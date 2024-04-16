return {
  "nvimdev/dashboard-nvim",
  event = "VimEnter",

  opts = function(_, opts)
    opts.config.header = {}
    return opts
  end,
}
