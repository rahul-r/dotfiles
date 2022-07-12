local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
  return
end

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

null_ls.setup({
  debug = false,
  sources = {
    formatting.eslint,
    formatting.beautysh,
    formatting.black, -- python
    --formatting.autopep8, -- python
    formatting.clang_format,
    formatting.cmake_format,
    --formatting.fixjson, -- json
    --formatting.jq, -- json
    formatting.gofmt, -- go
    formatting.goimports, -- go imports
    formatting.markdownlint,
    --formatting.mdformat, -- markdown -- This is messing up yaml frontmatter
    formatting.prettierd,
    formatting.qmlformat, -- qml
    formatting.rustfmt,
    formatting.black.with({ extra_args = { "--fast" } }),
    --formatting.stylua,
    --formatting.lua_format,

    diagnostics.flake8,
    diagnostics.eslint,
    diagnostics.cppcheck,
    --diagnostics.cspell,
    diagnostics.jsonlint,
    diagnostics.markdownlint,
    diagnostics.qmllint,
    diagnostics.stylelint,
    diagnostics.tsc,
    diagnostics.yamllint,
    diagnostics.zsh,
  },
  -- Format on save
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
          vim.lsp.buf.formatting_sync(nil, 4000)
        end,
      })
    end
  end,
})
