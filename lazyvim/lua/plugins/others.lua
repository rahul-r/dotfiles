return {
  -- autoclose and autorename html tag
  {
    "windwp/nvim-ts-autotag",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
  -- rainbow parentheses
  {
    "p00f/nvim-ts-rainbow",
  },
  {
    "karb94/neoscroll.nvim",
    event = "WinScrolled",
    config = function()
      require("neoscroll").setup({
        -- All these keys will be mapped to their corresponding default scrolling animation
        mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
        hide_cursor = true, -- Hide cursor while scrolling
        stop_eof = true, -- Stop at <EOF> when scrolling downwards
        use_local_scrolloff = false, -- Use the local scope of scrolloff instead of the global scope
        respect_scrolloff = false, -- Stop scrolling when the cursor reaches the scrolloff margin of the file
        cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
        easing_function = nil, -- Default easing function
        pre_hook = nil, -- Function to run before the scrolling animation starts
        post_hook = nil, -- Function to run after the scrolling animation ends
      })
    end,
  },
  -- pick up where you left off
  {
    "ethanholz/nvim-lastplace",
    event = "BufRead",
    config = function()
      require("nvim-lastplace").setup({
        lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
        lastplace_ignore_filetype = {
          "gitcommit",
          "gitrebase",
          "svn",
          "hgcommit",
        },
        lastplace_open_folds = true,
      })
    end,
  },
  -- -- highlight and search for todo comments
  -- {
  --   "folke/todo-comments.nvim",
  --   event = "BufRead",
  --   config = function()
  --     require("todo-comments").setup()
  --   end,
  -- },
  {
    "rmagatti/auto-session",
    config = function()
      -- Couldn't get auto save working; as a workaround, run ":SaveSession" in neovim to save the current session
      require("auto-session").setup({
        log_level = "error",
        auto_save_enabled = true,
        auto_restore_enabled = true,
      })
    end,
  },
  {
    "nmac427/guess-indent.nvim",
    config = function()
      require("guess-indent").setup({})
    end,
  },
  -- {
  --   "zbirenbaum/copilot-cmp",
  --   event = "InsertEnter",
  --   dependencies = { "zbirenbaum/copilot.lua" },
  --   config = function()
  --     vim.defer_fn(function()
  --       -- https://github.com/zbirenbaum/copilot.lua/blob/master/README.md#setup-and-configuration
  --       require("copilot").setup({
  --         suggestion = {
  --           auto_trigger = true,
  --         },
  --       })
  --       -- https://github.com/zbirenbaum/copilot-cmp/blob/master/README.md#configuration
  --       require("copilot_cmp").setup()
  --     end, 100)
  --   end,
  -- },
}
