; DEPENDS:
; (get-rtps load-fennel): tangerine.utils.env
; (load-fennel): tangerine.fennel.x-y-z
(local env (require :tangerine.utils.env))

;; -------------------- ;;
;;        Utils         ;;
;; -------------------- ;;
(lambda format-path [path ext]
  "converts 'path' into usable fennel.path."
  (.. path :?. ext ";" path :?/init. ext))

(lambda get-rtp [ext]
  "get rtp entries containing /fnl formatted for fennel.path or package.path."
  (local out [(format-path (env.get :source) ext)])
  (let [rtp (.. vim.o.runtimepath ",")]
       (each [entry (rtp:gmatch "(.-),")]
             (local path (.. entry "/fnl"))
             (if (= 1 (vim.fn.isdirectory path))
                 (table.insert out (format-path path ext)))))
  (table.concat out ";"))


;; -------------------- ;;
;;       Fennel         ;;
;; -------------------- ;;
(fn load-fennel []
  "require fennel and setups it opts."
  (let [version (env.get :compiler :version)
        fennel  (require (.. :tangerine.fennel. version))
        path    (get-rtp :fnl)]
       (set fennel.path path)
       fennel))

(fn patch-package-path []
  "appends fennel source dirs in package.path."
  (let [path (get-rtp :lua)]
       (set package.path (.. path ";" package.path))
       true))

:return {
  :load load-fennel
  :     patch-package-path 
}
