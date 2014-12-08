local util = require("util")

local Mock = {}

setmetatable(Mock, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

local mock_mt = {
  __call = function(self, ...)
    local args = {n = select("#", ...), ...}
    self._calls[#self._calls + 1] = args
  end,
  __index = Mock,
}

function Mock.new()
  local self = setmetatable({
    _calls = {},
  }, mock_mt)
  return self
end

function Mock:assert_called(n_times)
  if n_times == nil then
    if #self._calls < 1 then
      error("Expected to be called, but wasn't")
    end
    return
  end

  if n_times ~= #self._calls then
    local err = string.format(
      "Expected to be called %s times, but called %s times", 
      n_times, 
      #self._calls
    )
    error(err)
  end
end

function Mock:assert_called_once_with(...)
  if #self._calls < 1 then
    error("Expected to be called once. Called 0 times.")
  elseif #self._calls > 1 then
    error("Expected to be called once. Called " .. #self._calls .. " times.")
  end

  local err_msg = "Expected call: mock(%s)\nActual call: mock(%s)"

  local expected_args = {n = select("#", ...), ...}
  local actual_args = self._calls[1]

  if expected_args.n ~= actual_args.n then
    error(string.format(
      err_msg, 
      util.format_argument_list(unpack(expected_args)), 
      util.format_argument_list(unpack(actual_args))
    ))
  end

  for i = 1, expected_args.n, 1 do
    if expected_args[i] ~= actual_args[i] then
      error(string.format(
        err_msg,
        util.format_argument_list(unpack(expected_args)),
        util.format_argument_list(unpack(actual_args))
      ))
    end
  end
end

function Mock:assert_any_call(...)
end

return Mock
