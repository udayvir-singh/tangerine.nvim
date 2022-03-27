local env = require("tangerine.utils.env")
local win = require("tangerine.utils.window")
local dp = {}
local function primitive_3f(val)
  _G.assert((nil ~= val), "Missing argument val on fnl/tangerine/output/display.fnl:14")
  return (("string" == type(val)) or ("number" == type(val)))
end
local function escape_quotes(str)
  _G.assert((nil ~= str), "Missing argument str on fnl/tangerine/output/display.fnl:18")
  local qt = "\""
  local esc = "\\\""
  return (qt .. str:gsub(qt, esc) .. qt)
end
local function parse_list(str)
  _G.assert((nil ~= str), "Missing argument str on fnl/tangerine/output/display.fnl:23")
  local inline = "%{( [^{]-%g )%}"
  local multi = "%{( [^{]%C- {.+%g )%}"
  if str:find(inline) then
    return parse_list(str:gsub(inline, "[%1]"))
  elseif str:find(multi) then
    return parse_list(str:gsub(multi, "[%1]"))
  elseif "else" then
    return str
  else
    return nil
  end
end
local function serialize_tbl(tbl)
  _G.assert((nil ~= tbl), "Missing argument tbl on fnl/tangerine/output/display.fnl:35")
  return string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(vim.inspect(tbl), "= -'([^']-)'", escape_quotes), ",", ""), "= ", ""), "(\n -)[^<[%w]([%w_-])", "%1 :%2"), "(\n -)%[\"(.-)\"%]", "%1:%2"), "(\n -)%[(.-)%]", "%1%2"), "<(.-)>", "(%1)"), "%b{}", parse_list)
end
dp.serialize = function(xs, return_3f)
  local out = ""
  if primitive_3f(xs) then
    out = vim.inspect(xs)
  else
    out = serialize_tbl(xs)
  end
  local function _3_()
    if return_3f then
      return ":return "
    else
      return ""
    end
  end
  return (_3_() .. out)
end
dp.format = function(code)
  _G.assert((nil ~= code), "Missing argument code on fnl/tangerine/output/display.fnl:65")
  local luafmt = env.get("eval", "luafmt")()
  if ((0 == #luafmt) or (0 == vim.fn.executable(luafmt[1]))) then
    return code
  else
    return vim.fn.system(luafmt, code)
  end
end
local function print(str)
  _G.assert((nil ~= str), "Missing argument str on fnl/tangerine/output/display.fnl:77")
  if (_G.has_ui or (0 < #vim.api.nvim_list_uis())) then
    return _G.print(str)
  else
    return nil
  end
end
dp.show = function(_3fval, opts)
  _G.assert((nil ~= opts), "Missing argument opts on fnl/tangerine/output/display.fnl:82")
  if (_3fval == nil) then
    return
  else
  end
  local out = dp.serialize(_3fval, true)
  if env.conf(opts, {"eval", "float"}) then
    win["set-float"](out, "fennel", env.get("highlight", "float"))
  elseif "else" then
    print(out)
  else
  end
  return true
end
dp["show-lua"] = function(code, opts)
  _G.assert((nil ~= opts), "Missing argument opts on fnl/tangerine/output/display.fnl:93")
  _G.assert((nil ~= code), "Missing argument code on fnl/tangerine/output/display.fnl:93")
  local out = string.gsub(dp.format(code), "\n$", "")
  if env.conf(opts, {"eval", "float"}) then
    win["set-float"](out, "lua", env.get("highlight", "float"))
  elseif "else" then
    print(out)
  else
  end
  return true
end
return dp
