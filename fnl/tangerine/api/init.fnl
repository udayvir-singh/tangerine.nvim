; DEPENDS:
; :return api[*]
; :return utils[path]
; :return utils[serialize]
; :return utils[window]

;; -------------------- ;;
;;         UTILS        ;;
;; -------------------- ;;
(lambda lazy [module ?func]
  "lazy require 'module' and optionally calls 'func'."
  (fn [...]
    (local mod (require (.. "tangerine." module)))
    :return
    ((if ?func (. mod ?func) mod) ...)))


;; -------------------- ;;
;;         API          ;;
;; -------------------- ;;
:return
{
  :eval {
    :string (lazy :api.eval "string")
    :file   (lazy :api.eval "file")
    :buffer (lazy :api.eval "buffer")
    :peek   (lazy :api.eval "peek")
  }
  :compile {
    :string (lazy :api.compile "string")
    :file   (lazy :api.compile "file")
    :dir    (lazy :api.compile "dir")
    :buffer (lazy :api.compile "buffer")
    :vimrc  (lazy :api.compile "vimrc")
    :rtp    (lazy :api.compile "rtp")
    :custom (lazy :api.compile "custom")
    :all    (lazy :api.compile "all")
  }
  :clean {
    :target   (lazy :api.clean "target")
    :rtp      (lazy :api.clean "rtp")
    :orphaned (lazy :api.clean "orphaned")
  }
  :win {
    :next    (lazy :utils.window "next")
    :prev    (lazy :utils.window "prev")
    :close   (lazy :utils.window "close")
    :resize  (lazy :utils.window "resize")
    :killall (lazy :utils.window "killall")
  }
  :goto_output (lazy :utils.path "goto-output")
  :serialize   (lazy :utils.serialize)
}
