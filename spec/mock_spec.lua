describe("luamock", function()

  local luamock

  setup(function()
    luamock = require("src/init")
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
      assert.has_no.errors(mock)
    end)

    describe("assert_called", function()
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
        --_, err = pcall(function() mock:assert_called(3) end)
        assert.has.errors(
          function() mock:assert_called(3) end,
          "Expected to be called 3 times, but called 2 times"
        )
      end)
    end)

    describe("assert_called_once_with", function()

      it("should record the args it was called with", function()
        mock(1, "foo")
        assert.has_no.errors(function() mock:assert_called_once_with(1, "foo") end)
      end)

      it("should error if called with unexpected args", function()
        mock(2, "bar")
        --_, err = pcall(function() mock:assert_called_once_with(1, "foo") end)
        assert.has.errors(
          function() mock:assert_called_once_with(1, "foo") end, 
          "Expected call: mock(1, 'foo')\nActual call: mock(2, 'bar')"
        )
      end)

      it("should error if called more than once", function()
        mock()
        mock()
        assert.has.errors(
          function() mock:assert_called_once_with() end,
          "Expected to be called once. Called 2 times."
        )
      end)

      it("should error if called less than once", function()
        assert.has.errors(
          function() mock:assert_called_once_with() end,
          "Expected to be called once. Called 0 times."
        )
      end)

      it("should handle nil", function()
        mock(1, nil, 3)
        assert.has_no.errors(
          function() mock:assert_called_once_with(1, nil, 3) end
        )
      end)

      it("should error if nil expected but not in actual call", function()
        local expected_err = "Expected call: mock('foo', nil, 'bar')\nActual call: mock('foo', 'bar')"
        mock("foo", "bar")
        local check = function() mock:assert_called_once_with("foo", nil, "bar") end
        --_, err = pcall(check)
        assert.has.errors(
          check,
          expected_err
        )
      end)

      it("should error if nil expected but not in actual call (equal arg numbers)", function()
        local expected_err = "Expected call: mock('foo', nil, 'bar')\nActual call: mock('foo', 4, 'bar')"
        mock("foo", 4, "bar")
        local check = function() mock:assert_called_once_with("foo", nil, "bar") end
        --_, err = pcall(check)
        assert.has.errors(
          check,
          expected_err
        )
      end)

      pending("should handle tables", function()

      end)

      pending("should throw an error if tables are not the same", function()
      end)

    end)

    describe("assert_any_call", function()

      pending("should not care about call order", function()
        mock(1, 2, 3)
        mock("foo", "bar")
        mock(true, false)
        assert.has_no.errors(function() mock:assert_any_call("foo", "bar") end)
      end)

      pending("should error if supplied call never happened", function()
        mock("a", 1)
        mock("b", 2)
        assert.has.errors(
          function() mock:assert_any_call("c", 3) end,
          "mock('c', 3) call not found"
        )
      end)

    end)
  end)
end)
