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

M.Mock = Mock
return M
