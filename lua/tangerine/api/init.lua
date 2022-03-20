local prefix = "tangerine."
local function lazy(module, func)
  _G.assert((nil ~= func), "Missing argument func on fnl/tangerine/api/init.fnl:11")
  _G.assert((nil ~= module), "Missing argument module on fnl/tangerine/api/init.fnl:11")
  local function _1_(...)
    return require((prefix .. module))[func](...)
  end
  return _1_
end
return {eval = {string = lazy("api.eval", "string"), file = lazy("api.eval", "file"), buffer = lazy("api.eval", "buffer"), peak = lazy("api.eval", "peak")}, compile = {string = lazy("api.compile", "string"), file = lazy("api.compile", "file"), dir = lazy("api.compile", "dir"), buffer = lazy("api.compile", "buffer"), vimrc = lazy("api.compile", "vimrc"), rtp = lazy("api.compile", "rtp"), all = lazy("api.compile", "all")}, clean = {target = lazy("api.clean", "target"), rtp = lazy("api.clean", "rtp"), orphaned = lazy("api.clean", "orphaned")}, win = {next = lazy("utils.window", "next"), prev = lazy("utils.window", "prev"), close = lazy("utils.window", "close"), resize = lazy("utils.window", "resize"), killall = lazy("utils.window", "killall")}, goto_output = lazy("utils.path", "goto-output"), serialize = lazy("output.display", "serialize")}
