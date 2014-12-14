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

function M.table_compare(base1, base2, eq_override)
  local type1, type2 = type(base1), type(base2)
  local t1, t2

  -- ensure at least one argument is a table
  if type1 ~= "table" and type2 ~= "table" then
    error(string.format("Expected at least one table, got %s and %s", type1, type2))
  end

  if type1 ~= type2 then return false end

  -- apply `eq_override` if one is supplied
  if eq_override then
    if type(eq_override) ~= "function" then 
      error(string.format("Expected function for eq_override, got %s", type(eq_override)))
    end
    local mt = {__eq = eq_override}
    t1 = setmetatable(base1, mt)
    t2 = setmetatable(base2, mt)
    return t1 == t2
  end

  -- check if either object has __eq defined and if so let that handle
  -- the equality check
  t1 = base1
  while t1 do
    if t1.__eq then return base1 == base2 end
    t1 = getmetatable(t1)
  end
  t2 = base2
  while t2 do
    if t2.__eq then return base2 == base1 end
    t2 = getmetatable(t2)
  end
     
  t1, t2 = base1, base2
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

  t1 = base1

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
