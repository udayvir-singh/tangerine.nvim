;; -------------------- ;;
;;        Utils         ;;
;; -------------------- ;;
(local config-dir (vim.fn.stdpath :config))

(lambda endswith [str args]
  "checks if 'str' endswith one of arr::'args'."
  (each [i v (pairs args)]
        (if (vim.endswith str v)
            (lua "return true"))))

(lambda resolve [path]
  "resolves 'path' to POSIX complaint path."
  (let [out (vim.fn.resolve (vim.fn.expand path))]
       (if (endswith out ["/" ".fnl" ".lua"])
           out
           (.. out "/"))))


(lambda deepcopy [tbl1 tbl2]
  "deep copy 'tbl1' onto 'tbl2'."
  (each [key val (pairs tbl1)]
        (if (= (type val) :table)
            (deepcopy val (. tbl2 key))
            (tset tbl2 key val))))


;; -------------------- ;;
;;        Schema        ;;
;; -------------------- ;;
(local schema {
  :source "string"
  :target "string"
  :vimrc  "string"
  :compiler {
    :verbose "boolean"
    :clean   "boolean"
    :force   "boolean"
    :version [:oneof ["latest" "1-0-0" "0-10-0" "0-9-2"]]
    :hooks   [:array ["onsave" "onload" "oninit"]]
  }
  :diagnostic {
      :hl_normal  "string"
      :hl_virtual "string"
      :timeout    "number"
  }
})

(local pre-schema {
  :source resolve
  :target resolve
  :vimrc  resolve
  :compiler nil
  :diagnostic nil
})

(local ENV {
  :vimrc  (resolve (.. config-dir "/init.fnl"))
  :source (resolve (.. config-dir "/fnl/"))
  :target (resolve (.. config-dir "/lua/"))
  :compiler {
    :verbose true
    :clean   true
    :force   false
    :version "latest"           
    :hooks   []
  }
  :diagnostic {
      :hi_normal  "DiagnosticError"
      :hi_virtual "DiagnosticVirtualTextError"
      :timeout    10
  }
})


;; -------------------- ;;
;;      Validation      ;;
;; -------------------- ;;
(lambda validate-type [name val scm]
  "checks if 'scm' == typeof 'val', else throws an error."
  (if (not= (type val) scm)
    (error 
      (.. "[tangerine]: bad argument in 'setup()' to " name ", " scm " expected got " (type val) "."))))

(lambda validate-oneof [name val scm]
  "checks if 'val' is member of 'scm', else throws error."
  (validate-type name val :string)
  (when (not (vim.tbl_contains scm val))
        (local tbl (table.concat scm "' '"))
        (error
          (.. "[tangerine]: bad argument in 'setup()' to " name " expected to be one-of ['" tbl "']."))))

(lambda validate-array [name array scm]
  "checks if members of 'array' are present in 'scm'."
  (validate-type name array :table)
  (each [_ val (ipairs array)]
        (validate-oneof name val scm)))

(lambda validate [tbl schema]
  (each [key val (pairs tbl)]
        (local scm (. schema key))
        (if (not (. schema key))
            (error (.. "[tangerine]: invalid key " key)))
        (if 
            (= :string (type scm)) (validate-type  key val scm)
            (= :oneof  (?. scm 1)) (validate-oneof key val (. scm 2))
            (= :array  (?. scm 1)) (validate-array key val (. scm 2))
        ; recursive validation
        (= :table  (type scm))
        (validate val scm))))

(lambda pre-process [tbl schema]
  (each [key val (pairs tbl)]
        (local pre (. schema key))
        (if (= (type pre) :table)
            (pre-process val pre)
            (not= (type pre) :nil)
            (tset tbl key (pre val))))
  tbl)


;; -------------------- ;;
;;        Getters       ;;
;; -------------------- ;;
(lambda rget [tbl args]
  "recursively gets value in 'tbl' from list of args."
  (if (= 0 (# args)) tbl
  (let [current (?. tbl (. args 1))]
       (table.remove args 1)
       (if current
           (rget current args)))))

(lambda env-get [...]
  "getter for table 'config'."
  (rget ENV [...]))


;; -------------------- ;;
;;        Setters       ;;
;; -------------------- ;;
(lambda env-set [tbl]
  "setter for table 'config'."
  (validate tbl schema)
  (pre-process tbl pre-schema)
  (deepcopy tbl ENV))

:return {
  :get env-get
  :set env-set
}
