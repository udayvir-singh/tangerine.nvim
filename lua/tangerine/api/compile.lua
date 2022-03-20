local fennel = require("tangerine.fennel")
local _local_1_ = require("tangerine.utils")
local p = _local_1_["p"]
local fs = _local_1_["fs"]
local df = _local_1_["df"]
local env = _local_1_["env"]
local win = _local_1_["win"]
local _local_2_ = require("tangerine.output")
local log = _local_2_["log"]
local err = _local_2_["err"]
local compile = {}
local function quoted(str)
  _G.assert((nil ~= str), "Missing argument str on fnl/tangerine/api/compile.fnl:31")
  local qt = "\""
  return (qt .. str .. qt)
end
local function compiled(source)
  _G.assert((nil ~= source), "Missing argument source on fnl/tangerine/api/compile.fnl:36")
  return print(quoted(source), "compiled")
end
local function compile_3f(source, target, opts)
  _G.assert((nil ~= opts), "Missing argument opts on fnl/tangerine/api/compile.fnl:40")
  _G.assert((nil ~= target), "Missing argument target on fnl/tangerine/api/compile.fnl:40")
  _G.assert((nil ~= source), "Missing argument source on fnl/tangerine/api/compile.fnl:40")
  return (env.conf(opts, {"compiler", "force"}) or df["stale?"](source, target))
end
local function merge(list1, list2)
  _G.assert((nil ~= list2), "Missing argument list2 on fnl/tangerine/api/compile.fnl:45")
  _G.assert((nil ~= list1), "Missing argument list1 on fnl/tangerine/api/compile.fnl:45")
  for _, val in ipairs(list2) do
    table.insert(list1, val)
  end
  return list1
end
local function tbl_merge(tbl1, tbl2)
  _G.assert((nil ~= tbl2), "Missing argument tbl2 on fnl/tangerine/api/compile.fnl:51")
  _G.assert((nil ~= tbl1), "Missing argument tbl1 on fnl/tangerine/api/compile.fnl:51")
  return vim.tbl_extend("keep", (tbl1 or {}), tbl2)
end
compile.string = function(str, _3fopts)
  _G.assert((nil ~= str), "Missing argument str on fnl/tangerine/api/compile.fnl:76")
  local opts = (_3fopts or {})
  local fennel0 = fennel.load()
  local filename = (opts.filename or "tangerine-out")
  local globals = env.conf(opts, {"compiler", "globals"})
  return fennel0.compileString(str, {filename = filename, allowedGlobals = globals, compilerEnv = _G})
end
compile.file = function(source, target, _3fopts)
  _G.assert((nil ~= target), "Missing argument target on fnl/tangerine/api/compile.fnl:86")
  _G.assert((nil ~= source), "Missing argument source on fnl/tangerine/api/compile.fnl:86")
  local opts = (_3fopts or {})
  local source0 = p.resolve(source)
  local target0 = p.resolve(target)
  local sname = p.shortname(source0)
  local opts0 = tbl_merge(opts, {filename = sname})
  if not fs["readable?"](source0) then
    err.soft(("[tangerine]: source " .. (sname or source0) .. " is not readable."))
  else
  end
  local marker = df["create-marker"](source0)
  local output = compile.string(fs.read(source0), opts0)
  fs.write(target0, (marker .. "\n" .. output))
  return true
end
compile.dir = function(sourcedir, targetdir, _3fopts)
  _G.assert((nil ~= targetdir), "Missing argument targetdir on fnl/tangerine/api/compile.fnl:104")
  _G.assert((nil ~= sourcedir), "Missing argument sourcedir on fnl/tangerine/api/compile.fnl:104")
  local opts = (_3fopts or {})
  local logs = {}
  for _, source in ipairs(p.wildcard(sourcedir, "**/*.fnl")) do
    local sname = p.shortname(source)
    local opts0 = tbl_merge({filename = sname}, opts)
    local target = string.gsub(string.gsub(source, "fnl$", "lua"), p.resolve(sourcedir), p.resolve(targetdir))
    if compile_3f(source, target, opts0) then
      table.insert(logs, sname)
      local out_2_auto
      local function _4_()
        return compile.file(source, target, opts0)
      end
      local function _5_(_241)
        return log.failure("COMPILE ERROR", sname, _241, opts0)
      end
      out_2_auto = xpcall(_4_, _5_)
      if ((0 == out_2_auto) or (false == out_2_auto)) then
        return 0
      else
      end
    else
    end
  end
  log.success("COMPILED", logs, opts)
  return logs
end
compile.buffer = function(_3fopts)
  local opts = (_3fopts or {})
  local bufname = vim.fn.expand("%:p")
  local sname = vim.fn.expand("%:t")
  local target = p.target(bufname)
  do
    local out_2_auto
    local function _8_()
      return compile.file(bufname, target, tbl_merge(opts, {filename = sname}))
    end
    local function _9_(_241)
      return log.failure("COMPILE ERROR", sname, _241, opts)
    end
    out_2_auto = xpcall(_8_, _9_)
    if ((0 == out_2_auto) or (false == out_2_auto)) then
      return 0
    else
    end
  end
  if env.conf(opts, {"compiler", "verbose"}) then
    compiled(sname)
  else
  end
  return true
end
compile.vimrc = function(_3fopts)
  local opts = (_3fopts or {})
  local source = env.get("vimrc")
  local target = p.target(source)
  local sname = p.shortname(source)
  if compile_3f(source, target, opts) then
    do
      local out_2_auto
      local function _12_()
        return compile.file(source, target, opts)
      end
      local function _13_(_241)
        return log.failure("COMPILE ERROR", sname, _241, opts)
      end
      out_2_auto = xpcall(_12_, _13_)
      if ((0 == out_2_auto) or (false == out_2_auto)) then
        return 0
      else
      end
    end
    if env.conf(opts, {"compiler", "verbose"}) then
      compiled(sname)
    else
    end
    return {sname}
  else
    return nil
  end
end
compile.rtp = function(_3fopts)
  local opts = (_3fopts or {})
  local logs = {}
  local dirs = env.conf(opts, {"rtpdirs"})
  for _, dir in ipairs(dirs) do
    local out_2_auto = (compile.dir(dir, dir, tbl_merge({verbose = false}, opts)) or {})
    do
      local out_2_auto0 = out_2_auto
      if ((0 == out_2_auto0) or (false == out_2_auto0)) then
        return 0
      else
      end
    end
    merge(logs, out_2_auto)
  end
  log.success("COMPILED RTP", logs, opts)
  return logs
end
compile.all = function(_3fopts)
  local opts = (_3fopts or {})
  local copts = tbl_merge({verbose = false}, opts)
  local logs = {}
  do
    local out_2_auto = (compile.vimrc(copts) or {})
    do
      local out_2_auto0 = out_2_auto
      if ((0 == out_2_auto0) or (false == out_2_auto0)) then
        return 0
      else
      end
    end
    merge(logs, out_2_auto)
  end
  for _, source in ipairs(p["list-fnl-files"]()) do
    local target = p.target(source)
    local sname = p.shortname(source)
    if compile_3f(source, target, opts) then
      table.insert(logs, sname)
      local out_2_auto
      local function _19_()
        return compile.file(source, target, opts)
      end
      local function _20_(_241)
        return log.failure("COMPILE ERROR", sname, _241, opts)
      end
      out_2_auto = xpcall(_19_, _20_)
      if ((0 == out_2_auto) or (false == out_2_auto)) then
        return 0
      else
      end
    else
    end
  end
  do
    local out_2_auto = (compile.rtp(copts) or {})
    do
      local out_2_auto0 = out_2_auto
      if ((0 == out_2_auto0) or (false == out_2_auto0)) then
        return 0
      else
      end
    end
    merge(logs, out_2_auto)
  end
  log.success("COMPILED", logs, opts)
  return logs
end
return compile
