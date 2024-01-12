local env = require("tangerine.utils.env")
local hooks = {}
local windows_3f = (_G.jit.os == "Windows")
local function esc_file_pattern(path)
  _G.assert((nil ~= path), "Missing argument path on fnl/tangerine/vim/hooks.fnl:16")
  local _1_ = path:gsub("[%*%?%[%]%{%}\\,]", "\\%1")
  return _1_
end
local function resolve_file_pattern(path)
  _G.assert((nil ~= path), "Missing argument path on fnl/tangerine/vim/hooks.fnl:21")
  local function _2_()
    if windows_3f then
      return path:gsub("\\", "/")
    else
      return path
    end
  end
  return esc_file_pattern(_2_())
end
local function exec(...)
  return vim.cmd(table.concat({...}, " "))
end
local function parse_autocmd(opts)
  _G.assert((nil ~= opts), "Missing argument opts on fnl/tangerine/vim/hooks.fnl:30")
  local groups = table.concat(table.remove(opts, 1), " ")
  return "au", groups, table.concat(opts, " ")
end
local function augroup(name, ...)
  _G.assert((nil ~= name), "Missing argument name on fnl/tangerine/vim/hooks.fnl:35")
  exec("augroup", name)
  exec("au!")
  for idx, val in ipairs({...}) do
    exec(parse_autocmd(val))
  end
  exec("augroup", "END")
  return true
end
local map = vim.tbl_map
hooks.run = function()
  if env.get("compiler", "clean") then
    _G.tangerine.api.clean.orphaned()
  else
  end
  return _G.tangerine.api.compile.all()
end
local run_hooks = "lua require 'tangerine.vim.hooks'.run()"
hooks.onsave = function()
  local patterns
  local function _4_(_241)
    return (resolve_file_pattern(_241) .. "*.fnl")
  end
  local function _5_(_241)
    return (resolve_file_pattern(_241) .. "*.fnl")
  end
  local function _6_()
    local tbl_15_auto = {}
    local i_16_auto = #tbl_15_auto
    for _, _7_ in ipairs(env.get("custom")) do
      local _each_8_ = _7_
      local s = _each_8_[1]
      local val_17_auto = s
      if (nil ~= val_17_auto) then
        i_16_auto = (i_16_auto + 1)
        do end (tbl_15_auto)[i_16_auto] = val_17_auto
      else
      end
    end
    return tbl_15_auto
  end
  patterns = vim.tbl_flatten({resolve_file_pattern(env.get("vimrc")), (resolve_file_pattern(env.get("source")) .. "*.fnl"), map(_4_, env.get("rtpdirs")), map(_5_, _6_())})
  return augroup("tangerine-onsave", {{"BufWritePost", table.concat(patterns, ",")}, run_hooks})
end
hooks.onload = function()
  return augroup("tangerine-onload", {{"VimEnter", "*"}, run_hooks})
end
hooks.oninit = function()
  return hooks.run()
end
return hooks
