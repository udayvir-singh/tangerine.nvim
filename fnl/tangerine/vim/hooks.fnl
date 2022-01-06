; DEPENDS:
; (augroup) _G.tangerine
; :onload   tangerine.utils.env
(local prefix "lua tangerine.api.")
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
(local pat (.. source "*.fnl" "," vimrc))

:augroups {
  :onload #(augroup :tangerine-onload
                    [[:VimEnter "*"]     prefix "compile.all()"])

  :onsave #(augroup :tangerine-onsave
                    [[:BufWritePost pat] prefix "compile.all()"])
}
