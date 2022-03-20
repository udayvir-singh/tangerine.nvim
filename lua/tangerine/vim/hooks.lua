local env = require("tangerine.utils.env")
local hooks = {}
local function exec(...)
  return vim.cmd(table.concat({...}, " "))
end
local function parse_autocmd(opts)
  _G.assert((nil ~= opts), "Missing argument opts on fnl/tangerine/vim/hooks.fnl:18")
  local groups = table.concat(opts[1], " ")
  table.remove(opts, 1)
  return "au", groups, table.concat(opts, " ")
end
local function augroup(name, ...)
  _G.assert((nil ~= name), "Missing argument name on fnl/tangerine/vim/hooks.fnl:24")
  exec("augroup", name)
  exec("au!")
  for idx, val in ipairs({...}) do
    exec(parse_autocmd(val))
  end
  exec("augroup", "END")
  return true
end
hooks.run = function()
  local function _1_()
    local clean_3f = env.get("compiler", "clean")
    if clean_3f then
      _G.tangerine.api.clean.orphaned()
    else
    end
    return _G.tangerine.api.compile.all()
  end
  return vim.schedule_wrap(_1_)()
end
local run_hooks = "lua require 'tangerine.vim.hooks'.run()"
hooks.onsave = function()
  local vimrc = env.get("vimrc")
  local source = env.get("source")
  local sources = (source .. "*.fnl," .. vimrc)
  return augroup("tangerine-onsave", {{"BufWritePost", sources}, run_hooks})
end
hooks.onload = function()
  return augroup("tangerine-onload", {{"VimEnter", "*"}, run_hooks})
end
hooks.oninit = function()
  return hooks.run()
end
return hooks
