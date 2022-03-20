local env = require("tangerine.utils.env")
local fennel = {}
local function format_path(path, ext, macro_path_3f)
  _G.assert((nil ~= macro_path_3f), "Missing argument macro-path? on fnl/tangerine/fennel.fnl:14")
  _G.assert((nil ~= ext), "Missing argument ext on fnl/tangerine/fennel.fnl:14")
  _G.assert((nil ~= path), "Missing argument path on fnl/tangerine/fennel.fnl:14")
  local function _1_()
    if macro_path_3f then
      return (";" .. path .. "?/init-macros.fnl")
    else
      return ""
    end
  end
  return (path .. "?." .. ext .. ";" .. path .. "?/init." .. ext .. _1_())
end
local function get_rtp(ext, macro_path_3f)
  _G.assert((nil ~= macro_path_3f), "Missing argument macro-path? on fnl/tangerine/fennel.fnl:19")
  _G.assert((nil ~= ext), "Missing argument ext on fnl/tangerine/fennel.fnl:19")
  local out = {format_path(env.get("source"), ext, macro_path_3f)}
  do
    local rtp = (vim.o.runtimepath .. ",")
    for entry in rtp:gmatch("(.-),") do
      local path = (entry .. "/fnl/")
      if (1 == vim.fn.isdirectory(path)) then
        table.insert(out, format_path(path, ext, macro_path_3f))
      else
      end
    end
  end
  return table.concat(out, ";")
end
fennel.load = function(_3fversion)
  local version = (_3fversion or env.get("compiler", "version"))
  local fennel0 = require(("tangerine.fennel." .. version))
  do end (fennel0)["path"] = get_rtp("fnl", false)
  do end (fennel0)["macro-path"] = get_rtp("fnl", true)
  return fennel0
end
local orig = {path = package.path}
fennel["patch-path"] = function()
  local targetdirs = get_rtp("lua", false)
  local sourcedirs = format_path(env.get("target"), "lua", false)
  do end (package)["path"] = (orig.path .. ";" .. targetdirs .. ";" .. sourcedirs)
  return true
end
return fennel
