-- :fennel:1682267172
local config_dir = vim.fn.stdpath("config")
local a = ""
local function endswith(str, args)
  _G.assert((nil ~= args), "Missing argument args on env.fnl:12")
  _G.assert((nil ~= str), "Missing argument str on env.fnl:12")
  for i, v in pairs(args) do
    if vim.endswith(str, v) then
      return true
    else
    end
  end
  return nil
end
local function resolve(path)
  _G.assert((nil ~= path), "Missing argument path on env.fnl:18")
  local out = vim.fn.resolve(vim.fn.expand(path)):gsub("\\", "/")
  if endswith(out, {"/", ".fnl", ".lua"}) then
    return out
  else
    return (out .. "/")
  end
end
local function rtpdirs(dirs)
  _G.assert((nil ~= dirs), "Missing argument dirs on env.fnl:25")
  local tbl_17_auto = {}
  local i_18_auto = #tbl_17_auto
  for _, dir in ipairs(dirs) do
    local val_19_auto
    do
      local path = resolve(dir)
      if vim.startswith(path, "/") then
        val_19_auto = path
      else
        val_19_auto = (config_dir .. "/" .. path)
      end
    end
    if (nil ~= val_19_auto) then
      i_18_auto = (i_18_auto + 1)
      do end (tbl_17_auto)[i_18_auto] = val_19_auto
    else
    end
  end
  return tbl_17_auto
end
local function get_type(x)
  _G.assert((nil ~= x), "Missing argument x on env.fnl:33")
  if vim.tbl_islist(x) then
    return "list"
  else
    return type(x)
  end
end
local function table_3f(tbl, scm)
  _G.assert((nil ~= scm), "Missing argument scm on env.fnl:39")
  _G.assert((nil ~= tbl), "Missing argument tbl on env.fnl:39")
  return (("table" == type(tbl)) and not vim.tbl_islist(scm))
end
local function deepcopy(tbl1, tbl2)
  _G.assert((nil ~= tbl2), "Missing argument tbl2 on env.fnl:44")
  _G.assert((nil ~= tbl1), "Missing argument tbl1 on env.fnl:44")
  for key, val in pairs(tbl1) do
    if table_3f(val, (tbl2)[key]) then
      deepcopy(val, (tbl2)[key])
    elseif "else" then
      tbl2[key] = val
    else
    end
  end
  return nil
end
local function luafmt()
  local exec = vim.fn.expand("~/.luarocks/bin/lua-format")
  local width = vim.api.nvim_win_get_width(0)
  return {exec, "--spaces-inside-table-braces", "--column-table-limit", math.floor((width / 1.7)), "--column-limit", width}
end
local pre_schema
local function _7_(_241)
  local tbl_17_auto = {}
  local i_18_auto = #tbl_17_auto
  for _, _8_ in ipairs(_241) do
    local _each_9_ = _8_
    local s = _each_9_[1]
    local t = _each_9_[2]
    local val_19_auto = {resolve(s), resolve(t)}
    if (nil ~= val_19_auto) then
      i_18_auto = (i_18_auto + 1)
      do end (tbl_17_auto)[i_18_auto] = val_19_auto
    else
    end
  end
  return tbl_17_auto
end
pre_schema = {source = resolve, target = resolve, vimrc = resolve, rtpdirs = rtpdirs, custom = _7_, compiler = nil, eval = nil, keymaps = nil, highlight = nil}
local schema = {source = "string", target = "string", vimrc = "string", rtpdirs = {"string"}, custom = {{"string"}}, compiler = {float = "boolean", clean = "boolean", force = "boolean", verbose = "boolean", globals = {"string"}, version = {"oneof", {"latest", "1-2-1", "1-2-0", "1-1-0", "1-0-0", "0-10-0", "0-9-2"}}, hooks = {"array", {"onsave", "onload", "oninit"}}}, eval = {float = "boolean", luafmt = "function", diagnostic = {virtual = "boolean", timeout = "number"}}, keymaps = {peek_buffer = "string", eval_buffer = "string", goto_output = "string", float = {next = "string", prev = "string", kill = "string", close = "string", resizef = "string", resizeb = "string"}}, highlight = {float = "string", success = "string", errors = "string"}}
local ENV = {vimrc = resolve((config_dir .. "/init.fnl")), source = resolve((config_dir .. "/fnl/")), target = resolve((config_dir .. "/lua/")), rtpdirs = {}, custom = {}, compiler = {float = true, clean = true, verbose = true, version = "latest", globals = vim.tbl_keys(_G), hooks = {}, force = false}, eval = {float = true, luafmt = luafmt, diagnostic = {virtual = true, timeout = 10}}, keymaps = {eval_buffer = "gE", peek_buffer = "gL", goto_output = "gO", float = {next = "<C-K>", prev = "<C-J>", kill = "<Esc>", close = "<Enter>", resizef = "<C-W>=", resizeb = "<C-W>-"}}, highlight = {float = "Normal", success = "String", errors = "DiagnosticError"}}
local function validate_err(key, msg, ...)
  _G.assert((nil ~= msg), "Missing argument msg on env.fnl:183")
  _G.assert((nil ~= key), "Missing argument key on env.fnl:183")
  return error(("[tangerine]: bad argument to 'setup()' in key " .. key .. ": " .. table.concat({msg, ...}, " ") .. "."))
end
local function validate_type(key, val, scm)
  _G.assert((nil ~= scm), "Missing argument scm on env.fnl:189")
  _G.assert((nil ~= val), "Missing argument val on env.fnl:189")
  _G.assert((nil ~= key), "Missing argument key on env.fnl:189")
  local tv = get_type(val)
  if (scm ~= tv) then
    return validate_err(key, scm, "expected got", tv)
  else
    return nil
  end
end
local function validate_oneof(key, val, scm)
  _G.assert((nil ~= scm), "Missing argument scm on env.fnl:196")
  _G.assert((nil ~= val), "Missing argument val on env.fnl:196")
  _G.assert((nil ~= key), "Missing argument key on env.fnl:196")
  if not vim.tbl_contains(scm, val) then
    return validate_err(key, "value expected to be one of", vim.inspect(scm), "got", vim.inspect(val))
  else
    return nil
  end
end
local function validate_array(key, array, scm)
  _G.assert((nil ~= scm), "Missing argument scm on env.fnl:202")
  _G.assert((nil ~= array), "Missing argument array on env.fnl:202")
  _G.assert((nil ~= key), "Missing argument key on env.fnl:202")
  validate_type(key, array, "list")
  for _, val in ipairs(array) do
    validate_oneof(key, val, scm)
  end
  return nil
end
local function validate_list(key, list, scm)
  _G.assert((nil ~= scm), "Missing argument scm on env.fnl:209")
  _G.assert((nil ~= list), "Missing argument list on env.fnl:209")
  _G.assert((nil ~= key), "Missing argument key on env.fnl:209")
  validate_type(key, list, "list")
  for _, val in ipairs(list) do
    if ("list" == get_type(scm)) then
      validate_list(key, val, scm[1])
    else
      local tv = get_type(val)
      if (scm ~= tv) then
        validate_err(key, "member", (vim.inspect(val) .. ":"), scm, "expected got", tv)
      else
      end
    end
  end
  return nil
end
local function validate(tbl, schema0)
  _G.assert((nil ~= schema0), "Missing argument schema on env.fnl:220")
  _G.assert((nil ~= tbl), "Missing argument tbl on env.fnl:220")
  for key, val in pairs(tbl) do
    local scm = (schema0)[key]
    if not scm then
      validate_err(key, "invalid", "key")
    else
    end
    local _16_ = {get_type(scm), scm[1]}
    if ((_G.type(_16_) == "table") and ((_16_)[1] == "string") and ((_16_)[2] == nil)) then
      validate_type(key, val, scm)
    elseif ((_G.type(_16_) == "table") and ((_16_)[1] == "table") and ((_16_)[2] == nil)) then
      validate(val, scm)
    elseif ((_G.type(_16_) == "table") and ((_16_)[1] == "list") and ((_16_)[2] == "oneof")) then
      validate_oneof(key, val, scm[2])
    elseif ((_G.type(_16_) == "table") and ((_16_)[1] == "list") and ((_16_)[2] == "array")) then
      validate_array(key, val, scm[2])
    elseif ((_G.type(_16_) == "table") and ((_16_)[1] == "list") and true) then
      local _ = (_16_)[2]
      validate_list(key, val, scm[1])
    else
    end
  end
  return nil
end
local function pre_process(tbl, schema0)
  _G.assert((nil ~= schema0), "Missing argument schema on env.fnl:234")
  _G.assert((nil ~= tbl), "Missing argument tbl on env.fnl:234")
  for key, val in pairs(tbl) do
    local pre = (schema0)[key]
    local _18_ = type(pre)
    if (_18_ == "table") then
      pre_process(val, pre)
    elseif (_18_ == "function") then
      tbl[key] = pre(val)
    else
    end
  end
  return tbl
end
local function env_get(...)
  local keys = {...}
  local cur = ENV
  while ((nil ~= cur) and (0 < #keys)) do
    cur = cur[table.remove(keys, 1)]
  end
  return cur
end
local function env_get_conf(opts, keys)
  _G.assert((nil ~= keys), "Missing argument keys on env.fnl:255")
  _G.assert((nil ~= opts), "Missing argument opts on env.fnl:255")
  local last = keys[#keys]
  if (nil ~= opts[last]) then
    return pre_process(opts, pre_schema)[last]
  else
    return env_get(unpack(keys))
  end
end
local function env_set(tbl)
  _G.assert((nil ~= tbl), "Missing argument tbl on env.fnl:266")
  validate(tbl, schema)
  return deepcopy(pre_process(tbl, pre_schema), ENV)
end
return {get = env_get, set = env_set, conf = env_get_conf}