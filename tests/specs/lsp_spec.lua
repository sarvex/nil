local a = require "plenary.async_lib.tests"
local utils = require "nil.utils"
local helpers = require "tests.nil.helpers"
local spy = require "luassert.spy"

a.describe("lsp workflow", function()
  before_each(function()
    vim.cmd [[
     let v:errmsg = ""
      let v:errors = []
    ]]
  end)

  after_each(function()
    local errmsg = vim.fn.eval "v:errmsg"
    local exception = vim.fn.eval "v:exception"
    local errors = vim.fn.eval "v:errors"
    assert.equal("", errmsg)
    assert.equal("", exception)
    assert.True(vim.tbl_isempty(errors))
  end)

  nil.lsp.templates_dir = join_paths(get_cache_dir(), "artifacts")

  a.it("should be able to delete ftplugin templates", function()
    if utils.is_directory(nil.lsp.templates_dir) then
      assert.equal(vim.fn.delete(nil.lsp.templates_dir, "rf"), 0)
    end
    assert.False(utils.is_directory(nil.lsp.templates_dir))
  end)

  a.it("should be able to generate ftplugin templates", function()
    if utils.is_directory(nil.lsp.templates_dir) then
      assert.equal(vim.fn.delete(nil.lsp.templates_dir, "rf"), 0)
    end

    require("nil.lsp").setup()

    assert.True(utils.is_directory(nil.lsp.templates_dir))
  end)

  a.it("should not include blacklisted servers in the generated templates", function()
    require("nil.lsp").setup()

    for _, file in ipairs(vim.fn.glob(nil.lsp.templates_dir .. "/*.lua", 1, 1)) do
      for _, server_name in ipairs(nil.lsp.override) do
        local setup_cmd = string.format([[require("nil.lsp.manager").setup(%q)]], server_name)
        assert.False(helpers.file_contains(file, setup_cmd))
      end
    end
  end)

  a.it("should only include one server per generated template", function()
    require("nil.lsp").setup()

    local allowed_dupes = { "tailwindcss" }
    for _, file in ipairs(vim.fn.glob(nil.lsp.templates_dir .. "/*.lua", 1, 1)) do
      local content = {}
      for entry in io.lines(file) do
        local server_name = entry:match [[.*setup%("(.*)"%)]]
        if not vim.tbl_contains(allowed_dupes, server_name) then
          table.insert(content, server_name)
        end
      end
      local err_msg = ""
      if #content > 1 then
        err_msg = string.format(
          "found more than one server for [%q]: \n{\n %q \n}",
          file:match "[^/]*.lua$",
          table.concat(content, ", ")
        )
      end
      assert.equal(err_msg, "")
    end
  end)

  a.it("should not attempt to re-generate ftplugin templates", function()
    local s = spy.on(require "nil.lsp.templates", "generate_templates")
    local plugins = require "nil.plugins"
    require("nil.plugin-loader").load { plugins, nil.plugins }

    require("nil.lsp").setup()
    assert.spy(s).was_not_called()
    s:revert()
  end)
end)
