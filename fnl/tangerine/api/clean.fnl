; ABOUT:
;   Functions to clean stale lua files in target dirs.
;
; DEPENDS:
; (-target)           utils[fs]
; (-target)           utils[env]
; (-target)           utils[diff]
; (-target -orphaned) utils[path]
; (-target -orphaned) output[logger]
(local {
  : p
  : fs
  : df
  : env
} (require :tangerine.utils))

(local { 
  : log
} (require :tangerine.output))

(local clean {})

;; -------------------- ;;
;;        Utils         ;;
;; -------------------- ;;
(lambda merge [list1 list2]
  "merges values of 'list2' onto 'list1'."
  (each [_ val (ipairs list2)]
        (table.insert list1 val))
  list1)

(lambda tbl-merge [tbl1 tbl2]
  "merges 'tbl1' onto 'tbl2'."
  (vim.tbl_extend "keep" (or tbl1 {}) tbl2))


;; -------------------- ;;
;;         MAIN         ;;
;; -------------------- ;;
(lambda clean.target [source target ?opts]
  "checks if lua:'target' is Marked and has a readable fnl:'source', 
   if not then it deletes 'target'."
  ;; opts { :force boolean }
  (local opts (or ?opts {}))
  (let [target  (p.resolve target)
        source? (fs.readable? (p.resolve source))
        marker? (df.read-marker target)
        force?  (env.conf opts [:force])]
    (if (and marker? (or (not source?) force?))
        (fs.remove target)
        :else false)))

(lambda clean.rtp [?opts]
  "deletes orphaned lua files in ENV.rtpdirs or 'opts.rtpdirs'."
  ;; opts { :rtpdirs list :force boolean :verbose boolean :float boolean }
  (local opts (or ?opts {}))
  (local logs [])
  (local dirs (env.conf opts [:rtpdirs]))
  :clean
  (each [_ dir (ipairs dirs)]
    (each [_ target (ipairs (p.wildcard dir "**/*.lua"))]
          (local source (target:gsub ".lua$" ".fnl"))
          (if (clean.target source target opts)
              (table.insert logs (p.shortname target)))))
  :logger (log.success "CLEANED" logs opts)
  :return logs)

(lambda clean.orphaned [?opts]
  "deletes orphaned lua files indexed in ENV."
  ;; opts { :rtpdirs list :force boolean :verbose boolean :float boolean }
  (local opts (or ?opts {}))
  (local logs [])
  :clean
  (merge logs
    (clean.rtp (tbl-merge {:verbose false} opts)))
  (each [_ target (ipairs (p.list-lua-files))]
        (if (clean.target (p.source target) target opts) 
            (table.insert logs (p.shortname target))))
  :logger (log.success "CLEANED" logs opts))

; EXAMPLES:
; (pcall tangerine.api.compile.all {:verbose false}) ;; setup
; (clean.rtp {:rtpdirs [:plugin] :force true :verbose true :float true})
; (clean.orphaned {:force true :verbose true :float true})


:return clean
