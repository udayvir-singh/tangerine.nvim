; ABOUT:
;   Stores environment used by rest of tangerine
;
;   Provides getter and setter so that multiple modules can have shared configurations.

;; -------------------- ;;
;;        UTILS         ;;
;; -------------------- ;;
(local config-dir (vim.fn.stdpath :config))

(lambda endswith [str args]
  "checks if 'str' ends with one of arr::'args'."
  (each [i v (pairs args)]
        (if (vim.endswith str v)
            (lua "return true"))))

(lambda resolve [path]
  "resolves 'path' to POSIX complaint absolute path."
  (let [out (vim.fn.resolve (vim.fn.expand path))]
       (if (endswith out ["/" ".fnl" ".lua"])
           (do out)
           (.. out "/"))))

(lambda rtpdirs [dirs]
  "resolve list of 'dirs' to valid &rtp paths."
  (icollect [_ dir (ipairs dirs)]
    (let [path (resolve dir)]
      (if (vim.startswith path "/")
          (do path)
          (.. config-dir "/" path)))))

(lambda get-type [x]
  "returns type of x, correctly types lists."
  (if (vim.tbl_islist x)
      (do "list")
      (type x)))

(lambda table? [tbl scm]
  "checks if 'tbl' is a valid table and 'scm' is not a list."
  (and (= :table (type tbl))
       (not (vim.tbl_islist scm))))

(lambda deepcopy [tbl1 tbl2]
  "deep copy 'tbl1' onto 'tbl2'."
  (each [key val (pairs tbl1)]
        (if (table? val (. tbl2 key))
            (deepcopy val (. tbl2 key))
            :else
            (tset tbl2 key val))))

(lambda luafmt []
  "returns default lua formatter for ENV."
  (let [exec  (vim.fn.expand "~/.luarocks/bin/lua-format")
        width (vim.api.nvim_win_get_width 0)]
    :return [
      exec
      "--spaces-inside-table-braces"
      "--column-table-limit" (math.floor (/ width 1.7))
      "--column-limit" width
    ]))


;; -------------------- ;;
;;        SCHEMA        ;;
;; -------------------- ;;
(local pre-schema {
  ; "pre processors called before setting ENV"
  :source  resolve
  :target  resolve
  :vimrc   resolve
  :rtpdirs rtpdirs
  :custom  #(icollect [_ [s t] (ipairs $)] [(resolve s) (resolve t)])
  :compiler    nil
  :eval        nil
  :keymaps     nil
  :highlight   nil
})


(local schema {
  ; "type definition for ENV used in validation"
  :source  "string"
  :target  "string"
  :vimrc   "string"
  :rtpdirs [:string]

  :custom [[:string]]

  :compiler {
    :float   "boolean"
    :clean   "boolean"
    :force   "boolean"
    :verbose "boolean"
    :version [:oneof ["latest" "1-5-1" "1-5-0" "1-4-2" "1-4-1" "1-4-0" "1-3-1" "1-3-0" "1-2-1" "1-2-0" "1-1-0" "1-0-0"]]
    :adviser "function"
    :globals [:string]
    :hooks   [:array ["onsave" "onload" "oninit"]]
  }

  :eval {
    :float  "boolean"
    :luafmt "function"
    :diagnostic {
      :virtual "boolean"
      :timeout "number"
    }
  }

  :keymaps {
    :peek_buffer "string"
    :eval_buffer "string"
    :goto_output "string"
    :float {
      :next    "string"
      :prev    "string"
      :kill    "string"
      :close   "string"
      :resizef "string"
      :resizeb "string"
    }
  }

  :highlight {
    :float   "string"
    :success "string"
    :errors  "string"
  }
})


(local ENV {
  :vimrc   (resolve (.. config-dir "/init.fnl"))
  :source  (resolve (.. config-dir "/fnl/"))
  :target  (resolve (.. config-dir "/lua/"))
  :rtpdirs []

  :custom []

  :compiler {
    :float   true
    :clean   true
    :force   false
    :verbose true
    :version "latest"
    :adviser #$
    :globals (vim.tbl_keys _G)
    :hooks   []
  }

  :eval {
    :float  true
    :luafmt luafmt
    :diagnostic {
      :virtual true
      :timeout 10
    }
  }

  :keymaps {
    :eval_buffer "gE"
    :peek_buffer "gL"
    :goto_output "gO"
    :float {
      :next    "<C-K>"
      :prev    "<C-J>"
      :kill    "<Esc>"
      :close   "<Enter>"
      :resizef "<C-W>="
      :resizeb "<C-W>-"
    }
  }

  :highlight {
    :float   "Normal"
    :success "String"
    :errors  "DiagnosticError"
  }
})


;; -------------------- ;;
;;      VALIDATION      ;;
;; -------------------- ;;
(lambda validate-err [key msg ...]
  "shows validation failed error for 'key' with description 'msg'."
  (error
    (.. "[tangerine]: bad argument to 'setup()' in key " key ": " (table.concat [msg ...] " ") ".")))


(lambda validate-type [key val scm]
  "checks if typeof 'val' == 'scm', else throws an error."
  (local tv (get-type val))
  (if (not= scm tv)
      (validate-err key scm "expected got" tv)))


(lambda validate-oneof [key val scm]
  "checks if 'val' is member of 'scm', else throws error."
  (if (not (vim.tbl_contains scm val))
      (validate-err key "value expected to be one of" (vim.inspect scm) "got" (vim.inspect val))))


(lambda validate-array [key array scm]
  "checks if members of 'array' are present in 'scm'."
  (validate-type key array :list)
  (each [_ val (ipairs array)]
        (validate-oneof key val scm)))


(lambda validate-list [key list scm]
  "recursively checks if all elements of 'list' are of type 'scm'."
  (validate-type key list :list)
  (each [_ val (ipairs list)]
    (if (= :list (get-type scm))
        (validate-list key val (. scm 1))
        (let [tv (get-type val)]
          (if (not= scm tv)
              (validate-err key "member" (.. (vim.inspect val) ::) scm "expected got" tv))))))


(lambda validate [tbl schema]
  "recursively validates 'tbl' against 'schema', raises error on failure."
  (each [key val (pairs tbl)]
        (local scm (. schema key))
        (if (not scm)
            (validate-err key :invalid :key))
        (match [(get-type scm) (. scm 1)]
          [:string nil]    (validate-type  key val scm)
          [:table  nil]    (validate val scm)
          [:list   :oneof] (validate-oneof key val (. scm 2))
          [:list   :array] (validate-array key val (. scm 2))
          [:list   _]      (validate-list  key val (. scm 1)))))


(lambda pre-process [tbl schema]
  "recursively runs pre processors defined in 'schema' on 'tbl."
  (each [key val (pairs tbl)]
        (local pre (. schema key))
        (match (type pre)
          :table    (pre-process val pre)
          :function (tset tbl key (pre val))))
  :return tbl)


;; -------------------- ;;
;;        GETTERS       ;;
;; -------------------- ;;
(lambda env-get [...]
  "getter for de' table ENV."
  (local keys [...])
  (var   cur ENV)
  (while (and (not= nil cur) (< 0 (# keys)))
    (set cur (. cur (table.remove keys 1))))
  :return cur)

(lambda env-get-conf [opts keys]
  "getter for 'opts', returns value of last key in 'keys' fallbacks to ENV."
  (let [last (. keys (# keys))]
    (if (not= nil (. opts last))
        (. (pre-process opts pre-schema) last)
        (env-get (unpack keys)))))


;; -------------------- ;;
;;        SETTERS       ;;
;; -------------------- ;;
(lambda env-set [tbl]
  "setter for de' table ENV."
  (validate tbl schema)
  (-> (pre-process tbl pre-schema)
      (deepcopy ENV)))


:return {
  :get  env-get
  :set  env-set
  :conf env-get-conf
}
