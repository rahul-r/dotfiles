return {
  -- add gruvbox
  { "ellisonleao/gruvbox.nvim" },

  { "olimorris/onedarkpro.nvim" },
  { "Th3Whit3Wolf/space-nvim" },
  { "tomasiser/vim-code-dark" },
  {
    "EdenEast/nightfox.nvim",
    config = function()
      require("nightfox").setup({
        options = {
          styles = {
            comments = "italic",
          },
        },
        groups = {
          all = {
            LineNr = { fg = "palette.bg4" },
            CursorLineNr = { fg = "palette.fg2" },
          },
        },
      })
    end,
  },
  { "marko-cerovac/material.nvim" },
  { "romgrk/doom-one.vim" },
  {
    "navarasu/onedark.nvim",
    config = function()
      require("material").setup({
        plugins = {
          "dashboard",
          "gitsigns",
          "nvim-tree",
          "nvim-web-devicons",
          "telescope",
          "trouble",
          "which-key",
        },
      })
    end,
  },

  -- Configure LazyVim to load a colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nightfox",
    },
  },
}
