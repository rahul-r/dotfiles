return {
  {
    "f-person/git-blame.nvim",
    event = "BufRead",
    config = function()
      vim.cmd("highlight default link gitblame SpecialComment")
      vim.g.gitblame_message_template = "<author> • <date>"
      vim.g.gitblame_message_when_not_committed = "Not commited!"
    end,
  },

  -- git diff in a single tabpage
  {
    "sindrets/diffview.nvim",
    event = "BufRead",
  },
}
