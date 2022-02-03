; DEPENDS:
; (base-hooks)  _G.tangerine
; (base-hooks)  tangerine.utils.env
; :onsave       tangerine.utils.env
(local env (require :tangerine.utils.env))

;; -------------------- ;;
;;        Utils         ;;
;; -------------------- ;;
(lambda exec [...]
  (vim.cmd (table.concat [...] " ")))

(lambda parse-autocmd [cmds]
  (let [groups (table.concat (. cmds 1) " ")]
       (table.remove cmds 1)
       (values :au groups (table.concat cmds " "))))

(lambda augroup [name ...]
  (exec :augroup name)
  (exec :au!)
  (each [idx val (ipairs [...])]
        (exec (parse-autocmd val)))
  (exec :augroup "END")
  :return true)

;; -------------------- ;;
;;         AUGS         ;;
;; -------------------- ;;
(local source (env.get :source))
(local vimrc  (env.get :vimrc))
(local pat    (.. source "*.fnl" "," vimrc))

(fn base-hooks []
  (let [clean? (env.get :compiler :clean)]
       (if clean?
           (_G.tangerine.api.clean.orphaned))
       (_G.tangerine.api.compile.all)))

(local lua-base 
       "lua :require 'tangerine.vim.hooks'.run()")

:augroups {
  :onload #(augroup :tangerine-onload [[:VimEnter "*"]]     lua-base)
  :onsave #(augroup :tangerine-onsave [[:BufWritePost pat]] lua-base)
  :oninit #(base-hooks)

  :run base-hooks
}
