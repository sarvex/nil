-- statusline
if nil.statusline.enabled then
  vim.opt.statusline = nil.statusline.config
end

-- Term
vim.schedule_wrap(require("nil.builtin.terminal").init())

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
local terminal_options = nil.terminal

map(
  "n",
  "<A-t>",
  "<cmd>lua require('nil.builtin.terminal').new_or_toggle('horizontal', "
    .. tostring(terminal_options.window.split_height)
    .. ")<cr>",
  opts
)

map(
  "t",
  "<A-t>",
  "<cmd>lua require('nil.builtin.terminal').new_or_toggle('horizontal', "
    .. tostring(terminal_options.window.split_height)
    .. ")<cr>",
  opts
)
require("nil.builtin.winbar")
