describe("luamock", function()

  local luamock

  setup(function()
    luamock = require("src/luamock")
  end)

  teardown(function()
    luamock = nil
    package.loaded["luamock"] = nil
  end)

  describe("generic Mock", function()

    local mock

    before_each(function()
      mock = luamock.Mock()
      --print(mock)
    end)

    after_each(function()
      mock = nil
    end)

    it("should be callable", function()
      mock()
    end)

    it("should record that it was called", function()
      mock()
      assert.has_no.errors(function() mock:assert_called() end)
    end)

    it("should error if it wasn't called", function()
      assert.has.errors(
        function() mock:assert_called() end, 
        "Expected to be called, but wasn't"
      )
    end)

    it("should record the exact number of times it was called", function()
      mock()
      mock()
      assert.has_no.errors(function() mock:assert_called(2) end)
    end)

    it("should error if called wrong number of times", function()
      mock()
      mock()
      --success, err = pcall(function() mock:assert_called(3) end)
      assert.has.errors(
        function() mock:assert_called(3) end,
        "Expected to be called 3 times, but called 2 times"
      )
    end)

    pending("should record the arguments it was called with", function()
      mock(1, "foo")
    end)

    pending("should allow any call to be made on it", function()
      mock.random_method()
      mock:random_method_again()
    end)
  end)
end)
