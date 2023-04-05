local base_dir = vim.env.LUNARVIM_BASE_DIR
    or (function()
      local init_path = debug.getinfo(1, "S").source
      return init_path:sub(2):match("(.*[/\\])"):sub(1, -2)
    end)()

if not vim.tbl_contains(vim.opt.rtp:get(), base_dir) then
  vim.opt.rtp:append(base_dir)
end

require("nil.bootstrap"):init(base_dir)


require("nil.config"):load()

local plugins = require "nil.plugins"
require("nil.plugin-loader").load { plugins, nil.plugins }

local Log = require "nil.core.log"
Log:debug "Starting LunarVim"

local commands = require "nil.core.commands"
commands.load(commands.defaults)

require("nil.lsp").setup()

-- Terminals, Statusline
require("nil.builtin")
