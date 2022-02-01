; DEPENDS:
; (get-rtps load-fennel patch-): tangerine.utils.env
; (load-fennel): tangerine.fennel.x-y-z
(local env (require :tangerine.utils.env))

;; -------------------- ;;
;;        Utils         ;;
;; -------------------- ;;
(lambda format-path [path ext ?macro]
  "converts 'path' into usable fennel.path."
  (.. path :?. ext ";" path :?/init. ext
      (if ?macro (.. ";" path :?/init-macros.fnl) "")))

(lambda get-rtp [ext ?macro]
  "get rtp entries containing /fnl formatted for fennel.path or package.path."
  (local out [(format-path (env.get :source) ext ?macro)])
  (let [rtp (.. vim.o.runtimepath ",")]
       (each [entry (rtp:gmatch "(.-),")]
             (local path (.. entry "/fnl/"))
             (if (= 1 (vim.fn.isdirectory path))
                 (table.insert out (format-path path ext ?macro)))))
  (table.concat out ";"))


;; -------------------- ;;
;;       Fennel         ;;
;; -------------------- ;;
(fn load-fennel [version]
  "require fennel and setups it opts."
  (let [version (or version (env.get :compiler :version))
        fennel  (require (.. :tangerine.fennel. version))]
       (set fennel.path (get-rtp :fnl false))
       (set fennel.macro-path (get-rtp :fnl true))
       fennel))

(local original-path [package.path])

(fn patch-package-path []
  "appends fennel source dirs in package.path."
  (let [path (get-rtp :lua)
        target (format-path (env.get :target) :lua)]
       (set package.path (.. target ";" path ";" (. original-path 1)))
       true))

:return {
  :load load-fennel
  :     patch-package-path 
}
