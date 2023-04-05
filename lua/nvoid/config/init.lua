local utils = require "nil.utils"
local Log = require "nil.core.log"

local M = {}
local user_config_dir = get_config_dir()
local user_config_file = utils.join_paths(user_config_dir, "config.lua")

---Get the full path to the user configuration file
---@return string
function M:get_user_config_path()
  return user_config_file
end

--- Initialize nil default configuration and variables
function M:init()
  nil = vim.deepcopy(require "nil.config.defaults")

  require("nil.core.keymappings").load_defaults()

  local builtins = require "nil.core.builtins"
  builtins.config { user_config_file = user_config_file }

  local settings = require "nil.config.settings"
  settings.load_defaults()

  local autocmds = require "nil.core.autocmds"
  autocmds.load_defaults()

  local nil_lsp_config = require "nil.lsp.config"
  nil.lsp = vim.deepcopy(nil_lsp_config)
end

--- Override the configuration with a user provided one
-- @param config_path The path to the configuration overrides
function M:load(config_path)
  local autocmds = require "nil.core.autocmds"
  config_path = config_path or self:get_user_config_path()
  local ok, err = pcall(dofile, config_path)
  if not ok then
    if utils.is_file(user_config_file) then
      Log:warn("Invalid configuration: " .. err)
    else
      vim.notify_once(string.format("Unable to find configuration file [%s]", config_path), vim.log.levels.WARN)
    end
  end

  autocmds.define_autocmds(nil.autocommands)

  vim.g.mapleader = (nil.leader == "space" and " ") or nil.leader

  require("nil.core.keymappings").load(nil.keys)
end

--- Override the configuration with a user provided one
-- @param config_path The path to the configuration overrides
function M:reload()
  vim.schedule(function()
    require_clean("nil.utils.hooks").run_pre_reload()

    M:load()

    require("nil.core.autocmds").configure_format_on_save()

    local plugins = require "nil.plugins"
    local plugin_loader = require "nil.plugin-loader"

    plugin_loader.reload { plugins, nil.plugins }
    require_clean("nil.utils.hooks").run_post_reload()
  end)
end

return M
