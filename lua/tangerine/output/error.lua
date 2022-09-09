local env = require("tangerine.utils.env")
local win = require("tangerine.utils.window")
local err = {}
local hl_errors = env.get("highlight", "errors")
local function number_3f(int)
  return (type(int) == "number")
end
local function toboolean(x)
  if x then
    return true
  else
    return false
  end
end
err["compile?"] = function(msg, _3fraw)
  _G.assert((nil ~= msg), "Missing argument msg on fnl/tangerine/output/error.fnl:24")
  local e
  if _3fraw then
    e = "[0-9?]+"
  else
    e = "[0-9]+"
  end
  return toboolean((msg:match(("^[%s\9]*Parse error.*:" .. e)) or msg:match(("^[%s\9]*Compile error.*:" .. e))))
end
err.parse = function(msg, offset)
  _G.assert((nil ~= offset), "Missing argument offset on fnl/tangerine/output/error.fnl:31")
  _G.assert((nil ~= msg), "Missing argument msg on fnl/tangerine/output/error.fnl:31")
  local lines = vim.split(msg, "\n")
  local line = string.match(lines[1], ".-:([0-9]+)")
  local shortmsg = ""
  for _, line0 in ipairs(lines) do
    if not err["compile?"](line0, true) then
      shortmsg = line0:gsub("^[%s\9]+", "")
      break
    else
    end
  end
  return (tonumber(line) + offset + -1), shortmsg
end
local timer = {get = vim.loop.new_timer()}
err.clear = function()
  if not vim.diagnostic then
    return
  else
  end
  local nspace = vim.api.nvim_create_namespace("tangerine")
  vim.diagnostic.reset(nspace)
  return vim.api.nvim_buf_clear_namespace(0, nspace, 0, -1)
end
err.send = function(line, msg, virtual_3f)
  _G.assert((nil ~= virtual_3f), "Missing argument virtual? on fnl/tangerine/output/error.fnl:58")
  _G.assert((nil ~= msg), "Missing argument msg on fnl/tangerine/output/error.fnl:58")
  _G.assert((nil ~= line), "Missing argument line on fnl/tangerine/output/error.fnl:58")
  if not vim.diagnostic then
    return
  else
  end
  local buffer = vim.api.nvim_get_current_buf()
  local timeout = env.get("eval", "diagnostic", "timeout")
  local nspace = vim.api.nvim_create_namespace("tangerine")
  local function _6_()
    if virtual_3f then
      return {virtual_text = {spacing = 1, prefix = ";;"}}
    else
      return {virtual_text = false}
    end
  end
  vim.diagnostic.set(nspace, buffer, {{lnum = line, col = 0, end_col = -1, severity = vim.diagnostic.severity.ERROR, source = "tangerine", message = msg}}, _6_())
  do end (timer.get):start((1000 * timeout), 0, vim.schedule_wrap(err.clear))
  return true
end
err.soft = function(msg)
  _G.assert((nil ~= msg), "Missing argument msg on fnl/tangerine/output/error.fnl:89")
  return vim.api.nvim_echo({{msg, hl_errors}}, false, {})
end
err.float = function(msg)
  _G.assert((nil ~= msg), "Missing argument msg on fnl/tangerine/output/error.fnl:93")
  return win["set-float"](msg, "text", hl_errors)
end
err.handle = function(msg, opts)
  _G.assert((nil ~= opts), "Missing argument opts on fnl/tangerine/output/error.fnl:97")
  _G.assert((nil ~= msg), "Missing argument msg on fnl/tangerine/output/error.fnl:97")
  local msg0 = msg:gsub("%c%[[0-9]m", "")
  if (err["compile?"](msg0) and number_3f(opts.offset)) then
    local line, msg1 = err.parse(msg0, opts.offset)
    err.send(line, msg1, env.conf(opts, {"eval", "diagnostic", "virtual"}))
  else
  end
  if env.conf(opts, {"eval", "float"}) then
    err.float(msg0)
  else
    err.soft(msg0)
  end
  return true
end
return err
