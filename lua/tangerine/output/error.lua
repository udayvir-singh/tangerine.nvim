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
err["compile?"] = function(msg)
  _G.assert((nil ~= msg), "Missing argument msg on fnl/tangerine/output/error.fnl:24")
  return toboolean((msg:match("^Parse error.*:([0-9]+)") or msg:match("^Compile error.*:([0-9]+)")))
end
err.parse = function(msg, offset)
  _G.assert((nil ~= offset), "Missing argument offset on fnl/tangerine/output/error.fnl:30")
  _G.assert((nil ~= msg), "Missing argument msg on fnl/tangerine/output/error.fnl:30")
  local lines = vim.split(msg, "\n")
  local line = string.match(lines[1], ".*:([0-9]+)")
  local msg0 = string.gsub(lines[2], "^ +", "")
  return (tonumber(line) + offset + -1), msg0
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
  _G.assert((nil ~= virtual_3f), "Missing argument virtual? on fnl/tangerine/output/error.fnl:51")
  _G.assert((nil ~= msg), "Missing argument msg on fnl/tangerine/output/error.fnl:51")
  _G.assert((nil ~= line), "Missing argument line on fnl/tangerine/output/error.fnl:51")
  if not vim.diagnostic then
    return
  else
  end
  local buffer = vim.api.nvim_get_current_buf()
  local timeout = env.get("eval", "diagnostic", "timeout")
  local nspace = vim.api.nvim_create_namespace("tangerine")
  local function _4_()
    if virtual_3f then
      return {virtual_text = {spacing = 1, prefix = ";;"}}
    else
      return {virtual_text = false}
    end
  end
  vim.diagnostic.set(nspace, buffer, {{lnum = line, col = 0, end_col = -1, severity = vim.diagnostic.severity.ERROR, source = "tangerine", message = msg}}, _4_())
  do end (timer.get):start((1000 * timeout), 0, vim.schedule_wrap(err.clear))
  return true
end
err.soft = function(msg)
  _G.assert((nil ~= msg), "Missing argument msg on fnl/tangerine/output/error.fnl:82")
  return vim.api.nvim_echo({{msg, hl_errors}}, false, {})
end
err.float = function(msg)
  _G.assert((nil ~= msg), "Missing argument msg on fnl/tangerine/output/error.fnl:86")
  return win["set-float"](msg, "text", hl_errors)
end
err.handle = function(msg, opts)
  _G.assert((nil ~= opts), "Missing argument opts on fnl/tangerine/output/error.fnl:90")
  _G.assert((nil ~= msg), "Missing argument msg on fnl/tangerine/output/error.fnl:90")
  if (err["compile?"](msg) and number_3f(opts.offset)) then
    local line, msg0 = err.parse(msg, opts.offset)
    err.send(line, msg0, env.conf(opts, {"eval", "diagnostic", "virtual"}))
  else
  end
  if env.conf(opts, {"eval", "float"}) then
    err.float(msg)
  else
    err.soft(msg)
  end
  return true
end
return err
