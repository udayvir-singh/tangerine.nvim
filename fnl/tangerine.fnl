; DEPENDS:
; (setup)      tangerine.fennel
; (load-vimrc) tangerine.utils.fs
; (load-api)   tangerine.api
; (load-hooks) tangerine.vim.hooks
; (load-cmds)  tangerine.vim.cmds
; (setup load-hooks load-vimrc) tangerine.utils.env
(local fennel (require :tangerine.fennel))
(local { : env : fs } (require :tangerine.utils))

(local require-api   #(require :tangerine.api))
(local require-cmds  #(require :tangerine.vim.cmds))
(local require-hooks #(require :tangerine.vim.hooks))

(local vimrc-module "tangerine_vimrc")

;; -------------------- ;;
;;        Utils         ;;
;; -------------------- ;;
(lambda safe-require [module]
  (let [(ok? out) (pcall require module)] 
       (if (not ok?)
           (print out)
           :else out)))

;; -------------------- ;;
;;       Loaders        ;;
;; -------------------- ;;
(lambda load-vimrc []
  (let [target (env.get :target)
        path   (.. target vimrc-module ".lua")]
        (if (fs.readable? path)
            (safe-require vimrc-module))))

(lambda load-api []
  (let [api (require-api)]
       (global tangerine {:api api :fennel fennel.load})))

(lambda load-cmds []
  (require-cmds))

(lambda load-hooks []
  (let [hooks (require-hooks)]
       (each [_ hook (ipairs (env.get :compiler :hooks))]
             :call ((. hooks hook)))))

;; -------------------- ;;
;;         MAIN         ;;
;; -------------------- ;;
(lambda setup [config]
  (env.set config)
  (fennel.patch-package-path) 
  (load-api)
  (load-cmds)
  (load-hooks)
  (load-vimrc)
  true)

{
  : setup
}
