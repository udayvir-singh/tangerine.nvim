local modules = {dp = "tangerine.output.display", log = "tangerine.output.logger", err = "tangerine.output.error"}
local function _1_(_241, _242)
  return require(modules[_242])
end
return setmetatable({}, {__index = _1_})
