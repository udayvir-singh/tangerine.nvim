; DEPENDS:
; (command!) _G.tangerine
(local prefix "lua tangerine.api.")

;; -------------------- ;;
;;        Utils         ;;
;; -------------------- ;;
(lambda odd? [int]
  (not= 0 (% int 2)))

(lambda parse-opts [opts]
  (var out "")
  (each [idx val (ipairs opts)]
        (if (odd? idx)
            (set out (.. out "-" val))
            :else 
            (set out (.. out "=" val " "))))
  out)

(lambda command! [name cmd opts]
  (let [opts (parse-opts opts)]
       (vim.cmd (.. :command! " " opts " " name " " prefix cmd))))

;; -------------------- ;;
;;         CMDS         ;;
;; -------------------- ;;
(command! :FnlCompile       "compile.all()"          [])
(command! :FnlCompileBuffer "compile.buffer()"       [])

(command! :FnlBuffer "eval.buffer()"                       [])
(command! :Fnl       "eval.string(<q-args>)"               [:nargs "*"])
(command! :FnlFile   "eval.file(<q-args>)"                 [:nargs 1 :complete "file"])
(command! :FnlRange  "eval.range(<line1>,<line2>,<count>)" [:range 0])

(command! :FnlClean "clean.orphaned()" [])

(command! :FnlGotoOutput "goto_output()" [])

[true]
