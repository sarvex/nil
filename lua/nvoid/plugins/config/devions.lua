local present, devicons = pcall(require, "nvim-web-devicons")

if present then
  local options = { override = require("nil.interface.icons").devicons }
  devicons.setup(options)
end
