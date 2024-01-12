; ABOUT:
;   Displays serialized evaluation results.
;
; DEPENDS:
; (show)        utils[window]
; (show)        utils[srlize]
; (show format) utils[env]
(local {: env : win : srl} (require :tangerine.utils))
(local dp {})

;; -------------------- ;;
;;        UTILS         ;;
;; -------------------- ;;
(lambda print [str]
  "wrapper around print that only works if UI is available."
  (if (or _G.has_ui (< 0 (# (vim.api.nvim_list_uis))))
      (vim.api.nvim_echo [[str]] false {})))

(lambda format [code]
  "runs formatter on lua 'code' as defined in ENV."
  (let [luafmt ((env.get :eval :luafmt))]
    (if (= 0 (vim.fn.executable (or (. luafmt 1) "")))
        (do code)
        (string.gsub (vim.fn.system luafmt code) "\n$" ""))))


;; -------------------- ;;
;;        OUTPUT        ;;
;; -------------------- ;;
(lambda dp.show [res opts]
  "displays serialized 'res' inside float if opts.float = true."
  ;; opts { :float boolean }
  (if (= 0 (# res))
      (lua :return))
  (local out (srl (unpack res)))
  (if (env.conf opts [:eval :float])
      (win.set-float out :fennel (env.get :highlight :float))
      (print out))
  :return true)

(lambda dp.show-lua [code opts]
  "displays lua 'code' inside float if opts.float = true."
  ;; opts { :float boolean }
  (local out (format code))
  (if (env.conf opts [:eval :float])
      (win.set-float out :lua (env.get :highlight :float))
      (print out))
  :return true)

; EXAMPLES:
; (dp.show [(tangerine.fennel)] {:float false})
; (dp.show-lua "return {foo={baz='string', bar=variable}}" {:float true})


:return dp
