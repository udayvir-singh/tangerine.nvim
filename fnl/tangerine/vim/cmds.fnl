; ABOUT:
;   Defines tangerine's default vim commands.
;
; DEPENDS:
; (command!) api[init] -> _G.tangerine.api
(local prefix "lua tangerine.api.")

;; -------------------- ;;
;;        Utils         ;;
;; -------------------- ;;
(lambda odd? [int]
  "checks if 'int' is mathematically of odd parity ;}"
  (not= 0 (% int 2)))

(lambda parse-opts [opts]
  "converts list of 'opts' into string of valid command-opts."
  (var out "")
  (each [idx val (ipairs opts)]
        (if (odd? idx)
            (set out (.. out "-" val))
            :else 
            (set out (.. out "=" val " "))))
  out)

(lambda command! [cmd func ?args opts]
  "defines a user command, that runs api.'func' with 'args'."
  (let [opts (parse-opts opts)]
       (vim.cmd (.. :command! " " opts " " cmd " " prefix func (or ?args "()")))))


;; -------------------- ;;
;;         CMDS         ;;
;; -------------------- ;;
(local bang? "{ force=('<bang>' == '!' or nil) }")


; COMMAND |       name       |     func     |  args  |  opts |
(command! :FnlCompileBuffer  "compile.buffer"  nil         [])
(command! :FnlCompile        "compile.all"     bang?  [:bang])
(command! :FnlClean          "clean.orphaned"  bang?  [:bang])


(command! :Fnl        "eval.string"          "(<q-args>)"  [:nargs "*"])
(command! :FnlFile    "eval.file"            "(<q-args>)"  [:nargs 1 :complete "file"])
(command! :FnlBuffer  "eval.buffer"  "(<line1>, <line2>)"  [:range "%"])
(command! :FnlPeak    "eval.peak"    "(<line1>, <line2>)"  [:range "%"])


(command! :FnlWinKill    "win.killall"  nil                   [])
(command! :FnlWinClose   "win.close"    nil                   [])
(command! :FnlWinResize  "win.resize"   "(<args>)"  [:nargs "1"])
(command! :FnlWinNext    "win.next"     "(<args>)"  [:nargs "?"])
(command! :FnlWinPrev    "win.prev"     "(<args>)"  [:nargs "?"])


(command! :FnlGotoOutput  "goto_output"  nil  [])


:return [true]
