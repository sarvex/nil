local a = require "plenary.async_lib.tests"
local uv = vim.loop
local home_dir = uv.os_homedir()

a.describe("initial start", function()
  local nil_config_path = get_config_dir()
  local nil_runtime_path = get_runtime_dir()
  local nil_cache_path = get_cache_dir()

  a.it("should be able to detect test environment", function()
    assert.truthy(os.getenv "_TEST_ENV")
    assert.falsy(package.loaded["nil.impatient"])
  end)

  a.it("should be able to use nil cache directory using vim.fn", function()
    assert.equal(nil_cache_path, vim.fn.stdpath "cache")
  end)

  a.it("should be to retrieve default neovim directories", function()
    local xdg_config = os.getenv "XDG_CONFIG_HOME" or join_paths(home_dir, ".config")
    assert.equal(join_paths(xdg_config, "nvim"), vim.call("stdpath", "config"))
  end)

  a.it("should be able to read nil directories", function()
    local rtp_list = vim.opt.rtp:get()
    assert.truthy(vim.tbl_contains(rtp_list, nil_runtime_path .. "/nil"))
    assert.truthy(vim.tbl_contains(rtp_list, nil_config_path))
  end)

  a.it("should be able to run treesitter without errors", function()
    assert.truthy(vim.treesitter.highlighter.active)
  end)

  a.it("should be able to pass basic checkhealth without errors", function()
    vim.cmd "set cmdheight&"
    vim.cmd "checkhealth nvim"
    local errmsg = vim.fn.eval "v:errmsg"
    local exception = vim.fn.eval "v:exception"
    assert.equal("", errmsg) -- v:errmsg was not updated.
    assert.equal("", exception)
  end)
end)
