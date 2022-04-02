local env = require("tangerine.utils.env")
local api = require("tangerine.api")
local fennel = require("tangerine.fennel")
local function load_vimrc()
  local module = "tangerine_vimrc"
  local path = (env.get("target") .. module .. ".lua")
  if (1 == vim.fn.filereadable(path)) then
    local function _1_()
      return require(module)
    end
    local function _2_(_241)
      return print(("[tangerine]: ERROR LOADING VIMRC...\n" .. _241))
    end
    return xpcall(_1_, _2_)
  else
    return nil
  end
end
local function load_hooks(hooks)
  _G.assert((nil ~= hooks), "Missing argument hooks on fnl/tangerine.fnl:21")
  for _, hook in ipairs(env.get("compiler", "hooks")) do
    hooks[hook]()
  end
  return nil
end
local function setup(config)
  _G.assert((nil ~= config), "Missing argument config on fnl/tangerine.fnl:26")
  env.set(config)
  fennel["patch-path"]()
  tangerine = {api = api, fennel = fennel.load}
  require("tangerine.vim.cmds")
  require("tangerine.vim.maps")
  load_hooks(require("tangerine.vim.hooks"))
  load_vimrc()
  return true
end
return {setup = setup}
