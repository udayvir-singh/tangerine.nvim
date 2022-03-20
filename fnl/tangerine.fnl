; DEPENDS:
; (setup) api
; (setup) fennel
; (setup) vim[*]
; ALL()   utils[env]
(local env    (require :tangerine.utils.env))
(local api    (require :tangerine.api))
(local fennel (require :tangerine.fennel))

;; -------------------- ;;
;;         MAIN         ;;
;; -------------------- ;;
(lambda load-vimrc []
  "safely require vimrc if readable."
  (let [module "tangerine_vimrc"
        path   (.. (env.get :target) module ".lua")]
    (if (= 1 (vim.fn.filereadable path))
        (xpcall #(require module)
                #(print (.. "[tangerine]: ERROR LOADING VIMRC...\n" $1))))))

(lambda load-hooks [hooks]
  "loads hooks that are present in ENV from table of 'hooks'."
  (each [_ hook (ipairs (env.get :compiler :hooks))]
        :call ((. hooks hook))))

(lambda setup [config]
  "main entry point for tangerine, setups required configuration."
  ; setup ENV and package.path
  (env.set config)
  (fennel.patch-path)
  ; setup tangerine.api
  (global tangerine {
    :api    api
    :fennel fennel.load
  })
  ; load vim config
  (require :tangerine.vim.cmds)
  (require :tangerine.vim.maps)
  (load-hooks (require :tangerine.vim.hooks))
  ; load vimrc
  (load-vimrc)
  :return true)


:return {
  : setup 
}
