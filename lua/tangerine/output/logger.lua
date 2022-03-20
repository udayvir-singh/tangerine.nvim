local env = require("tangerine.utils.env")
local win = require("tangerine.utils.window")
local log = {}
local hl_success = env.get("highlight", "success")
local hl_failure = env.get("highlight", "errors")
local hl_float = env.get("highlight", "float")
local function empty_3f(list)
  _G.assert((nil ~= list), "Missing argument list on fnl/tangerine/output/logger.fnl:18")
  if not vim.tbl_islist(list) then
    error(("[tangerine]: error in logger, expected 'list' to be a valid list got " .. type(list) .. "."))
  else
  end
  return (#list == 0)
end
local function indent(str, level)
  _G.assert((nil ~= level), "Missing argument level on fnl/tangerine/output/logger.fnl:26")
  _G.assert((nil ~= str), "Missing argument str on fnl/tangerine/output/logger.fnl:26")
  local spaces = ""
  for _ = 1, level do
    spaces = (spaces .. " ")
  end
  return string.gsub(string.gsub(str, "^", spaces), "\n", ("\n" .. spaces))
end
local function syn_match(group, pattern)
  _G.assert((nil ~= pattern), "Missing argument pattern on fnl/tangerine/output/logger.fnl:35")
  _G.assert((nil ~= group), "Missing argument group on fnl/tangerine/output/logger.fnl:35")
  return vim.cmd(("syn match " .. group .. " \"" .. pattern .. "\""))
end
local header_block = ":: "
local success_block = "  ==> "
local failure_block = "  xxx "
local function parse_title(title)
  _G.assert((nil ~= title), "Missing argument title on fnl/tangerine/output/logger.fnl:48")
  return (header_block .. title)
end
log["print-success"] = function(title, files)
  _G.assert((nil ~= files), "Missing argument files on fnl/tangerine/output/logger.fnl:52")
  _G.assert((nil ~= title), "Missing argument title on fnl/tangerine/output/logger.fnl:52")
  print(parse_title(title))
  for _, file in ipairs(files) do
    vim.api.nvim_echo({{success_block, hl_success}, {file, "Normal"}}, false, {})
  end
  return nil
end
log["print-failure"] = function(title, file, msg)
  _G.assert((nil ~= msg), "Missing argument msg on fnl/tangerine/output/logger.fnl:58")
  _G.assert((nil ~= file), "Missing argument file on fnl/tangerine/output/logger.fnl:58")
  _G.assert((nil ~= title), "Missing argument title on fnl/tangerine/output/logger.fnl:58")
  print(parse_title(title))
  vim.api.nvim_echo({{failure_block, hl_failure}, {file, "Normal"}}, false, {})
  return vim.api.nvim_echo({{indent(msg, #failure_block), hl_failure}}, false, {})
end
log["float-success"] = function(title, files)
  _G.assert((nil ~= files), "Missing argument files on fnl/tangerine/output/logger.fnl:64")
  _G.assert((nil ~= title), "Missing argument title on fnl/tangerine/output/logger.fnl:64")
  local out = parse_title(title)
  for _, file in ipairs(files) do
    out = (out .. "\n" .. success_block .. file)
  end
  win["set-float"](out, "text", "Normal")
  return syn_match(hl_success, success_block)
end
log["float-failure"] = function(title, file, msg)
  _G.assert((nil ~= msg), "Missing argument msg on fnl/tangerine/output/logger.fnl:72")
  _G.assert((nil ~= file), "Missing argument file on fnl/tangerine/output/logger.fnl:72")
  _G.assert((nil ~= title), "Missing argument title on fnl/tangerine/output/logger.fnl:72")
  local out = ((parse_title(title) .. "\n" .. failure_block .. file) .. "\n" .. indent(msg, #failure_block))
  win["set-float"](out, "text", "Normal")
  syn_match(hl_failure, failure_block)
  return syn_match(hl_failure, indent(".*", #failure_block))
end
log.success = function(title, files, opts)
  _G.assert((nil ~= opts), "Missing argument opts on fnl/tangerine/output/logger.fnl:86")
  _G.assert((nil ~= files), "Missing argument files on fnl/tangerine/output/logger.fnl:86")
  _G.assert((nil ~= title), "Missing argument title on fnl/tangerine/output/logger.fnl:86")
  if (empty_3f(files) or not env.conf(opts, {"compiler", "verbose"})) then
    return
  else
  end
  if env.conf(opts, {"compiler", "float"}) then
    log["float-success"](title, files)
  elseif "else" then
    log["print-success"](title, files)
  else
  end
  return true
end
log.failure = function(title, file, msg, opts)
  _G.assert((nil ~= opts), "Missing argument opts on fnl/tangerine/output/logger.fnl:98")
  _G.assert((nil ~= msg), "Missing argument msg on fnl/tangerine/output/logger.fnl:98")
  _G.assert((nil ~= file), "Missing argument file on fnl/tangerine/output/logger.fnl:98")
  _G.assert((nil ~= title), "Missing argument title on fnl/tangerine/output/logger.fnl:98")
  if env.conf(opts, {"compiler", "float"}) then
    log["float-failure"](title, file, msg)
  elseif "else" then
    log["print-failure"](title, file, msg)
  else
  end
  return true
end
return log
