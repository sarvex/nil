local M = {}

vim.cmd [[
  function! QuickFixToggle()
    if empty(filter(getwininfo(), 'v:val.quickfix'))
      copen
    else
      cclose
    endif
  endfunction
]]

M.defaults = {
  {
    name = "NilToggleFormatOnSave",
    fn = function()
      require("nil.core.autocmds").toggle_format_on_save()
    end,
  },
  {
    name = "NilDiagnostics",
    fn = function()
      vim.diagnostic.open_float(0, { show_header = false, severity_sort = true, scope = "line" })
    end
  },
  {
    name = "NilFormat",
    fn = function()
      vim.lsp.buf.format({ async = true })
    end
  },
  {
    name = "NilRename",
    fn = function()
      require("nil.interface.rename").open()
    end
  },
  {
    name = "NilInfo",
    fn = function()
      require("nil.core.info").toggle_popup(vim.bo.filetype)
    end,
  },
  {
    name = "NilCacheReset",
    fn = function()
      require("nil.utils.hooks").reset_cache()
    end,
  },
  {
    name = "NilReload",
    fn = function()
      require("nil.config"):reload()
    end,
  },
  {
    name = "NilUpdate",
    fn = function()
      require("nil.bootstrap"):update()
    end,
  },
  {
    name = "NilSyncCorePlugins",
    fn = function()
      require("nil.plugin-loader").sync_core_plugins()
    end,
  },
  {
    name = "NilChangelog",
    fn = function()
      require("nil.core.telescope.custom-finders").view_lunarvim_changelog()
    end,
  },
  {
    name = "NilVersion",
    fn = function()
      print(require("nil.utils.git").get_nil_version())
    end,
  },
  {
    name = "NilOpenlog",
    fn = function()
      vim.fn.execute("edit " .. require("nil.core.log").get_path())
    end,
  },
}

function M.load(collection)
  local common_opts = { force = true }
  for _, cmd in pairs(collection) do
    local opts = vim.tbl_deep_extend("force", common_opts, cmd.opts or {})
    vim.api.nvim_create_user_command(cmd.name, cmd.fn, opts)
  end
end

return M
