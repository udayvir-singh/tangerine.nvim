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
p["from-x-to-y"] = function(path, _1_, _3_)
  local _arg_2_ = _1_
  local from = _arg_2_[1]
  local ext1 = _arg_2_[2]
  local _arg_4_ = _3_
  local to = _arg_4_[1]
  local ext2 = _arg_4_[2]
  _G.assert((nil ~= ext2), "Missing argument ext2 on fnl/tangerine/utils/path.fnl:28")
  _G.assert((nil ~= to), "Missing argument to on fnl/tangerine/utils/path.fnl:28")
  _G.assert((nil ~= ext1), "Missing argument ext1 on fnl/tangerine/utils/path.fnl:28")
  _G.assert((nil ~= from), "Missing argument from on fnl/tangerine/utils/path.fnl:28")
  _G.assert((nil ~= path), "Missing argument path on fnl/tangerine/utils/path.fnl:28")
  local from0 = env.get(from)
  local to0 = env.get(to)
  local path0 = path:gsub((ext1 .. "$"), ext2)
  if vim.startswith(path0, from0) then
    return path0:gsub(from0, to0)
  elseif "else" then
    return path0:gsub(("/" .. ext1 .. "/"), ("/" .. ext2 .. "/"))
  else
    return nil
  end
end
p.target = function(path)
  _G.assert((nil ~= path), "Missing argument path on fnl/tangerine/utils/path.fnl:38")
  local vimrc = env.get("vimrc")
  if (path == vimrc) then
    return vimrc_out
  elseif "else" then
    return p["from-x-to-y"](path, {"source", "fnl"}, {"target", "lua"})
  else
    return nil
  end
end
p.source = function(path)
  _G.assert((nil ~= path), "Missing argument path on fnl/tangerine/utils/path.fnl:46")
  local vimrc = env.get("vimrc")
  if (path == vimrc_out) then
    return vimrc
  elseif "else" then
    return p["from-x-to-y"](path, {"target", "lua"}, {"source", "fnl"})
  else
    return nil
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
  _G.assert((nil ~= pat), "Missing argument pat on fnl/tangerine/utils/path.fnl:72")
  _G.assert((nil ~= dir), "Missing argument dir on fnl/tangerine/utils/path.fnl:72")
  return vim.fn.glob((dir .. pat), 0, 1)
end
p["list-fnl-files"] = function()
  local source = env.get("source")
  local out = p.wildcard(source, "**/*.fnl")
  return out
end
p["list-lua-files"] = function()
  local target = env.get("target")
  local out = p.wildcard(target, "**/*.lua")
  return out
end
return p
