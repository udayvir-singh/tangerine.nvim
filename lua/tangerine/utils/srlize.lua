local function table_3f(x)
  return ("table" == type(x))
end
local function list_3f(x)
  if ("table" ~= type(x)) then
    return false
  else
  end
  local prev = 0
  for key in pairs(x) do
    if (key ~= (prev + 1)) then
      return false
    else
    end
    prev = key
  end
  return true
end
local function tab(n)
  _G.assert((nil ~= n), "Missing argument n on fnl/tangerine/utils/srlize.fnl:22")
  return ("\n" .. string.rep("\9", n))
end
local function time_2a(name, runs, handler)
  _G.assert((nil ~= handler), "Missing argument handler on fnl/tangerine/utils/srlize.fnl:42")
  _G.assert((nil ~= runs), "Missing argument runs on fnl/tangerine/utils/srlize.fnl:42")
  _G.assert((nil ~= name), "Missing argument name on fnl/tangerine/utils/srlize.fnl:42")
  local start = os.clock()
  for i = 1, runs do
    handler()
  end
  local _end = os.clock()
  return print(string.format("%-8s: %s", name, ((_end - start) / runs)))
end
local priority = {number = 1, boolean = 2, string = 3, ["function"] = 4, table = 5, thread = 6, userdata = 7}
local function compare(x, y)
  _G.assert((nil ~= y), "Missing argument y on fnl/tangerine/utils/srlize.fnl:67")
  _G.assert((nil ~= x), "Missing argument x on fnl/tangerine/utils/srlize.fnl:67")
  local tx = type(x)
  local ty = type(y)
  if (tx ~= ty) then
    return (priority[tx] < priority[ty])
  elseif (tx == "number") then
    return (x < y)
  elseif (tx == "string") then
    local lhs = string.lower(x:gsub("[_-]", ""))
    local rhs = string.lower(y:gsub("[_-]", ""))
    if (lhs == rhs) then
      return (x < y)
    else
      return (lhs < rhs)
    end
  else
    return (tostring(x) < tostring(y))
  end
end
local function order_keys(tbl)
  _G.assert((nil ~= tbl), "Missing argument tbl on fnl/tangerine/utils/srlize.fnl:87")
  local keys = vim.tbl_keys(tbl)
  table.sort(keys, compare)
  return keys
end
local function onext(tbl, _3fstate)
  _G.assert((nil ~= tbl), "Missing argument tbl on fnl/tangerine/utils/srlize.fnl:93")
  local key = nil
  local mtbl = (getmetatable(tbl) or {})
  if (_3fstate == nil) then
    mtbl.__okeys = order_keys(tbl)
    key = mtbl.__okeys[1]
  elseif "else" then
    for i = 1, #(mtbl.__okeys or {}) do
      if (_3fstate == mtbl.__okeys[i]) then
        key = mtbl.__okeys[(1 + i)]
      else
      end
    end
  else
  end
  if (nil == key) then
    mtbl.__okeys = nil
    do local _ = ((0 == #vim.tbl_keys(mtbl)) and setmetatable(tbl, nil)) end
    return
  else
  end
  setmetatable(tbl, mtbl)
  return key, tbl[key]
end
local function opairs(tbl)
  _G.assert((nil ~= tbl), "Missing argument tbl on fnl/tangerine/utils/srlize.fnl:115")
  return onext, tbl, nil
end
local default_store
local function _8_()
  return {refs = {["function"] = {n = 0}, table = {n = 0}, thread = {n = 0}, userdata = {n = 0}}, cycles = {}}
end
default_store = _8_
local store = default_store()
local function add_cycle(x)
  do
    local out = not table_3f(x)
    if not table_3f(x) then
      return out
    else
    end
  end
  local count = store.cycles[x]
  store.cycles[x] = (1 + (count or 0))
  if not count then
    add_cycle(getmetatable(x))
    for k, v in pairs(x) do
      add_cycle(k)
      add_cycle(v)
    end
    return nil
  else
    return nil
  end
end
local function recursive_3f(tbl)
  _G.assert((nil ~= tbl), "Missing argument tbl on fnl/tangerine/utils/srlize.fnl:148")
  return (1 ~= (store.cycles[tbl] or 1))
end
local function add_ref(val)
  _G.assert((nil ~= val), "Missing argument val on fnl/tangerine/utils/srlize.fnl:152")
  local tv = type(val)
  local ref = (1 + store.refs[tv].n)
  do end (store.refs)[tv][val] = ref
  store.refs[tv]["n"] = ref
  return ref
end
local function get_ref(val)
  _G.assert((nil ~= val), "Missing argument val on fnl/tangerine/utils/srlize.fnl:160")
  local tv = type(val)
  local ref = store.refs[tv][val]
  return (ref and string.format("(%s %s)", tv, ref))
end
local parse
local function _11_(parse0, val, level)
  _G.assert((nil ~= level), "Missing argument level on fnl/tangerine/utils/srlize.fnl:181")
  _G.assert((nil ~= val), "Missing argument val on fnl/tangerine/utils/srlize.fnl:181")
  _G.assert((nil ~= parse0), "Missing argument parse on fnl/tangerine/utils/srlize.fnl:181")
  if list_3f(val) then
    return parse0.list(val, level)
  elseif table_3f(val) then
    return parse0.table(val, level)
  elseif "else" then
    return parse0.primitive(val)
  else
    return nil
  end
end
local function _13_(parse0, val, level)
  do
    local out = "nil"
    if (nil == val) then
      return out
    else
    end
  end
  add_cycle(val)
  local out = parse0:this(val, level)
  store = default_store()
  return out
end
parse = setmetatable({primitive = nil, list = nil, key = nil, table = nil, metatable = nil, this = _11_}, {__call = _13_})
local escapes = {["\7"] = "\\a", ["\8"] = "\\b", ["\12"] = "\\f", ["\n"] = "\\n", ["\13"] = "\\r", ["\9"] = "\\t", ["\11"] = "\\v"}
local function double_quote(str)
  _G.assert((nil ~= str), "Missing argument str on fnl/tangerine/utils/srlize.fnl:216")
  local function _15_(_241)
    return (escapes[_241] or ("\\" .. string.byte(_241)))
  end
  return ("\"" .. string.gsub(string.gsub(string.gsub(str, "\\", "\\\\"), "\"", "\\\""), "%c", _15_) .. "\"")
end
parse.primitive = function(val, _3fdry)
  _G.assert((nil ~= val), "Missing argument val on fnl/tangerine/utils/srlize.fnl:225")
  local tv = type(val)
  if ("string" == tv) then
    return double_quote(val)
  elseif (("number" == tv) or ("boolean" == tv)) then
    return tostring(val)
  elseif "else" then
    local function _16_()
      if _3fdry then
        return "nil"
      else
        return add_ref(val)
      end
    end
    return string.format("(%s %s)", tv, _16_())
  else
    return nil
  end
end
local function multi_line_3f(list, level, _3fkey)
  _G.assert((nil ~= level), "Missing argument level on fnl/tangerine/utils/srlize.fnl:239")
  _G.assert((nil ~= list), "Missing argument list on fnl/tangerine/utils/srlize.fnl:239")
  do
    local out = recursive_3f(list)
    if recursive_3f(list) then
      return out
    else
    end
  end
  do
    local out = getmetatable(list)
    if getmetatable(list) then
      return out
    else
    end
  end
  local width = (3 + #(_3fkey or "") + (level * vim.o.shiftwidth))
  for _, val in ipairs(list) do
    if table_3f(val) then
      return true
    else
    end
    width = (width + 1 + #parse.primitive(val, true))
  end
  return (width > vim.api.nvim_win_get_width(0))
end
parse.list = function(list, level, _3fkey)
  _G.assert((nil ~= level), "Missing argument level on fnl/tangerine/utils/srlize.fnl:252")
  _G.assert((nil ~= list), "Missing argument list on fnl/tangerine/utils/srlize.fnl:252")
  do
    local out = get_ref(list)
    if get_ref(list) then
      return out
    else
    end
  end
  do
    local out = "{}"
    if (0 == #list) then
      return out
    else
    end
  end
  local ref = ""
  if recursive_3f(list) then
    ref = string.format(" ; (%s)", add_ref(list))
  else
  end
  local ml = multi_line_3f(list, level, _3fkey)
  local out = ""
  for idx, val in ipairs(list) do
    local sep
    if ml then
      sep = tab(level)
    elseif (idx ~= 1) then
      sep = " "
    else
      sep = nil
    end
    out = (out .. (sep or "") .. (parse:this(val, (1 + level)) or ""))
  end
  local mtbl = parse.metatable(list, (level + 1))
  local function _25_()
    if ml then
      return tab((level - 1))
    else
      return ""
    end
  end
  return ("[" .. ref .. out .. mtbl .. _25_() .. "]")
end
local function keyword_3f(x)
  _G.assert((nil ~= x), "Missing argument x on fnl/tangerine/utils/srlize.fnl:276")
  return (("string" == type(x)) and not string.find(x, "[%s%c%(%)%[%]%{%}\"'`,;@~]"))
end
parse.key = function(x, level)
  _G.assert((nil ~= level), "Missing argument level on fnl/tangerine/utils/srlize.fnl:281")
  _G.assert((nil ~= x), "Missing argument x on fnl/tangerine/utils/srlize.fnl:281")
  if keyword_3f(x) then
    return (":" .. x)
  else
    return parse:this(x, (level + 1))
  end
end
local function key_padding(tbl)
  _G.assert((nil ~= tbl), "Missing argument tbl on fnl/tangerine/utils/srlize.fnl:287")
  local out = {}
  local buf = {}
  local len = 1
  local function checkout()
    for _, key in ipairs(buf) do
      out[key] = (len - #key)
    end
    buf = {}
    len = 1
    return nil
  end
  for key, val in opairs(tbl) do
    if (("string" == type(key)) and ("table" ~= type(val))) then
      local klen = (1 + #key)
      table.insert(buf, key)
      if (klen > len) then
        len = klen
      else
      end
    else
      checkout()
      do end (out)[key] = 1
    end
  end
  checkout()
  return out
end
parse.table = function(tbl, level)
  _G.assert((nil ~= level), "Missing argument level on fnl/tangerine/utils/srlize.fnl:312")
  _G.assert((nil ~= tbl), "Missing argument tbl on fnl/tangerine/utils/srlize.fnl:312")
  do
    local out = get_ref(tbl)
    if get_ref(tbl) then
      return out
    else
    end
  end
  local ref = ""
  if recursive_3f(tbl) then
    ref = string.format(" ; (%s)", add_ref(tbl))
  else
  end
  local out = ""
  local pad = key_padding(tbl)
  for k, v in opairs(tbl) do
    out = (out .. (tab(level) or "") .. (parse.key(k, (level + 1)) or "") .. (string.rep(" ", pad[k]) or "") .. (parse:this(v, (level + 1)) or ""))
  end
  local mtbl = parse.metatable(tbl, (level + 1))
  return ("{" .. ref .. out .. mtbl .. tab((level - 1)) .. "}")
end
parse.metatable = function(tbl, level)
  _G.assert((nil ~= level), "Missing argument level on fnl/tangerine/utils/srlize.fnl:333")
  _G.assert((nil ~= tbl), "Missing argument tbl on fnl/tangerine/utils/srlize.fnl:333")
  local mtbl = getmetatable(tbl)
  do
    local out = ""
    if (nil == mtbl) then
      return out
    else
    end
  end
  return (tab((level - 1)) .. "(metatable) " .. parse:this(mtbl, level))
end
local function serialize(...)
  local args = {...}
  do
    local out = (":return " .. parse(args[1], 1))
    if (1 >= #args) then
      return out
    else
    end
  end
  local out = ""
  for _, val in ipairs(args) do
    out = (out .. (tab(1) or "") .. (parse(val, 2) or ""))
  end
  return ("(values" .. out .. "\n)")
end
return serialize
