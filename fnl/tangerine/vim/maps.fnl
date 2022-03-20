; ABOUT:
;   Defines mappings for vim[cmds] as described in ENV.
;
; DEPENDS:
; (nmap! vmap!) vim[cmds]
; (nmap! vmap!) utils[env]
(local env (require :tangerine.utils.env))

(local {
  : eval_buffer
  : peak_buffer
  : goto_output
} (env.get :keymaps))

;; -------------------- ;;
;;        Utils         ;;
;; -------------------- ;;
(lambda nmap! [lhs rhs]
  (vim.api.nvim_set_keymap :n lhs (.. ":" rhs "<CR>") {:noremap true :silent true}))

(lambda vmap! [lhs rhs]
  (vim.api.nvim_set_keymap :v lhs (.. ":'<,'>" rhs "<CR>") {:noremap true :silent true}))


;; -------------------- ;;
;;         MAPS         ;;
;; -------------------- ;;
(nmap! eval_buffer :FnlBuffer)
(vmap! eval_buffer :FnlBuffer)

(nmap! peak_buffer :FnlPeak)
(vmap! peak_buffer :FnlPeak)

(nmap! goto_output :FnlGotoOutput)


[true]
