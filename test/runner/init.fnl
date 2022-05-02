; ABOUT:
;   Provides functions to test neovim plugins.
;
; DEPENDS:
; (asrt) fennel
(local fennel (require :tangerine.fennel.latest))

(local M {})

;; -------------------- ;;
;;        Utils         ;;
;; -------------------- ;;
(lambda indent [str level]
  "appends 'level' of indentation to 'str'."
  (local spaces (string.rep " " level))
  (pick-values 1
    (-> (.. spaces str)
        (string.gsub "\n([^\n])" (.. "\n" spaces "%1")))))

(lambda remstack [err]
  "remove stack traceback from module 'err'."
  (or (err:match "module.-not found") err))

(lambda remln [err]
  "removes line number info from 'err'."
  (err:gsub "^%g+:[0-9]+: " ""))

(lambda parse-err [err level]
  "sterilizes 'err' into better readable form."
  (indent (-> err (remln) (remstack)) level))


;; -------------------- ;;
;;        Logger        ;;
;; -------------------- ;;
(local UI? (< 0 (# (vim.api.nvim_list_uis))))

(lambda colorize [str]
  "convert [rg0] in 'str' to valid color sequences."
  (if UI?
    (str:gsub "%[[rg0].-]" "")
    (-> str
      (string.gsub "%[r(.-)]" "\27[%1;31m")
      (string.gsub "%[g(.-)]" "\27[%1;32m")
      (string.gsub "%[0]"        "\27[0m"))))

(lambda log [str ...]
  "prints 'str' to vim output buffer or stdout."
  (local msg (colorize (table.concat [str ...] " ")))
  (if UI?
    (print msg)
    (do (io.write msg "\n")
        (io.close))))

(lambda success [title]
  "prints success message for 'title'."
  (log "   [g1]==>[0]" title))

(lambda failure [title err]
  "prints failure message for 'title' with 'err'."
  (log (.. "   [r1]xxx[0] " title "\n[r]" (parse-err err 7) "[0]\n")))


;; -------------------- ;;
;;        Runner        ;;
;; -------------------- ;;
(local stat {})

(lambda M.test [name func]
  "defines test with 'name' for handler 'func'."
  (set stat.pass true) ; reset stat
  (log ":: TEST" name)
  :exec
  (xpcall func
    (fn [err]
      (set stat.pass false)
      (log (.. "   [r1]INLINE ERROR:[0]\n[r]" (parse-err err 5) "[0]"))))
  :logs
  (if stat.pass
    (log "[g1]PASS[0]")
    (do (log "[r1]FAIL[0]")
        (if (not UI?) (vim.cmd :cq)))))


(lambda M.it [title func]
  "defines step of 'title' for handler 'func'."
  (local (ok? res) (pcall func))
  :logs
  (if ok?
    (success title)
    (do (failure title res)
        (set stat.pass false)))
  :return res)


;; -------------------- ;;
;;        Assert        ;;
;; -------------------- ;;
(lambda serialize [val]
  "converts 'val' into human readable form."
  (if (= :string (type val))
      (.. "\"" (val:gsub "\n" "\n   ") "\"")
      :else
      (fennel.view val)))


(lambda M.asrt [name cond ?opts]
  "defines assertion on 'cond', sends error msg of 'name'."
  ;; opts { :items string :scope string }
  (local opts (or ?opts {}))
  ; parse items
  (var items "")
  (each [_ val (ipairs (or opts.items []))]
        (set items (.. items "\n* " (serialize val))))
  ; parse scope
  (local scope
    (if opts.scope (.. opts.scope "\n---\n") ""))
  ; assert
  (assert cond
    (.. scope "ASSERTION FOR " name " FAILED" items)))


(lambda M.eql [lhs rhs ?scope]
  "asserts if 'lhs' is equal to 'rhs'."
  (M.asrt :EQUALITY
          (vim.deep_equal lhs rhs)
          {:items [lhs rhs] :scope ?scope}))


(lambda M.fnd [str pat ?scope]
  "asserts if pattern 'pat' matches 'str'."
  (M.asrt :MATCHING
          (or (string.find str pat) false)
          {:items [str pat] :scope ?scope}))


(lambda M.err [func xs ?scope]
  "asserts if 'func' returns an error that matches 'xs'."
  (local (ok? res) (pcall func))
  (M.asrt :ERROR
          (and (not ok?) (or (string.find res xs) false))
          {:items [res xs] :scope ?scope}))


(lambda M.ext [path]
  "asserts if 'path' is readable."
  (M.asrt :READABILITY
          (= 1 (vim.fn.file_readable (vim.fn.expand path)))
          {:items [path]}))


:return M
