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
(lambda format-path [path ext macro?]
  "converts 'path' into usable fennel.path."
  (.. path :?. ext ";"
      path :?/ (if macro? "init-macros." "init.") ext))

(lambda get-path [ext macro-path?]
  "formats paths in &rtp and source dir for package and fennel paths."
  (local out [])
  (let [source (env.get :source)
        rtps   (.. vim.o.runtimepath ",")]
    ; relative paths
    (table.insert out (format-path "./" ext macro-path?))
    ; source dirs
    (table.insert out (format-path source ext macro-path?))
    ; rtp dirs
    (each [entry (rtps:gmatch "(.-),")]
          (local glob (vim.fn.glob (.. entry "/fnl/") 0 1))
          (each [_ path (ipairs glob)]
                (table.insert out (format-path path ext macro-path?))))
    :return
    (table.concat out ";")))


;; -------------------- ;;
;;       Fennel         ;;
;; -------------------- ;;
(local original-path package.path)

(lambda fennel.load [?version]
  "require fennel of 'version' and setups it paths."
  (let [version (or ?version (env.get :compiler :version))
        fennel  (require (.. :tangerine.fennel. version))]
    ; setup paths
    (set fennel.path       (get-path :fnl false))
    (set fennel.macro-path (get-path :fnl true))
    :return fennel))

(lambda fennel.patch-path []
  "appends fennel source and target dirs into package.path."
  (let [target (get-path :lua false)
        source (format-path (env.get :target) :lua false)]
    (tset package :path (.. original-path ";" target ";" source))
    :return package.path))


:return fennel
