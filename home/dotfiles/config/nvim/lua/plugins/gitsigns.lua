local present, gitsigns = pcall(require, "gitsigns")

if not present then
    return
end

gitsigns.setup({
    signs = {
        add = { hl = "DiffAdd", text = "│", numhl = "GitSignsAddNr" },
        change = { hl = "DiffChange", text = "│", numhl = "GitSignsChangeNr" },
        delete = { hl = "DiffDelete", text = "", numhl = "GitSignsDeleteNr" },
        topdelete = { hl = "DiffDelete", text = "‾", numhl = "GitSignsDeleteNr" },
        changedelete = { hl = "DiffChangeDelete", text = "~", numhl = "GitSignsChangeNr" },
    },
    current_line_blame = true,
    current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay = 300,
        ignore_whitespace = false,
    },
})
