; ABOUT:
;   Provides extra utils and syntactic sugar over main test library.
;
; DEPENDS:
; (call)        test
; (float-lines) utils[window]
(local test   `(require :tangerine.test))
(local window `(require :tangerine.utils.window))

(local M {})

;; -------------------- ;;
;;        Utils         ;;
;; -------------------- ;;
(lambda call [func ...]
  "loads 'func' from runner, calls it with {...}."
  `((. ,test ,func) ,...))


;; -------------------- ;;
;;       Wrappers       ;;
;; -------------------- ;;
(lambda M.test [name ...]
  (call :test name `(fn [] ,...)))

(lambda M.it [title ...]
  (call :it title `(fn [] ,...)))

(lambda M.asrt [name cond ?opts]
  (call :asrt name cond ?opts))

(lambda M.eql [lhs rhs]
  (call :eql lhs rhs
        (if (list? lhs) (tostring lhs))))

(lambda M.fnd [lhs rhs]
  (call :fnd lhs rhs
        (if (list? lhs) (tostring lhs))))

(lambda M.err [lhs rhs]
  (call :err `(fn [] ,lhs) rhs (tostring lhs)))

(lambda M.ext [path]
  (call :ext path))


;; -------------------- ;;
;;        Module        ;;
;; -------------------- ;;
(lambda M.module [name mod]
  "defines test for module 'mod' and assigns return value to 'name'."
  `(local ,name
     (it ,(.. "require " (string.gsub mod "^.+[%./]" ""))
         (require ,mod))))


;; -------------------- ;;
;;        Window        ;;
;; -------------------- ;;
(lambda M.with-buf [[name get* set*] ...]
  "creates new buffer and auto closes it after executing {...}."
  `(let [opt# {:relative "editor" :bufpos [0 0] :width 80 :height 24}
         buf# (vim.fn.bufadd ,name)
         win# (vim.api.nvim_open_win buf# true opt#)]
     ; win getter and setter
     (local ,get* #(vim.api.nvim_buf_get_lines buf# 0 -1 true))
     (local ,set* #(vim.api.nvim_buf_set_lines buf# 0 -1 true $1))
     ; exec {...}
     (local (ok# res#) (pcall (fn [] ,...)))
     ; close window
     (vim.api.nvim_win_close win# true)
     (vim.api.nvim_buf_delete buf# {:force true})
     ; bubble
     (if (not ok#) (error res#))
     :return true))


(lambda M.float-lines []
  "returns lines in current floating window, auto closes it afterwards."
  `(let [stack# (. ,window :_stack_)]
     (var out# nil)
     ; search stack
     (each [i# [w#] (ipairs stack#)]
       (when (= w# (vim.api.nvim_get_current_win))
         (set out# (vim.api.nvim_buf_get_lines 0 0 -1 true))
         ; close window
         (vim.api.nvim_win_close w# true)
         (lua :break)))
     ; bubble
     (assert out# "current window is not a float.")
     :return
     (table.concat out# "\n")))


:return M
