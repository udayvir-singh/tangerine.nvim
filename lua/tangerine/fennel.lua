local env = require("tangerine.utils.env")
local fennel = {}
local function format_path(path, ext, macro_3f)
  _G.assert((nil ~= macro_3f), "Missing argument macro? on fnl/tangerine/fennel.fnl:14")
  _G.assert((nil ~= ext), "Missing argument ext on fnl/tangerine/fennel.fnl:14")
  _G.assert((nil ~= path), "Missing argument path on fnl/tangerine/fennel.fnl:14")
  local function _1_()
    if macro_3f then
      return "init-macros."
    else
      return "init."
    end
  end
  return (path .. "?." .. ext .. ";" .. path .. "?/" .. _1_() .. ext)
end
local function get_path(ext, macro_path_3f)
  _G.assert((nil ~= macro_path_3f), "Missing argument macro-path? on fnl/tangerine/fennel.fnl:19")
  _G.assert((nil ~= ext), "Missing argument ext on fnl/tangerine/fennel.fnl:19")
  local out = {}
  local source = env.get("source")
  local rtps = (vim.o.runtimepath .. ",")
  table.insert(out, format_path("./", ext, macro_path_3f))
  table.insert(out, format_path(source, ext, macro_path_3f))
  for entry in rtps:gmatch("(.-),") do
    local path = (entry .. "/fnl/")
    if (1 == vim.fn.isdirectory(path)) then
      table.insert(out, format_path(path, ext, macro_path_3f))
    else
    end
  end
  return table.concat(out, ";")
end
local orig = {path = package.path}
fennel.load = function(_3fversion)
  local version = (_3fversion or env.get("compiler", "version"))
  local fennel0 = require(("tangerine.fennel." .. version))
  fennel0.path = get_path("fnl", false)
  fennel0["macro-path"] = get_path("fnl", true)
  return fennel0
end
fennel["patch-path"] = function()
  local target = get_path("lua", false)
  local source = format_path(env.get("target"), "lua", false)
  package.path = (orig.path .. ";" .. target .. ";" .. source)
  return true
end
return fennel
