local _local_1_ = require("tangerine.utils")
local env = _local_1_["env"]
local win = _local_1_["win"]
local srl = _local_1_["srl"]
local dp = {}
local function print(str)
  _G.assert((nil ~= str), "Missing argument str on fnl/tangerine/output/display.fnl:14")
  if (_G.has_ui or (0 < #vim.api.nvim_list_uis())) then
    return vim.api.nvim_echo({{str}}, false, {})
  else
    return nil
  end
end
local function format(code)
  _G.assert((nil ~= code), "Missing argument code on fnl/tangerine/output/display.fnl:19")
  local luafmt = env.get("eval", "luafmt")()
  if (0 == vim.fn.executable((luafmt[1] or ""))) then
    return code
  else
    return string.gsub(vim.fn.system(luafmt, code), "\n$", "")
  end
end
dp.show = function(res, opts)
  _G.assert((nil ~= opts), "Missing argument opts on fnl/tangerine/output/display.fnl:30")
  _G.assert((nil ~= res), "Missing argument res on fnl/tangerine/output/display.fnl:30")
  if (0 == #res) then
    return
  else
  end
  local out = srl(unpack(res))
  if env.conf(opts, {"eval", "float"}) then
    win["set-float"](out, "fennel", env.get("highlight", "float"))
  else
    print(out)
  end
  return true
end
dp["show-lua"] = function(code, opts)
  _G.assert((nil ~= opts), "Missing argument opts on fnl/tangerine/output/display.fnl:41")
  _G.assert((nil ~= code), "Missing argument code on fnl/tangerine/output/display.fnl:41")
  local out = format(code)
  if env.conf(opts, {"eval", "float"}) then
    win["set-float"](out, "lua", env.get("highlight", "float"))
  else
    print(out)
  end
  return true
end
return dp
