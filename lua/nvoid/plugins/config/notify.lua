local M = {}

local Log = require "nil.core.log"
local icons = require("nil.interface.icons")
local defaults = {
  active = false,
  on_config_done = nil,
  opts = {
    stages = "slide",
    on_open = nil,
    on_close = nil,
    timeout = 5000,
    render = "default",
    background_colour = "Normal",
    minimum_width = 50,
    icons = {
      ERROR = icons.lsp.error,
      WARN = icons.lsp.warn,
      INFO = icons.lsp.info,
      DEBUG = "",
      TRACE = "✎",
    },
  },
}

function M.config()
  nil.builtin.notify = vim.tbl_deep_extend("force", defaults, nil.builtin.notify or {})
end

function M.setup()
  if #vim.api.nvim_list_uis() == 0 then
    return
  end
  local opts = nil.builtin.notify and nil.builtin.notify.opts or defaults
  local notify = require "notify"
  notify.setup(opts)
  vim.notify = notify
  Log:configure_notifications(notify)
end

return M
