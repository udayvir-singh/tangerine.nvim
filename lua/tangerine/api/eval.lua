local fennel = require("tangerine.fennel")
local _local_1_ = require("tangerine.utils")
local p = _local_1_["p"]
local fs = _local_1_["fs"]
local _local_2_ = require("tangerine.output")
local dp = _local_2_["dp"]
local err = _local_2_["err"]
local eval = {}
local function get_lines(start, _end)
  _G.assert((nil ~= _end), "Missing argument end on fnl/tangerine/api/eval.fnl:26")
  _G.assert((nil ~= start), "Missing argument start on fnl/tangerine/api/eval.fnl:26")
  return table.concat(vim.api.nvim_buf_get_lines(0, start, _end, true), "\n")
end
local function get_bufname()
  local bufname = vim.fn.expand("%:t")
  if (bufname ~= "") then
    return bufname
  elseif "else" then
    return "[No Name]"
  else
    return nil
  end
end
local function tbl_merge(tbl1, tbl2)
  _G.assert((nil ~= tbl2), "Missing argument tbl2 on fnl/tangerine/api/eval.fnl:37")
  _G.assert((nil ~= tbl1), "Missing argument tbl1 on fnl/tangerine/api/eval.fnl:37")
  return vim.tbl_extend("keep", tbl1, tbl2)
end
eval.string = function(str, _3fopts)
  _G.assert((nil ~= str), "Missing argument str on fnl/tangerine/api/eval.fnl:45")
  local opts = (_3fopts or {})
  local fennel0 = fennel.load()
  local filename = (opts.filename or "string")
  err.clear()
  local ok, result = nil, nil
  local function _4_()
    return {fennel0.eval(str, {filename = filename, compilerEnv = _G, useBitLib = true})}
  end
  local function _5_(_241)
    return err.handle(_241, opts)
  end
  ok, result = xpcall(_4_, _5_)
  if not ok then
    return false
  else
  end
  dp.show(result, opts)
  return unpack(result)
end
eval.file = function(path, _3fopts)
  _G.assert((nil ~= path), "Missing argument path on fnl/tangerine/api/eval.fnl:61")
  local opts = (_3fopts or {})
  local path0 = p.resolve(path)
  local sname = p.shortname(path0)
  assert(fs["readable?"](path0), ("[tangerine]: error in 'eval-file', file not readable " .. path0))
  return eval.string(fs.read(path0), tbl_merge(opts, {filename = sname}))
end
eval.buffer = function(start, _end, _3fopts)
  _G.assert((nil ~= _end), "Missing argument end on fnl/tangerine/api/eval.fnl:72")
  _G.assert((nil ~= start), "Missing argument start on fnl/tangerine/api/eval.fnl:72")
  local opts = (_3fopts or {})
  local start0 = (start - 1)
  local lines = get_lines(start0, _end)
  local bufname = get_bufname()
  return eval.string(lines, tbl_merge(opts, {filename = bufname, offset = start0}))
end
eval.peek = function(start, _end, _3fopts)
  _G.assert((nil ~= _end), "Missing argument end on fnl/tangerine/api/eval.fnl:90")
  _G.assert((nil ~= start), "Missing argument start on fnl/tangerine/api/eval.fnl:90")
  local opts = (_3fopts or {})
  local fennel0 = fennel.load()
  local start0 = (start - 1)
  local lines = get_lines(start0, _end)
  local bufname = get_bufname()
  err.clear()
  local ok, result = nil, nil
  local function _7_()
    return fennel0.compileString(lines, {filename = (opts.filename or bufname), compilerEnv = _G, useBitLib = true})
  end
  local function _8_(_241)
    return err.handle(_241, tbl_merge({offset = start0}, opts))
  end
  ok, result = xpcall(_7_, _8_)
  if not ok then
    return false
  else
  end
  dp["show-lua"](result, opts)
  return result
end
return eval
