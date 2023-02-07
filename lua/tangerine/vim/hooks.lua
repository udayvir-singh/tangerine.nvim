local env = require("tangerine.utils.env")
local hooks = {}
local function exec(...)
  return vim.cmd(table.concat({...}, " "))
end
local function parse_autocmd(opts)
  _G.assert((nil ~= opts), "Missing argument opts on fnl/tangerine/vim/hooks.fnl:18")
  local groups = table.concat(table.remove(opts, 1), " ")
  return "au", groups, table.concat(opts, " ")
end
local function augroup(name, ...)
  _G.assert((nil ~= name), "Missing argument name on fnl/tangerine/vim/hooks.fnl:23")
  exec("augroup", name)
  exec("au!")
  for idx, val in ipairs({...}) do
    exec(parse_autocmd(val))
  end
  exec("augroup", "END")
  return true
end
local flat = vim.tbl_flatten
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
  local pat
  local function _2_(_241)
    return (_241 .. "*.fnl")
  end
  local function _3_(_241)
    return (_241 .. "*.fnl")
  end
  local function _4_()
    local tbl_15_auto = {}
    local i_16_auto = #tbl_15_auto
    for _, _5_ in ipairs(env.get("custom")) do
      local _each_6_ = _5_
      local s = _each_6_[1]
      local val_17_auto = s
      if (nil ~= val_17_auto) then
        i_16_auto = (i_16_auto + 1)
        do end (tbl_15_auto)[i_16_auto] = val_17_auto
      else
      end
    end
    return tbl_15_auto
  end
  pat = {env.get("vimrc"), (env.get("source") .. "*.fnl"), map(_2_, env.get("rtpdirs")), map(_3_, _4_())}
  return augroup("tangerine-onsave", {{"BufWritePost", table.concat(flat(pat), ",")}, run_hooks})
end
hooks.onload = function()
  return augroup("tangerine-onload", {{"VimEnter", "*"}, run_hooks})
end
hooks.oninit = function()
  return hooks.run()
end
return hooks
