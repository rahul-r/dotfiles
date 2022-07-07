local status_ok, lsp_installer = pcall(require, "nvim-lsp-installer")
if not status_ok then
  return
end

local lspconfig = require("lspconfig")

local servers = {
  "jsonls",
  "sumneko_lua",
  "bashls",
  "clangd",
  "cmake",
  "cssls",
  "dockerls",
  "eslint",
  "html",
  "tsserver",
  "marksman",
  "pyright",
  "rust_analyzer",
  "sqlls",
  "lemminx",
  "yamlls"
}

local function exists(name)
  local handle = io.popen("which " .. name)
  if handle ~= nil then
    local result = handle:read("*a")
    handle:close()
    return result ~= ''
  end
  return false
end

if exists("go") then
  table.insert(servers, "golangci_lint_ls")
end

if exists("cargo") then
  table.insert(servers, "taplo")
end

lsp_installer.setup({
  ensure_installed = servers,
})

for _, server in pairs(servers) do
  local opts = {
    on_attach = require("plugins.lsp.handlers").on_attach,
    capabilities = require("plugins.lsp.handlers").capabilities,
  }
  local has_custom_opts, server_custom_opts = pcall(require, "plugins.lsp.settings." .. server)
  if has_custom_opts then
    opts = vim.tbl_deep_extend("force", opts, server_custom_opts)
  end
  lspconfig[server].setup(opts)
end
