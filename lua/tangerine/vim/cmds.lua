local prefix = "lua tangerine.api."
local function odd_3f(int)
  _G.assert((nil ~= int), "Missing argument int on fnl/tangerine/vim/cmds.fnl:11")
  return (0 ~= (int % 2))
end
local function parse_opts(opts)
  _G.assert((nil ~= opts), "Missing argument opts on fnl/tangerine/vim/cmds.fnl:15")
  local out = ""
  for idx, val in ipairs(opts) do
    if odd_3f(idx) then
      out = (out .. "-" .. val)
    elseif "else" then
      out = (out .. "=" .. val .. " ")
    else
    end
  end
  return out
end
local function command_21(cmd, func, _3fargs, opts)
  _G.assert((nil ~= opts), "Missing argument opts on fnl/tangerine/vim/cmds.fnl:25")
  _G.assert((nil ~= func), "Missing argument func on fnl/tangerine/vim/cmds.fnl:25")
  _G.assert((nil ~= cmd), "Missing argument cmd on fnl/tangerine/vim/cmds.fnl:25")
  local opts0 = parse_opts(opts)
  return vim.cmd(("command!" .. " " .. opts0 .. " " .. cmd .. " " .. prefix .. func .. (_3fargs or "()")))
end
local bang_3f = "{ force=('<bang>' == '!' or nil) }"
command_21("FnlCompileBuffer", "compile.buffer", nil, {})
command_21("FnlCompile", "compile.all", bang_3f, {"bang"})
command_21("FnlClean", "clean.orphaned", bang_3f, {"bang"})
command_21("Fnl", "eval.string", "(<q-args>)", {"nargs", "*"})
command_21("FnlFile", "eval.file", "(<q-args>)", {"nargs", 1, "complete", "file"})
command_21("FnlBuffer", "eval.buffer", "(<line1>, <line2>)", {"range", "%"})
command_21("FnlPeak", "eval.peak", "(<line1>, <line2>)", {"range", "%"})
command_21("FnlWinKill", "win.killall", nil, {})
command_21("FnlWinClose", "win.close", nil, {})
command_21("FnlWinResize", "win.resize", "(<args>)", {"nargs", "1"})
command_21("FnlWinNext", "win.next", "(<args>)", {"nargs", "?"})
command_21("FnlWinPrev", "win.prev", "(<args>)", {"nargs", "?"})
command_21("FnlGotoOutput", "goto_output", nil, {})
return {true}
