local M = {}

function M.format_argument_list(...)
  local args = {n = select("#", ...), ...}
  local output = ""
  for i = 1, args.n, 1 do
    v = args[i]
    local del = i ~= args.n and ", " or ""
    if type(v) == "string" then
      output = output .. string.format("'%s'%s", v, del)
    elseif v == nil then
      output = output .. string.format("nil%s", del)
    else
      output = output .. string.format("%s%s", v, del)
    end
  end
  return output
end

return M
