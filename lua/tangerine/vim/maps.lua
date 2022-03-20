local env = require("tangerine.utils.env")
local _local_1_ = env.get("keymaps")
local eval_buffer = _local_1_["eval_buffer"]
local peak_buffer = _local_1_["peak_buffer"]
local goto_output = _local_1_["goto_output"]
local function nmap_21(lhs, rhs)
  _G.assert((nil ~= rhs), "Missing argument rhs on fnl/tangerine/vim/maps.fnl:18")
  _G.assert((nil ~= lhs), "Missing argument lhs on fnl/tangerine/vim/maps.fnl:18")
  return vim.api.nvim_set_keymap("n", lhs, (":" .. rhs .. "<CR>"), {noremap = true, silent = true})
end
local function vmap_21(lhs, rhs)
  _G.assert((nil ~= rhs), "Missing argument rhs on fnl/tangerine/vim/maps.fnl:21")
  _G.assert((nil ~= lhs), "Missing argument lhs on fnl/tangerine/vim/maps.fnl:21")
  return vim.api.nvim_set_keymap("v", lhs, (":'<,'>" .. rhs .. "<CR>"), {noremap = true, silent = true})
end
nmap_21(eval_buffer, "FnlBuffer")
vmap_21(eval_buffer, "FnlBuffer")
nmap_21(peak_buffer, "FnlPeak")
vmap_21(peak_buffer, "FnlPeak")
nmap_21(goto_output, "FnlGotoOutput")
return {true}
