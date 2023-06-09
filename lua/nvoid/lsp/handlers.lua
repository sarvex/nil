-- Set Default Prefix.
-- Note: You can set a prefix per lsp server in the lv-globals.lua file
local M = {}

function M.setup()
  local config = { -- your config
    virtual_text = nil.lsp.diagnostics.virtual_text,
    signs = nil.lsp.diagnostics.signs,
    underline = nil.lsp.diagnostics.underline,
    update_in_insert = nil.lsp.diagnostics.update_in_insert,
    severity_sort = nil.lsp.diagnostics.severity_sort,
    float = nil.lsp.diagnostics.float,
  }
  vim.diagnostic.config(config)
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, nil.lsp.float)
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, nil.lsp.float)
end

return M
