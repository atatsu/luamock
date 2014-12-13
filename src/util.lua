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

function M.table_compare(t1, t2)
  local base_t1, base_t2 = t1, t2
  if type(t1) ~= type(t2) then return false end

  while t1 do
    for k, v in pairs(t1) do
      local skip_meta
      if type(k) == "string" then
        local found = k:find("^__.*$")
        if found then skip_meta = true end
      end

      if not skip_meta then
        if t2[k] == nil then 
          return false
        elseif type(v) == "table" and type(t2[k]) == "table" then
          if not M.table_compare(v, t2[k]) then return false end
        else 
          if t2[k] ~= v then 
            return false 
          end 
        end
      end
    end
    
    t1 = getmetatable(t1)
  end

  t1 = base_t1

  while t2 do
    for k, v in pairs(t2) do
      local skip_meta = false
      if type(k) == "string" then
        local found = k:find("^__.*$")
        if found then skip_meta = true end
      end
      if not skip_meta and t1[k] == nil then return false end
    end

    t2 = getmetatable(t2)
  end

  return true
end

return M
