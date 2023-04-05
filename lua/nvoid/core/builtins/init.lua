local M = {}

local builtins = {
  "nil.plugins.config.cmp",
  "nil.plugins.config.which-key",
  "nil.plugins.config.gitsigns",
  "nil.plugins.config.telescope",
  "nil.plugins.config.treesitter",
  "nil.plugins.config.nvimtree",
  "nil.plugins.config.autopairs",
  "nil.plugins.config.notify",
  "nil.plugins.config.mason",
}

function M.config(config)
  for _, builtin_path in ipairs(builtins) do
    local builtin = require(builtin_path)
    builtin.config(config)
  end
end

return M
