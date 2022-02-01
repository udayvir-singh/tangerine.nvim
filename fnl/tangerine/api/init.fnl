; DEPENDS:
; :api tangerine.api.**
; :api tangerine.utils.path
; :api tangerine.utils.logger
(local prefix "tangerine.")

;; -------------------- ;;
;;         Utils        ;;
;; -------------------- ;;
(lambda lazy [module func]
  "lazy require 'module' and call 'func' from it."
  (fn [...]
      ((-> (require (.. prefix module)) 
           (. func)) ...)))


;; -------------------- ;;
;;         API          ;;
;; -------------------- ;;

:return :api {
  :eval {
    :string (lazy :api.eval "string")
    :file   (lazy :api.eval "file")
    :range  (lazy :api.eval "range")
    :buffer (lazy :api.eval "buffer")
  }
  :compile {
    :string (lazy :api.compile "string")
    :file   (lazy :api.compile "file")
    :dir    (lazy :api.compile "dir")
    :buffer (lazy :api.compile "buffer")
    :vimrc  (lazy :api.compile "vimrc")
    :all    (lazy :api.compile "all")
  }
  :clean {
    :target   (lazy :api.clean "target")
    :orphaned (lazy :api.clean "orphaned")
  }
  :goto_output (lazy :utils.path "goto-output")
  :serialize   (lazy :utils.logger "serialize")
}
