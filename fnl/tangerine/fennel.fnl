; ABOUT:
;   Configures fennel and provides functions to load fennel bins.
;
; DEPENDS:
; (-load) utils[env]
; (-load) fennel[*]
(local env (require :tangerine.utils.env))

(local fennel {})

;; -------------------- ;;
;;        Utils         ;;
;; -------------------- ;;
(lambda format-path [path ext macro-path?]
  "converts 'path' into usable fennel.path."
  (.. path :?. ext ";" path :?/init. ext
      (if macro-path? (.. ";" path :?/init-macros.fnl) "")))

(lambda get-rtp [ext macro-path?]
  "get rtp entries containing /fnl formatted for fennel.path or package.path."
  (local out [(format-path (env.get :source) ext macro-path?)])
  (let [rtp (.. vim.o.runtimepath ",")]
    (each [entry (rtp:gmatch "(.-),")]
          (local path (.. entry "/fnl/"))
          (if (= 1 (vim.fn.isdirectory path))
              (table.insert out (format-path path ext macro-path?)))))
  (table.concat out ";"))


;; -------------------- ;;
;;       Fennel         ;;
;; -------------------- ;;
(lambda fennel.load [?version]
  "require fennel of 'version' and setups it paths."
  (let [version (or ?version (env.get :compiler :version))
        fennel  (require (.. :tangerine.fennel. version))]
    ;; setup paths
    (tset fennel :path       (get-rtp :fnl false))
    (tset fennel :macro-path (get-rtp :fnl true))
    :return fennel))

(local orig { :path package.path }) ;; cache original package.path

(lambda fennel.patch-path []
  "appends fennel source and target dirs into package.path."
  (let [targetdirs (get-rtp :lua false)
        sourcedirs (format-path (env.get :target) :lua false)]
    (tset package :path (.. orig.path ";" targetdirs ";" sourcedirs))
    :return true))


:return fennel
