local core_plugins = {
  -- Plenary
  { "nvim-lua/plenary.nvim" },

  -- Packer
  { "wbthomason/packer.nvim" },

  {
    "SmiteshP/nvim-navic",
    requires = "neovim/nvim-lspconfig",
  },

  -- Term
  {
    "numToStr/FTerm.nvim",
    module = "FTerm",
    config = function()
      require("nil.plugins.config.fterm")
    end,
  },

  -- Icons
  {
    "kyazdani42/nvim-web-devicons",
    module = "nvim-web-devicons",
    config = function()
      require("nil.plugins.config.devions")
    end,
  },

  -- Indent Blankline
  {
    "lukas-reineke/indent-blankline.nvim",
    opt = true,
    after = "nvim-treesitter",
    config = function()
      require("nil.plugins.config.indent")
    end,
  },

  -- Colorizer
  {
    "norcalli/nvim-colorizer.lua",
    setup = function()
      require("nil.core.lazy_load").on_file_open("nvim-colorizer.lua")
    end,
    opt = true,
    config = function()
      require("nil.plugins.config.colorizer")
    end,
  },

  -- Tree Sitter
  {
    "nvim-treesitter/nvim-treesitter",
    module = "nvim-treesitter",
    setup = function()
      require("nil.core.lazy_load").on_file_open("nvim-treesitter")
    end,
    cmd = require("nil.core.lazy_load").treesitter_cmds,
    run = ":TSUpdate",
    config = function()
      require("nil.plugins.config.treesitter").setup()
    end,
  },

  -- Gitsigns
  {
    "lewis6991/gitsigns.nvim",
    disable = not nil.builtin.gitsigns.active,
    config = function()
      require("nil.plugins.config.gitsigns").setup()
    end,
    setup = function()
      require("nil.core.lazy_load").gitsigns()
    end,
  },

  -- Lsp, cmp and luadev
  {
    "williamboman/mason.nvim",
    config = function()
      require("nil.plugins.config.mason").setup()
    end,
  },
  { "williamboman/mason-lspconfig.nvim" },
  { "neovim/nvim-lspconfig" },
  { "jose-elias-alvarez/null-ls.nvim" },
  { "rafamadriz/friendly-snippets", module = { "cmp", "cmp_nvim_lsp" }, event = "InsertEnter" },
  {
    "folke/neodev.nvim",
    module = "neodev",
  },
  {
    "hrsh7th/nvim-cmp",
    after = "friendly-snippets",
    config = function()
      require("nil.plugins.config.cmp").setup()
    end,
  },

  {
    "L3MON4D3/LuaSnip",
    wants = "friendly-snippets",
    after = "nvim-cmp",
    cpnfig = function()
      require("nil.plugins.config.luasnip")
    end,
  },

  -- CMP Extensions
  { "saadparwaiz1/cmp_luasnip", after = "LuaSnip" },
  { "hrsh7th/cmp-nvim-lua", after = "cmp_luasnip" },
  { "hrsh7th/cmp-nvim-lsp", after = "cmp-nvim-lua" },
  { "hrsh7th/cmp-buffer", after = "cmp-nvim-lsp" },
  { "hrsh7th/cmp-path", after = "cmp-buffer" },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    after = "nvim-cmp",
    config = function()
      require("nil.plugins.config.autopairs").setup()
    end,
    disable = not nil.builtin.autopairs.active,
  },

  -- Alpha
  {
    "goolord/alpha-nvim",
    config = function()
      require("nil.plugins.config.alpha")
    end,
  },

  -- Comments
  {
    "numToStr/Comment.nvim",
    config = function()
      require("nil.plugins.config.comment")
    end,
  },

  -- NvimTree
  {
    "kyazdani42/nvim-tree.lua",
    disable = not nil.builtin.nvimtree.active,
    ft = "alpha",
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    tag = "nightly",
    config = function()
      require("nil.plugins.config.nvimtree").setup()
    end,
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    config = function()
      require("nil.plugins.config.telescope").setup()
    end,
    disable = not nil.builtin.telescope.active,
  },

  -- Whichkey
  {
    "folke/which-key.nvim",
    module = "which-key",
    keys = "<leader>",
    config = function()
      require("nil.plugins.config.which-key").setup()
    end,
  },

  -- Notify
  {
    "rcarriga/nvim-notify",
    config = function()
      require("nil.plugins.config.notify").setup()
    end,
    requires = { "nvim-telescope/telescope.nvim" },
    disable = not nil.builtin.notify.active or not nil.builtin.telescope.active,
  },

}

return core_plugins
