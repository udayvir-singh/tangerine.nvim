local _local_1_ = require("tangerine.utils")
local p = _local_1_["p"]
local fs = _local_1_["fs"]
local df = _local_1_["df"]
local env = _local_1_["env"]
local _local_2_ = require("tangerine.output")
local log = _local_2_["log"]
local clean = {}
local function merge(list1, list2)
  _G.assert((nil ~= list2), "Missing argument list2 on fnl/tangerine/api/clean.fnl:26")
  _G.assert((nil ~= list1), "Missing argument list1 on fnl/tangerine/api/clean.fnl:26")
  for _, val in ipairs(list2) do
    table.insert(list1, val)
  end
  return list1
end
local function tbl_merge(tbl1, tbl2)
  _G.assert((nil ~= tbl2), "Missing argument tbl2 on fnl/tangerine/api/clean.fnl:32")
  _G.assert((nil ~= tbl1), "Missing argument tbl1 on fnl/tangerine/api/clean.fnl:32")
  return vim.tbl_extend("keep", (tbl1 or {}), tbl2)
end
clean.target = function(source, target, _3fopts)
  _G.assert((nil ~= target), "Missing argument target on fnl/tangerine/api/clean.fnl:40")
  _G.assert((nil ~= source), "Missing argument source on fnl/tangerine/api/clean.fnl:40")
  local opts = (_3fopts or {})
  local target0 = p.resolve(target)
  local source_3f = fs["readable?"](p.resolve(source))
  local marker_3f = df["read-marker"](target0)
  local force_3f = env.conf(opts, {"force"})
  if (marker_3f and (not source_3f or force_3f)) then
    return fs.remove(target0)
  elseif "else" then
    return false
  else
    return nil
  end
end
clean.rtp = function(_3fopts)
  local opts = (_3fopts or {})
  local logs = {}
  local dirs = env.conf(opts, {"rtpdirs"})
  for _, dir in ipairs(dirs) do
    for _0, target in ipairs(p.wildcard(dir, "**/*.lua")) do
      local source = target:gsub(".lua$", ".fnl")
      if clean.target(source, target, opts) then
        table.insert(logs, p.shortname(target))
      else
      end
    end
  end
  log.success("CLEANED", logs, opts)
  return logs
end
clean.orphaned = function(_3fopts)
  local opts = (_3fopts or {})
  local logs = {}
  merge(logs, clean.rtp(tbl_merge({verbose = false}, opts)))
  for _, target in ipairs(p["list-lua-files"]()) do
    if clean.target(p.source(target), target, opts) then
      table.insert(logs, p.shortname(target))
    else
    end
  end
  return log.success("CLEANED", logs, opts)
end
return clean
