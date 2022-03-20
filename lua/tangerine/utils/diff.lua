local df = {}
df["create-marker"] = function(source)
  _G.assert((nil ~= source), "Missing argument source on fnl/tangerine/utils/diff.fnl:8")
  local base = "-- :fennel:"
  local meta = vim.fn.getftime(source)
  return (base .. meta)
end
df["read-marker"] = function(path)
  _G.assert((nil ~= path), "Missing argument path on fnl/tangerine/utils/diff.fnl:14")
  local file = assert(io.open(path, "r"))
  local function close_handlers_8_auto(ok_9_auto, ...)
    file:close()
    if ok_9_auto then
      return ...
    else
      return error(..., 0)
    end
  end
  local function _2_()
    local bytes = (file:read(21) or "")
    local marker = bytes:match(":fennel:([0-9]+)")
    if marker then
      return tonumber(marker)
    elseif "else" then
      return false
    else
      return nil
    end
  end
  return close_handlers_8_auto(_G.xpcall(_2_, (package.loaded.fennel or debug).traceback))
end
df["stale?"] = function(source, target)
  _G.assert((nil ~= target), "Missing argument target on fnl/tangerine/utils/diff.fnl:23")
  _G.assert((nil ~= source), "Missing argument source on fnl/tangerine/utils/diff.fnl:23")
  if (1 ~= vim.fn.filereadable(target)) then
    return true
  else
  end
  local source_time = vim.fn.getftime(source)
  local marker_time = df["read-marker"](target)
  return (source_time ~= marker_time)
end
return df
