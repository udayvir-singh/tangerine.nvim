; ABOUT:
;   Sends headache of errors made by devs' to the users.
;
; DEPENDS:
; (err.*) utils[env]
; (float) utils[window]
(local env (require :tangerine.utils.env))
(local win (require :tangerine.utils.window))
(local err {})

(local hl-errors  (env.get :highlight :errors))

;; -------------------- ;;
;;       PARSING        ;;
;; -------------------- ;;
(fn number? [int]
  "checks if 'int' is of number type."
  (= (type int) :number))

(fn toboolean [x]
  "converts 'x' to a boolean based on it truthiness."
  (if x true false))

(lambda err.compile? [msg ?raw]
  "checks if 'msg' is an compile-time error."
  (local e (if ?raw "[0-9?]+" "[0-9]+"))
  (toboolean
    (or (msg:match (.. "^[%s\t]*Parse error.*:" e))
        (msg:match (.. "^[%s\t]*Compile error.*:" e)))))

(lambda err.parse [msg offset]
  "parses raw error 'msg' to (line shortmsg) values."
  (let [lines (vim.split msg "\n")
        line  (string.match (. lines 1) ".-:([0-9]+)")]
    ; get shortmsg
    (var shortmsg "")
    (each [_ line (ipairs lines)]
      (when (not (err.compile? line true))
        (set shortmsg (line:gsub "^[%s\t]+" ""))
        (lua :break)))
    :return
    (values (+ (tonumber line) offset -1) shortmsg)))


;; -------------------- ;;
;;      DIAGNOSTIC      ;;
;; -------------------- ;;
(local timer {:get (vim.loop.new_timer)})

(lambda err.clear []
  "clears all errors in current namespace."
  (if (not vim.diagnostic)
      (lua :return))
  (let [nspace (vim.api.nvim_create_namespace :tangerine)]
    (vim.diagnostic.reset nspace)
    (vim.api.nvim_buf_clear_namespace 0 nspace 0 -1)))

(lambda err.send [line msg virtual?]
  "create diagnostic error on line-number 'line' with virtual text of 'msg'."
  (if (not vim.diagnostic)
      (lua :return))
  (let [buffer  (vim.api.nvim_get_current_buf)
        timeout (env.get :eval :diagnostic :timeout)
        nspace  (vim.api.nvim_create_namespace :tangerine)]
    :diagnostic
    (vim.diagnostic.set
      nspace
      buffer
      [{
        :lnum line
        :col 0
        :end_col -1
        :severity vim.diagnostic.severity.ERROR
        :source "tangerine"
        :message msg
      }]
      (if virtual?
        {:virtual_text {:spacing 1 :prefix ";;"}}
        {:virtual_text false}))
    :cleanup
    (timer.get:start (* 1000 timeout) 0
                     (vim.schedule_wrap err.clear))
    :return true))


;; -------------------- ;;
;;        ERRORS        ;;
;; -------------------- ;;
(lambda err.soft [msg]
  "echo 'msg' with Error highlight."
  (vim.api.nvim_echo [[msg hl-errors]] false {}))

(lambda err.float [msg]
  "creates floating buffer with Error highlighted 'msg'."
  (win.set-float msg :text hl-errors))

(lambda err.handle [msg opts]
  "handler for fennel errors, meant to be used with xpcall."
  ;; opts { :float boolean :virtual boolean :offset number }
  ; handle diagnostic
  (when (and (err.compile? msg) (number? opts.offset))
    (local (line msg) (err.parse msg opts.offset))
    (err.send line msg
              (env.conf opts [:eval :diagnostic :virtual])))
  ; display error
  (if (env.conf opts [:eval :float])
      (err.float msg)
      (err.soft msg))
  :return true)

; EXAMPLES:
;; (err.handle "Compile error:0\n  Compile error:1\n    example message"
;;             {:float true :virtual true :offset 18})


:return err
