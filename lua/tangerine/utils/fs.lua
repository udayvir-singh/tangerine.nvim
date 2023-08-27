local fs = {}
fs["readable?"] = function(path)
  _G.assert((nil ~= path), "Missing argument path on fnl/tangerine/utils/fs.fnl:8")
  return (1 == vim.fn.filereadable(path))
end
fs.read = function(path)
  _G.assert((nil ~= path), "Missing argument path on fnl/tangerine/utils/fs.fnl:12")
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
    return file:read("*a")
  end
  return close_handlers_8_auto(_G.xpcall(_2_, (package.loaded.fennel or debug).traceback))
end
fs.write = function(path, content)
  _G.assert((nil ~= content), "Missing argument content on fnl/tangerine/utils/fs.fnl:17")
  _G.assert((nil ~= path), "Missing argument path on fnl/tangerine/utils/fs.fnl:17")
  local dir
  if (_G.jit.os == "Windows") then
    dir = path:match("(.*[/\\])")
  else
    dir = path:match("(.*/)")
  end
  if (0 == vim.fn.isdirectory(dir)) then
    vim.fn.mkdir(dir, "p")
  else
  end
  local file = assert(io.open(path, "w"))
  local function close_handlers_8_auto(ok_9_auto, ...)
    file:close()
    if ok_9_auto then
      return ...
    else
      return error(..., 0)
    end
  end
  local function _6_()
    return file:write(content)
  end
  return close_handlers_8_auto(_G.xpcall(_6_, (package.loaded.fennel or debug).traceback))
end
fs.remove = function(path, ...)
  _G.assert((nil ~= path), "Missing argument path on fnl/tangerine/utils/fs.fnl:27")
  for _, path0 in ipairs({path, ...}) do
    for _0, file in ipairs(vim.fn.glob((path0 .. "/*"), 0, 1)) do
      os.remove(file)
    end
    os.remove(path0)
  end
  return true
end
return fs
