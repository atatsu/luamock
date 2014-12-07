local M = {}

M._COPYRIGHT = "Copyright (c) 2014 Nathan Lundquist"
M._DESCRIPTION = ""
M._VERSION = "0.1.0"

local Mock = {}
--Mock.__index = Mock

setmetatable(Mock, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

local mock_mt = {
  __call = function(self, ...)
    local args = {...}
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

  local expected_args = {...}
  local actual_args = self._calls[1]
  local equal = true
  for i, v in ipairs(expected_args) do
    if actual_args[i] ~= v then
      equal = false
      break
    end
  end

  if equal == true then
    return
  end

  local err = "Expected call: mock("
  for i, v in ipairs(expected_args) do
    local del = i ~= #expected_args and ", " or ""
    if type(v) == "string" then
      err = err .. string.format("'%s'%s", v, del)
    else
      err = err .. string.format("%s%s", v, del)
    end
  end
  err = err .. ")\nActual call: mock("
  for i, v in ipairs(actual_args) do
    local del = i ~= #expected_args and ", " or ""
    if type(v) == "string" then
      err = err .. string.format("'%s'%s", v, del)
    else
      err = err .. string.format("%s%s", v, del)
    end
  end
  err = err .. ")"
  error(err)
end

M.Mock = Mock
return M
