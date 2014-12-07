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
  if #self._calls < 1 then
    error("Expected to be called, but wasn't")
  end
end

M.Mock = Mock
return M
