local modules = {p = "tangerine.utils.path", fs = "tangerine.utils.fs", df = "tangerine.utils.diff", env = "tangerine.utils.env", srl = "tangerine.utils.srlize", win = "tangerine.utils.window"}
local function _1_(_241, _242)
  return require(modules[_242])
end
return setmetatable({}, {__index = _1_})
