describe("luamock.util", function()

  local util

  setup(function()
    util = require("src/util")
  end)

  teardown(function()
    util = nil
    package.loaded["util"] = nil
  end)

  describe("format_argument_list", function()

    it("should quote strings", function()
      local expected = "1, 2, 'foo', 'bar'"
      local actual = util.format_argument_list(1, 2, "foo", "bar")
      assert.are.equal(expected, actual)
    end)

    it("should show nils", function()
      local expected = "1, 'a', nil, nil, 3, nil"
      local actual = util.format_argument_list(1, "a", nil, nil, 3, nil)
      assert.are.equal(expected, actual)
    end)
  end)

  describe("table_compare", function()
  end)

end)
