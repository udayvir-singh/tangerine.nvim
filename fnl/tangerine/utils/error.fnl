; DEPENDS:
; (send)  tangerine.utils.env
(local env (require :tangerine.utils.env))

(local err {})

;; -------------------- ;;
;;       Parsing        ;;
;; -------------------- ;;
(lambda err.compile? [msg]
  "checks if 'msg' is an compile-time error."
  (if (or (msg:match "^Parse error.*:([0-9]+)")
          (msg:match "^Compile error.*:([0-9]+)")) true false))

(lambda err.parse [msg]
  "parses raw error 'msg' to (line msg) values."
  (let [lines (vim.split msg "\n")
        line  (string.match (. lines 1) ".*:([0-9]+)")
        msg   (string.gsub  (. lines 2) "^ +" "")]
    (values (tonumber line) msg)))

;; -------------------- ;;
;;      Diagnostic      ;;
;; -------------------- ;;
(local timer {:t (vim.loop.new_timer)})

(lambda err.clear []
  (let [namespace  (vim.api.nvim_create_namespace :tangerine)]
       (vim.api.nvim_buf_clear_namespace 0 namespace 0 -1)))

(lambda err.send [line msg]
  "create diagnostic error on linenumber 'line' with virtual text of 'msg'."
  (let [line       (- line 1)
        msg        (.. ";; " msg)
        hi_normal  (env.get :diagnostic :hi_normal)
        hi_virtual (env.get :diagnostic :hi_virtual)
        timeout    (env.get :diagnostic :timeout)
        timer      timer.t
        namespace  (vim.api.nvim_create_namespace :tangerine)]
    (vim.api.nvim_buf_add_highlight 0 namespace hi_normal line 0 -1)

    (vim.api.nvim_buf_set_extmark 0 namespace line 0 {
        :virt_text [[msg hi_virtual]]
    })

    (timer:start (* 1000 timeout) 0
                 (vim.schedule_wrap #(vim.api.nvim_buf_clear_namespace 0 namespace 0 -1)))
    true))

err
