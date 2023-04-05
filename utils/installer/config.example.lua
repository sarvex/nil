-- Ui
nil.colorscheme = "onedarker"
-- nil.statusline. ...

-- Log
nil.log.level = "warn"
-- nil.log. ...

-- Keys
nil.leader = "space"
nil.keys.normal_mode["<C-s>"] = ":w<cr>"
-- nil.builtin.which_key.mappings["h"] = { "<cmd>nohlsearch<CR>", " No Highlight" }
-- nil.builtin.which_key.mappings["z"] = {
--   name = " Zen",
--   z = { "<cmd>ZenMode<cr>", "ZenMode" },
--   t = { "<cmd>Twilight<cr>", "Twilight" },
-- }

-- Lsp
nil.lsp.diagnostics.virtual_text = true
nil.lsp.format_on_save = false
nil.lsp.document_highlight = true
-- nil.lsp. ...

-- Plugins
nil.builtin.notify.active = true
nil.builtin.nvimtree.setup.view.side = "left"
nil.builtin.treesitter.ensure_installed = {
  "bash",
  "c",
  "javascript",
  "json",
  "lua",
  "python",
  "typescript",
  "tsx",
  "css",
  "rust",
  "java",
  "yaml",
}

nil.builtin.treesitter.ignore_install = { "haskell" }
nil.builtin.treesitter.highlight.enabled = true
-- Add Plugins
-- nil.plugins = {}
