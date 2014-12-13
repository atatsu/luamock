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

    it("should return false when one of the arguments is not a table", function()
      assert.is_false(util.table_compare(5, {}))
    end)

    describe("when used with simple array-like tables", function()

      local simple_array

      before_each(function()
        simple_array = {1, 2, "foo", "bar", 20}
      end)

      after_each(function()
        simple_array = nil
      end)

      it("should return true when equal", function()
        local other = {1, 2, "foo", "bar", 20}
        assert.is_true(util.table_compare(simple_array, other))
        assert.is_true(util.table_compare(other, simple_array))
      end)

      it("should return false when not remotely equal", function()
        local other = {5, "c", 20}
        assert.is_false(util.table_compare(simple_array, other))
        assert.is_false(util.table_compare(other, simple_array))
      end)

      it("should return false when same length but different items", function()
        local other = {"a", 10, 50, "c", "boo"}
        assert.is_false(util.table_compare(simple_array, other))
        assert.is_false(util.table_compare(other, simple_array))
      end)

      it("should return false when all items in first but extras in second", function()
        local other = {1, 2, "foo", "bar", 20, "more stuff", "here"}
        assert.is_false(util.table_compare(simple_array, other))
        assert.is_false(util.table_compare(other, simple_array))
      end)

    end)

    describe("when used with simple dictionary-like tables", function()

      local simple_dict

      before_each(function()
        simple_dict = {foo = "bar", a = 10, some = "value"}
      end)

      after_each(function()
        simple_dict = nil
      end)

      it("should return true when equal", function()
        local other = {foo = "bar", some = "value", a = 10}
        assert.is_true(util.table_compare(simple_dict, other))
        assert.is_true(util.table_compare(other, simple_dict))
      end)

      it("should return false when all items in first but extras in second", function()
        local other = {a = 10, foo = "bar", some = "value", one = "more"}
        assert.is_false(util.table_compare(simple_dict, other))
        assert.is_false(util.table_compare(other, simple_dict))
      end)

      it("should return false when same length but different items", function()
        local other = {a = 1, b = 2, c = 3}
        assert.is_false(util.table_compare(simple_dict, other))
        assert.is_false(util.table_compare(other, simple_dict))
      end)

    end)

    describe("when used with nested tables", function()

      describe("equality checks should be performed on inner tables", function()

        describe("such that with nested array-like tables", function()

          local nested_array

          before_each(function()
            nested_array = {"a", "b", {"f", "g"}}
          end)

          after_each(function()
            nested_array = nil
          end)

          it("should return true when equal", function()
            local other = {"a", "b", {"f", "g"}}
            assert.is_true(util.table_compare(nested_array, other))
            assert.is_true(util.table_compare(other, nested_array))
          end)

          it("should return false when a nested array is not equal", function()
            local other = {"a", "b", {"not", "equal"}}
            assert.is_false(util.table_compare(nested_array, other))
            assert.is_false(util.table_compare(other, nested_array))
          end)

          it("should compare all elements past the nested array", function()
            local other = {"a", "b", {"f", "g"}, "c"}
            assert.is_false(util.table_compare(nested_array, other))
            assert.is_false(util.table_compare(other, nested_array))
          end)

        end)

        describe("such that with nested dictionary-like tables", function()

          local nested_dict

          before_each(function()
            nested_dict = {flag = false, options = {do_stuff = true, opt2 = "stuff"}}
          end)

          after_each(function()
            nested_dict = nil
          end)

          it("should return true when equal", function()
            local other = {flag = false, options = {do_stuff = true, opt2 = "stuff"}}
            assert.is_true(util.table_compare(nested_dict, other))
            assert.is_true(util.table_compare(other, nested_dict))
          end)

          it("should return false when not equal", function()
            local other = {flag = false, options = {do_stuff = false, opt2 = "no"}}
            assert.is_false(util.table_compare(nested_dict, other))
            assert.is_false(util.table_compare(other, nested_dict))
          end)

        end)

        describe("such that with nested hybrid tables", function()

          local nested_hybrid

          before_each(function()
            nested_hybrid = {"a", "b", {5, 6, {mycat = "isfluffy", but = "stinks"}}, "c"}
          end)

          after_each(function()
            nested_hybrid = nil
          end)

          it("should return true when equal", function()
            local other = {"a", "b", {5, 6, {mycat = "isfluffy", but = "stinks"}}, "c"}
            assert.is_true(util.table_compare(nested_hybrid, other))
            assert.is_true(util.table_compare(other, nested_hybrid))
          end)

          it("should return false when not equal", function()
            local other = {"a", "b", {5, 6, {mycat = "is fat", but = "stink"}}, "c"}
            assert.is_false(util.table_compare(nested_hybrid, other))
            assert.is_false(util.table_compare(other, nested_hybrid))
          end)

        end)

      end)

    end)

    describe("when used with tables having metatables", function()

      local mt
      local control

      before_each(function()
        mt = {foo = "bar", bar = "baz"}
        mt.__index = mt
        control = setmetatable({a = 5, c = 7, {7, 20, "d"}}, mt)
      end)

      after_each(function()
        mt = nil
        control = nil
      end)

      it("the metatable values should be used in the comparison", function()
        local other = {a = 5, c = 7, {7, 20, "d"}}
        other.__index = other
        assert.is_false(util.table_compare(control, other))
        assert.is_false(util.table_compare(other, control))
      end)

      it("metamethods should be ignored", function()
        --local other = {a = 5, c = 7, {7, 20, "d"}, foo = "bar", bar = "baz"}
        local other_mt = {__index = {foo = "bar", bar = "baz"}}
        local other = setmetatable({a = 5, c = 7, {7, 20, "d"}}, other_mt)
        assert.is_true(util.table_compare(control, other))
        assert.is_true(util.table_compare(other, control))
      end)

    end)

  end)

end)
