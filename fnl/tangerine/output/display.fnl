; ABOUT:
;   Serializes evaluation results and pretty prints them.
;
; DEPENDS:
; (show)        utils[window]
; (show format) utils[env]
(local env (require :tangerine.utils.env))
(local win (require :tangerine.utils.window))
(local dp {})

;; -------------------- ;;
;;      Serialize       ;;
;; -------------------- ;; 
(lambda escape-quotes [str]
  "shell escapes double quotes in 'str'."
  (let [qt  "\"" esc "\\\""]
       (.. qt (str:gsub qt esc) qt)))

(lambda serialize-tbl [tbl]
  "converts 'tbl' into readable fennel table."
  (-> (vim.inspect tbl)
      ;; escape single quotes
      (string.gsub "= +'([^']+)'" escape-quotes)
      ;; remove "," and "= "
      (string.gsub "," "")
      (string.gsub "= " "")
      ;; append ":" in front of keys
      (string.gsub "(\n -)[^<[%w]([%w_-])" "%1 :%2")
      ;; convert [key] to :key
      (string.gsub "(\n -)%[\"(.-)\"%]" "%1:%2")
      (string.gsub "(\n -)%[(.-)%]" "%1%2")
      ;; convert {1, 2} to [1 2]
      (string.gsub "^%{ (.+)%}" "[ %1]")
      (string.gsub "%{( [^{}]+ )%}" "[%1]") ; ignore brackets in nested lists
      (string.gsub "%{( [^{}]+ )%}" "[%1]")))

(fn dp.serialize [xs return?]
  "converts 'xs' into human readable form."
  (var out "")
  (if (= (type xs) :table)
      (set out (serialize-tbl xs))
      :else
      (set out (vim.inspect xs)))
  (.. (if return? ":return " "") out))


;; -------------------- ;;
;;        Format        ;;
;; -------------------- ;;
(lambda dp.format [code]
  "runs formatter on lua 'code' defined in ENV."
  (let [luafmt ((env.get :eval :luafmt))]
    (if (or (= 0 (# luafmt))
            (= 0 (vim.fn.executable (. luafmt 1))))
        (do code)
        (vim.fn.system luafmt code))))


;; -------------------- ;;
;;        Output        ;;
;; -------------------- ;;
(lambda dp.show [?val opts]
  "serializes 'val' and displays inside float if opts.float = true."
  ;; opts { :float boolean }
  (if (= ?val nil) (lua :return))
  (let [out (dp.serialize ?val true)]
    (if (env.conf opts [:eval :float])
        (win.set-float out :fennel (env.get :highlight :float))
        :else
        (print out))
    :return true))

(lambda dp.show-lua [code opts]
  "show lua 'code' inside float if opts.float = true."
  ;; opts { :float boolean }
  (let [out (string.gsub (dp.format code) "\n$" "")]
    (if (env.conf opts [:eval :float])
        (win.set-float out :lua (env.get :highlight :float))
        :else
        (print out))
    :return true))

; EXAMPLES:
; (dp.show { 3 [:list 1] :foo* "baz \"" } {:float true})
; (dp.show-lua "return {foo={bar='value', baz=string, wrap=here}}" {:float true})


:return dp
