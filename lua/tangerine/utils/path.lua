local env = require("tangerine.utils.env")
local p = {}
p.shortname = function(path)
  _G.assert((nil ~= path), "Missing argument path on fnl/tangerine/utils/path.fnl:12")
  return (path:match(".+/fnl/(.+)") or path:match(".+/lua/(.+)") or path:match(".+/(.+/.+)"))
end
p.resolve = function(path)
  _G.assert((nil ~= path), "Missing argument path on fnl/tangerine/utils/path.fnl:18")
  return vim.fn.resolve(vim.fn.expand(path))
end
local vimrc_out = (env.get("target") .. "tangerine_vimrc.lua")
local function esc_regex(str)
  _G.assert((nil ~= str), "Missing argument str on fnl/tangerine/utils/path.fnl:28")
  return str:gsub("[%%%^%$%(%)%[%]%.%*%+%-%?]", "%%%1")
end
p["transform-path"] = function(path, _1_, _3_)
  local _arg_2_ = _1_
  local key1 = _arg_2_[1]
  local ext1 = _arg_2_[2]
  local _arg_4_ = _3_
  local key2 = _arg_4_[1]
  local ext2 = _arg_4_[2]
  _G.assert((nil ~= ext2), "Missing argument ext2 on fnl/tangerine/utils/path.fnl:32")
  _G.assert((nil ~= key2), "Missing argument key2 on fnl/tangerine/utils/path.fnl:32")
  _G.assert((nil ~= ext1), "Missing argument ext1 on fnl/tangerine/utils/path.fnl:32")
  _G.assert((nil ~= key1), "Missing argument key1 on fnl/tangerine/utils/path.fnl:32")
  _G.assert((nil ~= path), "Missing argument path on fnl/tangerine/utils/path.fnl:32")
  local from = ("^" .. esc_regex(env.get(key1)))
  local to = esc_regex(env.get(key2))
  local path0 = path:gsub(("%." .. ext1 .. "$"), ("." .. ext2))
  if path0:find(from) then
    return path0:gsub(from, to)
  else
    return path0:gsub(("/" .. ext1 .. "/"), ("/" .. ext2 .. "/"))
  end
end
p.target = function(path)
  _G.assert((nil ~= path), "Missing argument path on fnl/tangerine/utils/path.fnl:41")
  local vimrc = env.get("vimrc")
  if (path == vimrc) then
    return vimrc_out
  else
    return p["transform-path"](path, {"source", "fnl"}, {"target", "lua"})
  end
end
p.source = function(path)
  _G.assert((nil ~= path), "Missing argument path on fnl/tangerine/utils/path.fnl:48")
  local vimrc = env.get("vimrc")
  if (path == vimrc_out) then
    return vimrc
  else
    return p["transform-path"](path, {"target", "lua"}, {"source", "fnl"})
  end
end
p["goto-output"] = function()
  local source = vim.fn.expand("%:p")
  local target = p.target(source)
  if ((1 == vim.fn.filereadable(target)) and (source ~= target)) then
    return vim.cmd(("edit" .. target))
  elseif "else" then
    return print("[tangerine]: error in goto-output, target not readable.")
  else
    return nil
  end
end
p.wildcard = function(dir, pat)
  _G.assert((nil ~= pat), "Missing argument pat on fnl/tangerine/utils/path.fnl:73")
  _G.assert((nil ~= dir), "Missing argument dir on fnl/tangerine/utils/path.fnl:73")
  return vim.fn.glob((dir .. pat), 0, 1)
end
p["list-fnl-files"] = function()
  local source = env.get("source")
  local out = p.wildcard(source, "**/*.fnl")
  local function _9_(_241)
    return not string.find(_241, "macros.fnl$")
  end
  return vim.tbl_filter(_9_, out)
end
p["list-lua-files"] = function()
  local target = env.get("target")
  local out = p.wildcard(target, "**/*.lua")
  return out
end
return p
