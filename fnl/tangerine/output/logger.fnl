; ABOUT:
;   Displays compiler success/failure logs to the users.
;
; DEPENDS:
; (log.*)   utils[env]
; (float-*) utils[window]
(local env (require :tangerine.utils.env))
(local win (require :tangerine.utils.window))
(local log {})

(local hl-success (env.get :highlight :success))
(local hl-failure (env.get :highlight :errors))
(local hl-float   (env.get :highlight :float))

;; -------------------- ;;
;;        Utils         ;;
;; -------------------- ;;
(lambda empty? [list]
  "checks if 'list' is empty."
  (if (not (vim.tbl_islist list))
      (error 
        (.. "[tangerine]: error in logger, expected 'list' to be a valid list got " (type list) ".")))
  :return 
  (= (length list) 0))

(lambda indent [str level]
  "add 'level' of indentation to 'str'."
  (var spaces "")
  (for [_ 1 level]
       (set spaces (.. spaces " ")))
  (-> str 
      (string.gsub "^"  spaces)
      (string.gsub "\n" (.. "\n" spaces))))

(lambda syn-match [group pattern]
  "defines syntax match of 'pattern' with 'group'."
  (vim.cmd
    (.. "syn match " group " \"" pattern "\"")))


;; -------------------- ;;
;;       Loggers        ;;
;; -------------------- ;;
(local header-block  ":: ")
(local success-block "  ==> ")
(local failure-block "  xxx ")

(lambda parse-title [title]
  "prefixes 'title' with header block."
  (.. header-block title))

(lambda log.print-success [title files]
  "prints 'title' and list of successful 'files'."
  (print (parse-title title))
  (each [_ file (ipairs files)]
        (vim.api.nvim_echo [[success-block hl-success] [file :Normal]] false {})))

(lambda log.print-failure [title file msg]
  "prints 'title' and 'file' with error 'msg'."
  (print (parse-title title))
  (vim.api.nvim_echo [[failure-block hl-failure] [file :Normal]] false {})
  (vim.api.nvim_echo [[(indent msg (# failure-block)) hl-failure]] false {}))

(lambda log.float-success [title files]
  "outputs 'title' and list of successful 'files' inside an floating window."
  (var out (parse-title title))
  (each [_ file (ipairs files)]
        (set out (.. out "\n" success-block file)))
  (win.set-float out :text :Normal)
  (syn-match hl-success success-block))

(lambda log.float-failure [title file msg]
  "outputs 'title' and 'file' with error 'msg' inside an floating window."
  (local out
    (-> (parse-title title)
        (.. "\n" failure-block file)
        (.. "\n" (indent msg (# failure-block)))))
  (win.set-float out :text :Normal)
  (syn-match hl-failure failure-block)
  (syn-match hl-failure (indent ".*" (# failure-block))))


;; -------------------- ;;
;;         MAIN         ;;
;; -------------------- ;;
(lambda log.success [title files opts]
  "logs successful list of 'file' with heading 'title'."
  ;; opts { :float boolean :verbose false }
  (if (or (empty? files)
          (not (env.conf opts [:compiler :verbose])))
      (lua :return))
  (if (env.conf opts [:compiler :float]) 
      (log.float-success title files)
      :else
      (log.print-success title files))
  :return true)

(lambda log.failure [title file msg opts]
  "logs error 'msg' for 'file' with heading 'title'."
  ;; opts { :float boolean }
  (if (env.conf opts [:compiler :float])
      (log.float-failure title file msg)
      :else
      (log.print-failure title file msg))
  :return true)

; EXAMPLES:
; (log.success "COMPILED" ["tangerine.fnl" "lol/init.fnl" "lol/bazzz.fnl" "more/stuff/fooo.fnl"] {:float true :verbose true})
; (log.failure "COMPILE ERROR" "tangerine.fnl" 
; "SOME ERROR HAPPENED HERE
; # try doing foo
; # try doing baz" {:float true})

 
:return log
